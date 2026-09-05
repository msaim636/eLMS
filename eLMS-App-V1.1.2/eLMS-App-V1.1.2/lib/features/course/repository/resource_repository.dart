import 'package:elms/common/models/blueprints.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/features/course/models/resource_data_model.dart';

class ResourceRepository extends Blueprint {
  Future<CourseResourcesModel> fetchResource({
    required int id,
    required int lectureId,
  }) async {
    try {
      final response = await Api.get(
        Apis.getResources,
        data: {"id": id, "lecture_id": lectureId},
      );

      return CourseResourcesModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
