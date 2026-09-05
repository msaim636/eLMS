import 'package:elms/common/models/data_class.dart';
import 'package:elms/common/models/message_model.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class DiscussionRepository {
  Future<PaginatedDataClass<DiscussionModel>> fetch({
    required int courseId,
    int? page,
    int? perPage,
  }) async {
    return PaginatedDataClass.fromResponse(
      DiscussionModel.fromJson,
      await Api.get(
        Apis.courseDiscussion,
        data: {
          ApiParams.courseId: courseId,
          ApiParams.page: page,
          ApiParams.perPage: perPage,
        }.removeEmptyKeys(),
      ),
    );
  }

  Future<DiscussionModel> createDiscussion({
    required String text,
    required int courseId,
    int? parentDiscussionId,
  }) async {
    final response = await Api.post(
      Apis.courseDiscussion,
      data: {
        ApiParams.courseId: courseId,
        ApiParams.parentId: parentDiscussionId,
        ApiParams.message: text,
      }.removeEmptyKeys(),
    );

    return DiscussionModel.fromJson(response['data']);
  }
}
