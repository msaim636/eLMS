import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/features/course/features/quiz/models/quiz_summary_model.dart';

class QuizSummaryRepository {
  Future<QuizSummaryModel> fetchQuizSummary({
    required int courseChapterQuizId,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'course_chapter_quiz_id': courseChapterQuizId,
      };

      final response = await Api.get(Apis.quizSummary, data: params);

      if (response[ApiParams.data] != null) {
        return QuizSummaryModel.fromJson(
          response[ApiParams.data] as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to fetch quiz summary');
    } catch (e) {
      rethrow;
    }
  }
}
