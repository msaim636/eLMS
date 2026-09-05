import 'package:elms/common/enums.dart';
import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/course/cubit/course_details_cubit.dart';
import 'package:elms/features/course/features/quiz/cubits/finish_quiz_cubit.dart';
import 'package:elms/features/course/features/quiz/cubits/start_quiz_cubit.dart';
import 'package:elms/features/course/features/quiz/cubits/submit_answer_cubit.dart';
import 'package:elms/features/course/features/quiz/repositories/quiz_repository.dart';
import 'package:elms/features/course/features/quiz/widgets/quiz_option_widget.dart';
import 'package:elms/utils/course_navigation_helper.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/screen_protection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

/// Arguments for QuizScreen
class QuizScreenArguments {
  final int courseChapterQuizId;
  final String quizTitle;
  final int totalMarks;
  final int passingMarks;
  final List<Question> questions;
  final int courseId;
  final int chapterId;
  final int chapterIndex;
  final CourseDetailsCubit? courseDetailsCubit;

  QuizScreenArguments({
    required this.courseChapterQuizId,
    required this.quizTitle,
    required this.totalMarks,
    required this.passingMarks,
    required this.questions,
    required this.courseId,
    required this.chapterId,
    required this.chapterIndex,
    this.courseDetailsCubit,
  });
}

class QuizScreen extends StatelessWidget {
  final QuizScreenArguments arguments;

  static Widget route([RouteSettings? settings]) {
    final QuizScreenArguments? args =
        (settings?.arguments ?? Get.arguments) as QuizScreenArguments?;
    if (args == null) {
      throw Exception('QuizScreenArguments required for QuizScreen');
    }
    return QuizScreen(arguments: args);
  }

  const QuizScreen({super.key, required this.arguments});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              StartQuizCubit(QuizRepository())
                ..startQuiz(courseChapterQuizId: arguments.courseChapterQuizId),
        ),
        BlocProvider(create: (context) => SubmitAnswerCubit(QuizRepository())),
        BlocProvider(create: (context) => FinishQuizCubit(QuizRepository())),
      ],
      child: _QuizScreenContent(
        questions: arguments.questions,
        points: arguments.totalMarks,
        passingMarks: arguments.passingMarks,
        courseChapterQuizId: arguments.courseChapterQuizId,
        quizTitle: arguments.quizTitle,
        courseId: arguments.courseId,
        chapterId: arguments.chapterId,
        chapterIndex: arguments.chapterIndex,
        courseDetailsCubit: arguments.courseDetailsCubit,
      ),
    );
  }
}

class _QuizScreenContent extends StatefulWidget {
  final List<Question> questions;
  final int points;
  final int passingMarks;
  final int courseChapterQuizId;
  final String quizTitle;
  final int courseId;
  final int chapterId;
  final int chapterIndex;
  final CourseDetailsCubit? courseDetailsCubit;

  const _QuizScreenContent({
    required this.questions,
    required this.points,
    required this.passingMarks,
    required this.courseChapterQuizId,
    required this.quizTitle,
    required this.courseId,
    required this.chapterId,
    required this.chapterIndex,
    this.courseDetailsCubit,
  });

  @override
  State<_QuizScreenContent> createState() => _QuizScreenContentState();
}

