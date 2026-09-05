import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/features/course/features/quiz/models/quiz_api_models.dart';

class QuizRepository {
  /// Fetches quiz details with questions
  Future<QuizInfoModel> getQuizDetails({
    required int courseChapterQuizId,
  }) async {
    try {
      final Map<String, dynamic> params = {
        ApiParams.courseChapterQuizId: courseChapterQuizId,
      };

      final response = await Api.get(Apis.getQuizDetails, data: params);

      if (response[ApiParams.data] != null) {
        return QuizInfoModel.fromJson(
          response[ApiParams.data] as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to get quiz details');
    } catch (e) {
      rethrow;
    }
  }

  /// Starts a new quiz attempt
  /// Returns the quiz attempt data with attempt ID
  Future<QuizAttemptModel> startQuiz({required int courseChapterQuizId}) async {
    try {
      final Map<String, dynamic> params = {
        ApiParams.courseChapterQuizId: courseChapterQuizId,
      };

      final response = await Api.post(Apis.quizStart, data: params);

      if (response[ApiParams.data] != null) {
        return QuizAttemptModel.fromJson(
          response[ApiParams.data] as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to start quiz');
    } catch (e) {
      rethrow;
    }
  }

  /// Submits an answer for a quiz question
  /// Returns the submitted answer data
  Future<QuizAnswerModel> submitAnswer({
    required int quizQuestionId,
    required int quizOptionId,
    required int attemptId,
  }) async {
    try {
      final Map<String, dynamic> params = {
        ApiParams.quizQuestionId: quizQuestionId,
        ApiParams.quizOptionId: quizOptionId,
        ApiParams.attemptId: attemptId,
      };

      final response = await Api.post(Apis.quizAnswer, data: params);

      if (response[ApiParams.data] != null) {
        return QuizAnswerModel.fromJson(
          response[ApiParams.data] as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to submit answer');
    } catch (e) {
      rethrow;
    }
  }

  /// Finishes the quiz attempt and returns basic completion data
  Future<QuizFinishResponseModel> finishQuiz({required int attemptId}) async {
    try {
      final Map<String, dynamic> params = {ApiParams.attemptId: attemptId};

      final response = await Api.post(Apis.quizFinish, data: params);

      if (response[ApiParams.data] != null) {
        return QuizFinishResponseModel.fromJson(
          response[ApiParams.data] as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to finish quiz');
    } catch (e) {
      rethrow;
    }
  }
}
