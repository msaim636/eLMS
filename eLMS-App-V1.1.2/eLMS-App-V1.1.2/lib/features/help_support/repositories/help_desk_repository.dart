import 'package:elms/common/models/data_class.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/features/help_support/models/discussion_group.dart';
import 'package:elms/features/help_support/models/discussion_question_model.dart';
import 'package:elms/features/help_support/models/faq_model.dart';
import 'package:elms/features/help_support/models/group_approval_status_model.dart';

class HelpDeskRepository {
  Future<DataClass<HelpDeskDiscussionGroupModel>> fetchGroups({
    String? search,
  }) async {
    try {
      final Map<String, dynamic> params = {};

      if (search != null && search.isNotEmpty) {
        params[ApiParams.search] = search;
      }

      final response = await Api.get(Apis.discussionGroups, data: params);
      return DataClass.fromResponse(
        HelpDeskDiscussionGroupModel.fromJson,
        response,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<PaginatedDataClass<DiscussionQuestionModel>> fetchQuestions({
    required int groupId,
    int? page,
    int? perPage,
  }) async {
    try {
      final Map<String, dynamic> params = {ApiParams.groupId: groupId};

      if (page != null) {
        params[ApiParams.page] = page;
      }
      if (perPage != null) {
        params[ApiParams.perPage] = perPage;
      }

      final response = await Api.get(Apis.discussionQuestions, data: params);
      return PaginatedDataClass.fromResponse(
        DiscussionQuestionModel.fromJson,
        response,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestPrivateGroup({
    required int groupId,
  }) async {
    try {
      final Map<String, dynamic> params = {ApiParams.groupId: groupId};

      final response = await Api.post(Apis.requestPrivateGroup, data: params);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<GroupApprovalStatusModel> checkGroupApproval({
    required String groupSlug,
  }) async {
    try {
      final Map<String, dynamic> params = {ApiParams.groupSlug: groupSlug};

      final response = await Api.get(Apis.checkGroupApproval, data: params);
      return GroupApprovalStatusModel.fromJson(response[ApiParams.data] ?? {});
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchQuestionDetails({
    required int questionId,
    int? page,
    int? perPage,
  }) async {
    try {
      final Map<String, dynamic> params = {ApiParams.questionId: questionId};

      if (page != null) {
        params[ApiParams.page] = page;
      }
      if (perPage != null) {
        params[ApiParams.perPage] = perPage;
      }

      final response = await Api.get(Apis.helpDeskQuestion, data: params);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> replyQuestion({
    required int id,
    required String reply,
  }) async {
    try {
      final response = await Api.post(
        Apis.helpDeskQuestionReply,
        data: {'question_id': id, 'reply': reply},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<PaginatedDataClass<Faq>> fetchFaqs({int? page, int? perPage}) async {
    try {
      final Map<String, dynamic> params = {};

      if (page != null) {
        params[ApiParams.page] = page;
      }
      if (perPage != null) {
        params[ApiParams.perPage] = perPage;
      }

      final response = await Api.get(Apis.faqs, data: params);
      return PaginatedDataClass.fromResponse(Faq.fromJson, response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> askQuestion({
    required int groupId,
    required String title,
    required String description,
  }) async {
    try {
      final response = await Api.post(
        Apis.askQuestion,
        data: {
          ApiParams.groupId: groupId,
          'title': title,
          'description': description,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