class _QuizScreenContentState extends State<_QuizScreenContent>
    with ScreenProtection {
  final PageController _pageController = PageController();
  int? _attemptId;
  final Map<String, String> _selectedAnswers = {};
  int _currentQuestionIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onTapNext() async {
    // Check if answer is selected for current question
    final currentQuestion = widget.questions[_currentQuestionIndex];
    if (!_selectedAnswers.containsKey(currentQuestion.id.toString())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLabels.pleaseSelectAnAnswer.tr)),
      );
      return;
    }

    if (_attemptId == null) return;

    // Submit answer to API when tapping Next
    final selectedOptionId = _selectedAnswers[currentQuestion.id.toString()]!;
    await context.read<SubmitAnswerCubit>().submitAnswer(
      quizQuestionId: currentQuestion.id,
      quizOptionId: int.parse(selectedOptionId),
      attemptId: _attemptId!,
    );

    if (!mounted) return;

    if (_currentQuestionIndex >= widget.questions.length - 1) {
      // Finish quiz
      _finishQuiz();
    } else {
      // Move to next question
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _finishQuiz() {
    if (_attemptId == null) return;

    context.read<FinishQuizCubit>().finishQuiz(attemptId: _attemptId!);
  }

  void _onOptionSelected(String questionId, String optionId) {
    // Just store the selection locally, don't call API yet
    setState(() {
      _selectedAnswers[questionId] = optionId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StartQuizCubit, StartQuizState>(
          listener: (context, state) {
            if (state is StartQuizSuccess) {
              setState(() {
                _attemptId = state.attempt.id;
              });
            } else if (state is StartQuizFail) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLabels.failedToStartQuiz.tr.replaceAll(
                      '{{error}}',
                      state.error,
                    ),
                  ),
                ),
              );
              Get.back();
            }
          },
        ),
        BlocListener<SubmitAnswerCubit, SubmitAnswerState>(
          listener: (context, state) {
            if (state is SubmitAnswerFail) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to submit answer: ${state.error}'),
                ),
              );
            }
          },
        ),
        BlocListener<FinishQuizCubit, FinishQuizState>(
          listener: (context, state) async {
            if (state is FinishQuizSuccess) {
              // Determine pass/fail based on score and passing marks
              final bool isPassed = state.response.score >= widget.passingMarks;
              final QuizResult quizResult = isPassed
                  ? QuizResult.pass
                  : QuizResult.fail;

              await CourseNavigationHelper.navigateToCourseContentRoute(
                nestedRoute: CourseContentRoute.quizResult,
                replace: true,
                arguments: QuizResultParams(
                  result: quizResult,
                  passingMarks: widget.passingMarks,
                  courseChapterQuizId: widget.courseChapterQuizId,
                  quizTitle: widget.quizTitle,
                  totalMarks: widget.points,
                  questions: widget.questions,
                  courseId: widget.courseId,
                  chapterId: widget.chapterId,
                  chapterIndex: widget.chapterIndex,
                  courseDetailsCubit: widget.courseDetailsCubit,
                ),
              );
            } else if (state is FinishQuizFail) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to finish quiz: ${state.error}'),
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: CustomAppBar(
          showBackButton: true,
          title: AppLabels.quizPlay.tr,
        ),
        bottomNavigationBar: BottomAppBar(
          padding: const .symmetric(horizontal: 16, vertical: 8),
          height: kBottomNavigationBarHeight,
          child: BlocBuilder<StartQuizCubit, StartQuizState>(
            builder: (context, state) {
              if (state is StartQuizInProgress) {
                return const Center(child: CircularProgressIndicator());
              }
              return CustomButton(
                title: _currentQuestionIndex >= widget.questions.length - 1
                    ? AppLabels.complete.tr
                    : AppLabels.next.tr,
                onPressed: _attemptId != null ? _onTapNext : null,
              );
            },
          ),
        ),
        body: BlocBuilder<StartQuizCubit, StartQuizState>(
          builder: (context, state) {
            if (state is StartQuizInProgress) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is StartQuizFail) {
              return Center(child: Text('Error: ${state.error}'));
            }

            return PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final question = widget.questions[index];
                return QuizContent(
                  chapterName: widget.quizTitle,
                  chapterIndex: widget.chapterIndex,
                  question: question,
                  index: index,
                  totalQuestions: widget.questions.length,
                  points: widget.points,
                  selectedOptionId: _selectedAnswers[question.id.toString()],
                  onOptionSelected: (optionId) =>
                      _onOptionSelected(question.id.toString(), optionId),
                );
              },
              itemCount: widget.questions.length,
            );
          },
        ),
      ),
    );
  }
}

class QuizContent extends StatelessWidget {
  final String chapterName;
  final int chapterIndex;
  final Question question;
  final int index;
  final int totalQuestions;
  final int points;
  final String? selectedOptionId;
  final Function(String) onOptionSelected;

  const QuizContent({
    super.key,
    required this.question,
    required this.index,
    required this.chapterName,
    required this.chapterIndex,
    required this.totalQuestions,
    required this.points,
    this.selectedOptionId,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const .all(16),
      child: Column(
        children: [
          _buildQuizDetail(context),
          const SizedBox(height: 26),
          _buildQuestion(context),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final option = question.options[index];
              final isSelected = selectedOptionId == option.id.toString();
              return QuizOption(
                index: index,
                option: option.option,
                isSelected: isSelected,
                onSelectionChange: (_, __) {
                  onOptionSelected(option.id.toString());
                },
              );
            },
            itemCount: question.options.length,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    return CustomCard(
      padding: const .all(16),
      child: Row(
        spacing: 16,
        children: [
          _buildQuestionNumber('${index + 1}', context),
          Expanded(
            child: CustomText(
              question.question,
              style: TextStyle(fontSize: context.font.small),
              softWrap: true,
              fontWeight: .w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionNumber(String text, BuildContext context) {
    return CustomCard(
      width: 40,
      height: 40,
      borderRadius: 4,
      border: 0,
      color: context.color.darkColor,
      child: Center(
        child: CustomText(
          'Q. $text',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(color: context.color.onPrimary),
        ),
      ),
    );
  }

  Widget _buildQuizDetail(BuildContext context) {
    return CustomCard(
      padding: const .symmetric(vertical: 12, horizontal: 8),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            '${chapterIndex + 1}. $chapterName',
            style: TextStyle(
              fontSize: context.font.medium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(),
          _buildQuizInfo(context),
        ],
      ),
    );
  }

  Widget _buildQuizInfo(BuildContext context) {
    return Row(
      children: [
        CustomText(
          '${AppLabels.question.tr}: ${index + 1}/$totalQuestions',
          style: TextStyle(fontSize: context.font.medium),
        ),
        const Spacer(),
        CustomCard(
          padding: const .symmetric(vertical: 4, horizontal: 16),
          color: context.color.outline.withValues(alpha: 0.5),
          borderRadius: 4,
          border: 0,
          child: CustomText('$points ${AppLabels.points.tr}'),
        ),
      ],
    );
  }
}
