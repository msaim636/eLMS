import 'package:elms/common/enums.dart';
import 'package:elms/core/api/api_client.dart';

class ReviewRepository {
  Future<Map<dynamic, dynamic>> addReview({
    required ReviewType type,
    required int id,
    required int rating,
    required String review,
  }) async {
    final Map<String, dynamic> params = {'rating': rating, 'review': review};

    if (type == ReviewType.course) {
      params['course_id'] = id;
    } else {
      params['instructor_id'] = id;
    }

    final Map response = await Api.post(Apis.addReview, data: params);
    return response;
  }

  Future<Map<dynamic, dynamic>> deleteReview({required int ratingId}) async {
    final Map<String, dynamic> params = {'rating_id': ratingId};

    final Map response = await Api.delete(Apis.deleteReview, data: params);
    return response;
  }
}
