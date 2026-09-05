import 'package:elms/common/enums.dart';
import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/core/services/refresh_notifier.dart';
import 'package:elms/features/course/cubit/course_details_cubit.dart';
import 'package:elms/features/course/features/quiz/screens/quiz_screen.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/utils/course_navigation_helper.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizResult quizResult;
  final int passingMarks;
  final int courseChapterQuizId;
  final String quizTitle;
  final int totalMarks;
  final List<Question> questions;
  final int courseId;
  final int chapterId;
  final int chapterIndex;
  final CourseDetailsCubit? courseDetailsCubit;

  const QuizResultScreen({
    super.key,
    required this.quizResult,
    required this.passingMarks,
    required this.courseChapterQuizId,
    required this.quizTitle,
    required this.totalMarks,
    required this.questions,
    required this.courseId,
    required this.chapterId,
    required this.chapterIndex,
    this.courseDetailsCubit,
  });

  static Widget route([RouteSettings? settings]) {
    final QuizResultParams? params =
        (settings?.arguments ?? Get.arguments) as QuizResultParams?;
    if (params == null) {
      throw Exception('QuizResultParams required for QuizResultScreen');
    }
    return QuizResultScreen(
      quizResult: params.result,
      passingMarks: params.passingMarks,
      courseChapterQuizId: params.courseChapterQuizId,
      quizTitle: params.quizTitle,
      totalMarks: params.totalMarks,
      questions: params.questions,
      courseId: params.courseId,
      chapterId: params.chapterId,
      chapterIndex: params.chapterIndex,
      courseDetailsCubit: params.courseDetailsCubit,
    );
  }

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late bool didPass = widget.quizResult == QuizResult.pass;

  @override
  void initState() {
    super.initState();
    // Mark curriculum as complete when quiz is passed after frame is built
    if (didPass) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _markQuizComplete();
      });
    }
  }

  Future<void> _markQuizComplete() async {
    await CourseRepository().markCurriculumCompleted(
      chapterId: widget.chapterId,
      modelId: widget.courseChapterQuizId,
      modelType: 'quiz',
    );

    if (mounted && widget.courseDetailsCubit != null) {
      await widget.courseDetailsCubit!.refresh(widget.courseId);
      RefreshNotifier.instance.markMyLearningForRefresh();
    }
  }

  void _onTapNext() {
    if (didPass) {
      CourseNavigationHelper.popToCourseContent();
    } else {
      // Restart quiz - replace current result screen with a fresh quiz screen
      CourseNavigationHelper.navigateToCourseContentRoute(
        nestedRoute: CourseContentRoute.quiz,
        replace: true,
        arguments: QuizScreenArguments(
          courseChapterQuizId: widget.courseChapterQuizId,
          quizTitle: widget.quizTitle,
          totalMarks: widget.totalMarks,
          passingMarks: widget.passingMarks,
          questions: widget.questions,
          courseId: widget.courseId,
          chapterId: widget.chapterId,
          chapterIndex: widget.chapterIndex,
          courseDetailsCubit: widget.courseDetailsCubit,
        ),
      );
    }
  }

  void _onTapQuizSummary() {
    CourseNavigationHelper.navigateToCourseContentRoute(
      nestedRoute: CourseContentRoute.quizSummary,
      arguments: {'courseChapterQuizId': widget.courseChapterQuizId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLabels.quizSummary.tr,
        showBackButton: true,
      ),
      bottomNavigationBar: BottomAppBar(
        // ignore: prefer_const_constructors
        padding: .all(8).add(const .symmetric(horizontal: 16)),
        color: Colors.transparent,
        child: Row(
          spacing: 16,
          children: [
            if (didPass)
              Expanded(
                child: CustomButton(
                  title: AppLabels.quizSummary.tr,
                  type: CustomButtonType.outlined,
                  borderColor: context.color.primary,
                  textColor: context.color.primary,
                  onPressed: _onTapQuizSummary,
                ),
              ),
            Expanded(
              child: CustomButton(
                title: didPass
                    ? AppLabels.nextChapter.tr
                    : AppLabels.playAgain.tr,
                onPressed: _onTapNext,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const .symmetric(horizontal: 26),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            SizedBox(height: context.screenHeight * 0.1),
            Align(child: CustomImage(AppIcons.quiz, width: 200, height: 200)),
            const SizedBox(height: 30),
            CustomText(
              didPass
                  ? AppLabels.quizSuccessTitle.tr
                  : AppLabels.quizFailTitle.tr,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(fontWeight: .w700),
            ),
            const SizedBox(height: 11),
            CustomText(
              didPass
                  ? AppLabels.quizSuccessDescription.tr
                  : AppLabels.quizFailDescription.tr.translateWithTemplate({
                      'passing_marks': widget.passingMarks.toString(),
                    }),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: .w400),
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }
}
