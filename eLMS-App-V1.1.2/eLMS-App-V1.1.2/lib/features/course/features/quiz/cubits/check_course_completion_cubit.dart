import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/course/models/course_completion_model.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckCourseCompletionStatusState {}

class CheckCourseCompletionStatusInitial
    extends CheckCourseCompletionStatusState {}

class CheckCourseCompletionStatusInProgress
    extends CheckCourseCompletionStatusState {}

class CheckCourseCompletionStatusSuccess
    extends CheckCourseCompletionStatusState {
  final CourseCompletionData data;
  CheckCourseCompletionStatusSuccess(this.data);
}

final class CheckCourseCompletionStatusFail extends ErrorState
    implements CheckCourseCompletionStatusState {
  CheckCourseCompletionStatusFail({required super.error});
}

class CheckCourseCompletionCubit
    extends Cubit<CheckCourseCompletionStatusState> {
  CheckCourseCompletionCubit(this._repository)
    : super(CheckCourseCompletionStatusInitial());
  final CourseRepository _repository;
  Future<void> check(int courseId) async {
    try {
      emit(CheckCourseCompletionStatusInProgress());
      final CourseCompletionData courseCompletionData = await _repository
          .checkCourseStatus(courseId);
      emit(CheckCourseCompletionStatusSuccess(courseCompletionData));
    } catch (e) {
      emit(CheckCourseCompletionStatusFail(error: e));
    }
  }
}
