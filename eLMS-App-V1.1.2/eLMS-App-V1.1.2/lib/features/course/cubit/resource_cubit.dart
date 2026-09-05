import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/course/models/resource_data_model.dart';
import 'package:elms/features/course/repository/resource_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Cubit
class ResourceCubit extends Cubit<ResourceState> {
  final ResourceRepository _repository;

  ResourceCubit(this._repository) : super(ResourceInitial());

  Future<void> fetchResources({required int courseId, required int lectureId}) async {
    try {
      emit(ResourceProgress());

      final resourceData = await _repository.fetchResource(id: courseId, lectureId: lectureId);

      emit(ResourceSuccess(data: resourceData));
    } catch (e) {
      emit(ResourceError(error: e.toString()));
    }
  }

  void reset() {
    emit(ResourceInitial());
  }
}

// States
abstract base class ResourceState extends BaseState {}

final class ResourceInitial extends ResourceState {}

final class ResourceProgress extends ProgressState implements ResourceState {}

final class ResourceSuccess extends BaseState implements ResourceState {
  final CourseResourcesModel data;

  ResourceSuccess({required this.data});
}

final class ResourceError extends ErrorState<String> implements ResourceState {
  ResourceError({required super.error});
}
