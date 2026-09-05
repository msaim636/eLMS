import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/course/models/assignment_model.dart';
import 'package:elms/features/course/repository/assignment_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssignmentCubit extends Cubit<AssignmentState> {
  final AssignmentRepository _repository;

  AssignmentCubit(this._repository) : super(AssignmentInitial());

  Future<void> fetchAssignments(int courseId, {int? chapterId}) async {
    try {
      emit(AssignmentProgress());
      final AssignmentGroupModel result = await _repository
          .fetchAssignmentSubmissionHistory(
            courseId: courseId,
            chapterId: chapterId,
          );
      emit(AssignmentSuccess(data: result));
    } catch (e) {
      emit(AssignmentError(error: e.toString()));
    }
  }

  Future<void> submitAssignment({
    required int assignmentId,
    required List<String> files,
    required String comment,
  }) async {
    try {
      emit(AssignmentSubmissionProgress());
      final Map<dynamic, dynamic> result = await _repository.submitAssignment(
        assignmentId: assignmentId,
        files: files,
        comment: comment,
      );
      emit(
        AssignmentSubmissionSuccess(
          message: result['message'] ?? 'Assignment submitted successfully',
        ),
      );
    } catch (e) {
      emit(AssignmentSubmissionError(error: e.toString()));
    }
  }

  Future<void> updateAssignment({
    required int submissionId,
    required List<String> files,
    required String comment,
  }) async {
    try {
      emit(AssignmentSubmissionProgress());
      final Map<dynamic, dynamic> result = await _repository.updateSubmission(
        submissionId: submissionId,
        files: files,
        comment: comment,
      );
      emit(
        AssignmentSubmissionSuccess(
          message: result['message'] ?? 'Assignment updated successfully',
        ),
      );
    } catch (e) {
      emit(AssignmentSubmissionError(error: e.toString()));
    }
  }

  void reset() {
    emit(AssignmentInitial());
  }
}

abstract base class AssignmentState extends BaseState {}

final class AssignmentInitial extends AssignmentState {}

final class AssignmentProgress extends ProgressState
    implements AssignmentState {}

final class AssignmentSuccess extends BaseState implements AssignmentState {
  final AssignmentGroupModel data;

  AssignmentSuccess({required this.data});
}

final class AssignmentError extends ErrorState<String>
    implements AssignmentState {
  AssignmentError({required super.error});
}

final class AssignmentSubmissionProgress extends ProgressState
    implements AssignmentState {}

final class AssignmentSubmissionSuccess extends BaseState
    implements AssignmentState {
  final String message;

  AssignmentSubmissionSuccess({required this.message});
}

final class AssignmentSubmissionError extends ErrorState<String>
    implements AssignmentState {
  AssignmentSubmissionError({required super.error});
}
