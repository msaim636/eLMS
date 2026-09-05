import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';

class WishlistRepository {
  Future<PaginatedDataClass<CourseModel>> getWishlistItems({
    required int page,
  }) async {
    final Map<String, dynamic> response = await Api.get(
      Apis.getWishlist,
      data: {ApiParams.page: page},
    );
    return PaginatedDataClass.fromResponse(CourseModel.fromJson, response);
  }

  Future<Map<String, dynamic>> toggleWishlist({
    required int courseId,
    required int status, // 0 for remove, 1 for add
  }) async {
    final Map response = await Api.post(
      Apis.wishlist,
      data: {ApiParams.courseId: courseId, 'status': status},
    );

    return response as Map<String, dynamic>;
  }
}
