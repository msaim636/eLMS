import 'dart:io';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/features/transaction/models/my_refund_model.dart';
import 'package:image_picker/image_picker.dart';

/// Repository for managing refund request operations
/// Follows the Repository pattern extending Blueprint base class
class RefundRepository extends Blueprint {
  /// Submits a refund request for a course
  /// [courseId] - The ID of the course to request refund for
  /// [reason] - The reason for requesting the refund
  /// [userMedia] - Optional media file to attach with the request
  /// Returns the API response
  /// Throws exception if API call fails
  Future<Map<String, dynamic>> submitRefundRequest({
    required int courseId,
    required String reason,
    XFile? userMedia,
  }) async {
    final Map<String, dynamic> data = {'course_id': courseId, 'reason': reason};

    if (userMedia != null) {
      final file = File(userMedia.path);
      final response = await Api.postMultipart(
        Apis.refundRequest,
        data: data,
        files: [file],
        fileKey: 'user_media',
        isFilesArray: false,
      );
      return response;
    } else {
      final response = await Api.post(Apis.refundRequest, data: data);
      return response;
    }
  }

  /// Fetches the list of user's refund requests with pagination
  /// [page] - The page number to fetch
  /// [perPage] - Number of items per page
  /// Returns PaginatedDataClass containing list of MyRefundModel
  /// Throws exception if API call fails
  Future<PaginatedDataClass<MyRefundModel>> fetchMyRefunds({
    int? page,
    int? perPage,
  }) async {
    final Map<String, dynamic> params = {};

    if (page != null) params['page'] = page;
    if (perPage != null) params['per_page'] = perPage;

    final response = await Api.get(Apis.myRefunds, data: params);

    return PaginatedDataClass.fromResponse(MyRefundModel.fromJson, response);
  }
}
