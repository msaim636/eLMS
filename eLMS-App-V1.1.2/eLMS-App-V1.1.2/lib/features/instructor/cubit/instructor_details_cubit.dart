import 'package:elms/common/models/blueprints.dart';

import 'package:elms/features/instructor/models/instructor_details_model.dart';
import 'package:elms/features/instructor/repository/instructor_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InstructorDetailsCubit extends Cubit<BaseState> {
  InstructorDetailsCubit() : super(InitialState());
  final InstructorRepository _repository = InstructorRepository();

  Future<void> fetchInstructorDetails({
    required String id,
    bool skipProgress = false,
  }) async {
    if (!skipProgress) {
      emit(ProgressState());
    }
    try {
      final InstructorDetailsModel instructorDetailsModel = await _repository
          .fetchInstructorDetails(id: id);
      emit(
        SuccessDataState<InstructorDetailsModel>(data: instructorDetailsModel),
      );
    } catch (e) {
      emit(ErrorState(error: e));
    }
  }
}
