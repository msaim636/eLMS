import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/course/cubit/course_details_cubit.dart';
import 'package:elms/features/course/features/quiz/screens/quiz_screen.dart';
import 'package:elms/utils/course_navigation_helper.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class StartQuizCard extends StatelessWidget {
  final String? courseChapterQuizId;
  final CurriculumModel curriculum;
  final int courseId;
  final int chapterId;
  final int chapterIndex;
  final VoidCallback? onSkipToNext;

  const StartQuizCard({
    super.key,
    this.courseChapterQuizId,
    required this.curriculum,
    required this.courseId,
    required this.chapterId,
    required this.chapterIndex,
    this.onSkipToNext,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      height: 215,
      width: double.infinity,
      padding: const .all(10),
      color: context.color.outline,
      child: Column(
        mainAxisAlignment: .center,
        spacing: 8,
        children: [
          CustomImage(AppIcons.quiz),
          CustomText(
            AppLabels.startQuizTitle.tr,
            style: TextStyle(fontSize: context.font.xSmall),
          ),
          CustomText(
            AppLabels.startQuizDescription.tr,
            textAlign: .center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontSize: 10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12,
            children: [
              CustomButton(
                title: AppLabels.startQuiz.tr,
                onPressed: () {
                  final cubit = context.read<CourseDetailsCubit?>();
                  CourseNavigationHelper.navigateToCourseContentRoute(
                    nestedRoute: CourseContentRoute.quiz,
                    arguments: QuizScreenArguments(
                      passingMarks: curriculum.passingScore ?? 0,
                      questions: curriculum.questions!,
                      courseChapterQuizId: int.parse(courseChapterQuizId ?? ''),
                      quizTitle: curriculum.title,
                      totalMarks: curriculum.totalPoints!,
                      courseId: courseId,
                      chapterId: chapterId,
                      chapterIndex: chapterIndex,
                      courseDetailsCubit: cubit,
                    ),
                  );
                },
                backgroundColor: context.color.darkColor,
                height: 26,
                width: 160,
                radius: 4,
              ),
              if (curriculum.canSkip ?? false)
                CustomButton(
                  title: AppLabels.skip.tr,
                  onPressed: onSkipToNext,
                  backgroundColor: Colors.transparent,
                  borderColor: context.color.outline,
                  textColor: context.color.darkColor,
                  height: 26,
                  width: 80,
                  radius: 4,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
