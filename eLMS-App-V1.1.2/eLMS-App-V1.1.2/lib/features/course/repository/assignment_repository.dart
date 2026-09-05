import 'dart:io';

import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/features/course/models/assignment_model.dart';

class AssignmentRepository {
  Future<AssignmentGroupModel> fetchAssignmentSubmissionHistory({
    required int courseId,
    int? chapterId,
  }) async {
    try {
      final Map<String, dynamic> parameters = {ApiParams.courseId: courseId};
      if (chapterId != null) {
        parameters[ApiParams.chapterId] = chapterId;
      }

      final Map<String, dynamic> response = await Api.get(
        Apis.getAssignments,
        data: parameters,
      );

      return AssignmentGroupModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>> submitAssignment({
    required int assignmentId,
    required List<String> files,
    required String comment,
  }) async {
    try {
      final Map<String, dynamic> response = await Api.postMultipart(
        Apis.submitAssignment,
        data: {'assignment_id': assignmentId.toString(), 'comment': comment},
        files: files.map((path) => File(path)).toList(),
        fileKey: 'files',
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>> updateSubmission({
    required int submissionId,
    required List<String> files,
    required String comment,
  }) async {
    try {
      final Map<String, dynamic> response = await Api.postMultipart(
        Apis.updateAssignmentSubmission,
        data: {'id': submissionId.toString(), 'comment': comment},
        files: files.map((path) => File(path)).toList(),
        fileKey: 'files',
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>> resubmitAssignment({
    required int assignmentId,
    required List<String> files,
    required String comment,
  }) async {
    return await submitAssignment(
      assignmentId: assignmentId,
      files: files,
      comment: comment,
    );
  }
}
