import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class QuizSummaryModel extends Model {
  final int quizId;
  final String quizTitle;
  final int attemptId;
  final int totalPoints;
  final int earnedPoints;
  final num score;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int timeTaken;
  final String attemptedAt;
  final List<QuizSummaryQuestion> questions;

  QuizSummaryModel({
    required this.quizId,
    required this.quizTitle,
    required this.attemptId,
    required this.totalPoints,
    required this.earnedPoints,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeTaken,
    required this.attemptedAt,
    required this.questions,
  });

  factory QuizSummaryModel.fromJson(Map<String, dynamic> json) {
    return QuizSummaryModel(
      quizId: json.optional<int>('quiz_id') ?? 0,
      quizTitle: json.optional<String>('quiz_title') ?? '',
      attemptId: json.optional<int>('attempt_id') ?? 0,
      totalPoints: json.optional<int>('total_points') ?? 0,
      earnedPoints: json.optional<int>('earned_points') ?? 0,
      score: json.optional<num>('score') ?? 0,
      totalQuestions: json.optional<int>('total_questions') ?? 0,
      correctAnswers: json.optional<int>('correct_answers') ?? 0,
      wrongAnswers: json.optional<int>('wrong_answers') ?? 0,
      timeTaken: json.optional<int>('time_taken') ?? 0,
      attemptedAt: json.optional<String>('attempted_at') ?? '',
      questions:
          (json.optional<List>('questions'))
              ?.map(
                (q) => QuizSummaryQuestion.fromJson(q as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'quiz_id': quizId,
      'quiz_title': quizTitle,
      'attempt_id': attemptId,
      'total_points': totalPoints,
      'earned_points': earnedPoints,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'time_taken': timeTaken,
      'attempted_at': attemptedAt,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class QuizSummaryQuestion extends Model {
  final String questionNumber;
  final int questionId;
  final String question;
  final String? yourAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String points;

  QuizSummaryQuestion({
    required this.questionNumber,
    required this.questionId,
    required this.question,
    this.yourAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.points,
  });

  factory QuizSummaryQuestion.fromJson(Map<String, dynamic> json) {
    return QuizSummaryQuestion(
      questionNumber: json.optional<String>('question_number') ?? '',
      questionId: json.optional<int>('question_id') ?? 0,
      question: json.optional<String>('question') ?? '',
      yourAnswer: json.optional<String>('your_answer'),
      correctAnswer: json.optional<String>('correct_answer') ?? '',
      isCorrect: json.optional<bool>('is_correct') ?? false,
      points: json.optional<String>('points') ?? '0',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'question_number': questionNumber,
      'question_id': questionId,
      'question': question,
      'your_answer': yourAnswer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'points': points,
    };
  }
}
