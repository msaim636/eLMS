import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

/// Model for quiz attempt when starting a quiz
class QuizAttemptModel extends Model {
  final int id;
  final int userId;
  final String courseChapterQuizId;
  final int totalTime;
  final int timeTaken;
  final String score;
  final String createdAt;
  final String updatedAt;

  QuizAttemptModel({
    required this.id,
    required this.userId,
    required this.courseChapterQuizId,
    required this.totalTime,
    required this.timeTaken,
    required this.score,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: json.optional<int>('id') ?? 0,
      userId: json.optional<int>('user_id') ?? 0,
      courseChapterQuizId:
          json.optional<String>('course_chapter_quiz_id') ?? '',
      totalTime: json.optional<int>('total_time') ?? 0,
      timeTaken: json.optional<int>('time_taken') ?? 0,
      score: json.optional<String>('score') ?? '0.00',
      createdAt: json.optional<String>('created_at') ?? '',
      updatedAt: json.optional<String>('updated_at') ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_chapter_quiz_id': courseChapterQuizId,
      'total_time': totalTime,
      'time_taken': timeTaken,
      'score': score,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Model for quiz answer submission response
class QuizAnswerModel extends Model {
  final int id;
  final int userId;
  final String quizQuestionId;
  final String userQuizAttemptId;
  final String quizOptionId;
  final String createdAt;
  final String updatedAt;

  QuizAnswerModel({
    required this.id,
    required this.userId,
    required this.quizQuestionId,
    required this.userQuizAttemptId,
    required this.quizOptionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuizAnswerModel(
      id: json.optional<int>('id') ?? 0,
      userId: json.optional<int>('user_id') ?? 0,
      quizQuestionId: json.optional<String>('quiz_question_id') ?? '',
      userQuizAttemptId: json.optional<String>('user_quiz_attempt_id') ?? '',
      quizOptionId: json.optional<String>('quiz_option_id') ?? '',
      createdAt: json.optional<String>('created_at') ?? '',
      updatedAt: json.optional<String>('updated_at') ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_question_id': quizQuestionId,
      'user_quiz_attempt_id': userQuizAttemptId,
      'quiz_option_id': quizOptionId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Model for quiz questions
class QuizQuestionModel extends Model {
  final int id;
  final String question;
  final String? description;
  final String questionType;
  final int marks;
  final List<QuizOptionModel> options;
  final String? selectedOptionId;

  QuizQuestionModel({
    required this.id,
    required this.question,
    this.description,
    required this.questionType,
    required this.marks,
    required this.options,
    this.selectedOptionId,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json.optional<int>('id') ?? 0,
      question: json.optional<String>('question') ?? '',
      description: json.optional<String>('description'),
      questionType: json.optional<String>('question_type') ?? 'single_choice',
      marks: json.optional<int>('marks') ?? 0,
      options: json.optional<List>('options') != null
          ? (json.optional<List>(
              'options',
            )!).map((option) => QuizOptionModel.fromJson(option)).toList()
          : [],
      selectedOptionId: json.optional<String>('selected_option_id'),
    );
  }

  QuizQuestionModel copyWith({String? selectedOptionId}) {
    return QuizQuestionModel(
      id: id,
      question: question,
      description: description,
      questionType: questionType,
      marks: marks,
      options: options,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'description': description,
      'question_type': questionType,
      'marks': marks,
      'options': options.map((option) => option.toJson()).toList(),
      'selected_option_id': selectedOptionId,
    };
  }
}

/// Model for quiz options
class QuizOptionModel extends Model {
  final int id;
  final String option;
  final bool isCorrect;

  QuizOptionModel({
    required this.id,
    required this.option,
    required this.isCorrect,
  });

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      id: json.optional<int>('id') ?? 0,
      option: json.optional<String>('option') ?? '',
      isCorrect: json.optional<bool>('is_correct') ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'option': option, 'is_correct': isCorrect};
  }
}

/// Model for finish quiz response
class QuizFinishResponseModel extends Model {
  final num score;
  final int totalQuestions;
  final int correctAnswers;

  QuizFinishResponseModel({
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  factory QuizFinishResponseModel.fromJson(Map<String, dynamic> json) {
    return QuizFinishResponseModel(
      score: json.optional<num>('score') ?? 0,
      totalQuestions: json.optional<int>('total_questions') ?? 0,
      correctAnswers: json.optional<int>('correct_answers') ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
    };
  }
}

/// Model for quiz summary
class QuizSummaryModel extends Model {
  final int attemptId;
  final String score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int timeTaken;
  final String percentage;
  final bool isPassed;

  QuizSummaryModel({
    required this.attemptId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.timeTaken,
    required this.percentage,
    required this.isPassed,
  });

  factory QuizSummaryModel.fromJson(Map<String, dynamic> json) {
    return QuizSummaryModel(
      attemptId: json.optional<int>('attempt_id') ?? 0,
      score: json.optional<String>('score') ?? '0',
      totalQuestions: json.optional<int>('total_questions') ?? 0,
      correctAnswers: json.optional<int>('correct_answers') ?? 0,
      incorrectAnswers: json.optional<int>('incorrect_answers') ?? 0,
      timeTaken: json.optional<int>('time_taken') ?? 0,
      percentage: json.optional<String>('percentage') ?? '0',
      isPassed: json.optional<bool>('is_passed') ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'attempt_id': attemptId,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'incorrect_answers': incorrectAnswers,
      'time_taken': timeTaken,
      'percentage': percentage,
      'is_passed': isPassed,
    };
  }
}

/// Model for quiz info (metadata about the quiz)
class QuizInfoModel extends Model {
  final int id;
  final String title;
  final String? description;
  final int duration; // in minutes
  final int totalQuestions;
  final int totalMarks;
  final int passingMarks;
  final List<QuizQuestionModel> questions;

  QuizInfoModel({
    required this.id,
    required this.title,
    this.description,
    required this.duration,
    required this.totalQuestions,
    required this.totalMarks,
    required this.passingMarks,
    required this.questions,
  });

  factory QuizInfoModel.fromJson(Map<String, dynamic> json) {
    return QuizInfoModel(
      id: json.optional<int>('id') ?? 0,
      title: json.optional<String>('title') ?? '',
      description: json.optional<String>('description'),
      duration: json.optional<int>('duration') ?? 0,
      totalQuestions: json.optional<int>('total_questions') ?? 0,
      totalMarks: json.optional<int>('total_marks') ?? 0,
      passingMarks: json.optional<int>('passing_marks') ?? 0,
      questions: json.optional<List>('questions') != null
          ? (json.optional<List>(
              'questions',
            )!).map((question) => QuizQuestionModel.fromJson(question)).toList()
          : [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'total_questions': totalQuestions,
      'total_marks': totalMarks,
      'passing_marks': passingMarks,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}
