import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_expandable_tile.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/course/features/quiz/cubits/fetch_quiz_summary_cubit.dart';
import 'package:elms/features/course/features/quiz/models/quiz_summary_model.dart';
import 'package:elms/features/course/features/quiz/repositories/quiz_summary_repository.dart';
import 'package:elms/utils/course_navigation_helper.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get/route_manager.dart';

class QuizSummaryScreen extends StatefulWidget {
  final int courseChapterQuizId;

  const QuizSummaryScreen({super.key, required this.courseChapterQuizId});

  static Widget route([RouteSettings? settings]) {
    final arguments =
        (settings?.arguments ?? Get.arguments) as Map<String, dynamic>?;
    if (arguments == null) {
      throw Exception(
        'Map<String, dynamic> with courseChapterQuizId required for QuizSummaryScreen',
      );
    }
    final int courseChapterQuizId = arguments['courseChapterQuizId'] as int;
    return BlocProvider(
      create: (context) => FetchQuizSummaryCubit(QuizSummaryRepository()),
      child: QuizSummaryScreen(courseChapterQuizId: courseChapterQuizId),
    );
  }

  @override
  State<QuizSummaryScreen> createState() => _QuizSummaryScreenState();
}

class _QuizSummaryScreenState extends State<QuizSummaryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FetchQuizSummaryCubit>().fetchQuizSummary(
      courseChapterQuizId: widget.courseChapterQuizId,
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
        padding: const .all(8),
        height: kBottomNavigationBarHeight,
        child: CustomButton(
          title: AppLabels.nextChapter.tr,
          onPressed: () {
            CourseNavigationHelper.popToCourseContent();
          },
        ),
      ),
      body: BlocBuilder<FetchQuizSummaryCubit, FetchQuizSummaryState>(
        builder: (context, state) {
          if (state is FetchQuizSummaryInProgress) {
            return const Center(child: CustomShimmer());
          }

          if (state is FetchQuizSummaryFail) {
            return Center(
              child: CustomText(
                'Error loading quiz summary',
                style: TextStyle(fontSize: context.font.small),
              ),
            );
          }

          if (state is FetchQuizSummarySuccess) {
            final summary = state.summary;
            return SingleChildScrollView(
              padding: const .all(16),
              child: Column(
                children: [
                  _buildStats(context, summary),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final question = summary.questions[index];
                      return _buildQuestionResult(
                        context: context,
                        questionNumber: question.questionNumber,
                        question: question.question,
                        yourAnswer: question.yourAnswer,
                        correctAnswer: question.correctAnswer,
                        isCorrect: question.isCorrect,
                        points: question.points,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 12);
                    },
                    itemCount: summary.questions.length,
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildQuestionResult({
    required BuildContext context,
    required String questionNumber,
    required String question,
    required String? yourAnswer,
    required String correctAnswer,
    required bool isCorrect,
    required String points,
  }) {
    return CustomExpandableTile(
      title: question,
      content: Column(
        spacing: 8,
        children: [
          if (yourAnswer != null)
            _buildSummeryInfo(
              context,
              title: AppLabels.yourAnswer.tr,
              value: yourAnswer,
              icon: isCorrect ? AppIcons.correct : AppIcons.wrong,
              color: isCorrect ? context.color.primary : context.color.error,
            ),
          _buildSummeryInfo(
            context,
            title: AppLabels.correctAnswer.tr,
            value: correctAnswer,
            icon: AppIcons.correct,
            color: context.color.primary,
          ),
        ],
      ),
      onToggle: () {},
      customIcon: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: context.color.primary, shape: .circle),
        padding: const .all(5),
        child: CustomImage(
          AppIcons.arrowDown,
          color: context.color.onPrimary,
          width: 14,
          height: 14,
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, QuizSummaryModel summary) {
    return CustomCard(
      padding: const .all(8),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Column(
              spacing: 10,
              children: [
                _buildSummeryInfo(
                  context,
                  title: AppLabels.correctAnswers.tr,
                  value: summary.correctAnswers.toString(),
                  icon: AppIcons.correct,
                  color: context.color.primary,
                ),
                _buildSummeryInfo(
                  context,
                  title: AppLabels.wrongAnswers.tr,
                  value: summary.wrongAnswers.toString(),
                  icon: AppIcons.wrong,
                  color: context.color.error,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: CustomCard(
              padding: const .symmetric(vertical: 8, horizontal: 16),
              border: 0,
              color: context.color.primary.withValues(alpha: 0.14),
              child: CustomText(
                '${AppLabels.totalPoints.tr}\n${summary.earnedPoints}/${summary.totalPoints}',
                textAlign: .center,
                style: TextStyle(
                  fontSize: context.font.small,
                  color: context.color.primary,
                  fontWeight: .w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummeryInfo(
    BuildContext context, {
    required String title,
    required String value,
    required String icon,
    Color? color,
  }) {
    return Row(
      spacing: 8,
      children: [
        CustomImage(icon, width: 20, height: 20),
        Expanded(
          child: CustomText(
            '$title: $value',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
