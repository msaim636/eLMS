import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/help_support/repositories/help_desk_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class RequestPrivateGroupState {}

class RequestPrivateGroupInitial extends RequestPrivateGroupState {}

class RequestPrivateGroupProgress extends RequestPrivateGroupState {}

class RequestPrivateGroupSuccess extends SuccessDataState<Map<String, dynamic>>
    implements RequestPrivateGroupState {
  RequestPrivateGroupSuccess({required super.data});
}

base class RequestPrivateGroupError extends ErrorState
    implements RequestPrivateGroupState {
  RequestPrivateGroupError({required super.error});
}

class RequestPrivateGroupCubit extends Cubit<RequestPrivateGroupState> {
  final HelpDeskRepository _repository;

  RequestPrivateGroupCubit(this._repository)
    : super(RequestPrivateGroupInitial());

  Future<void> requestAccess({required int groupId}) async {
    try {
      emit(RequestPrivateGroupProgress());

      final Map<String, dynamic> result = await _repository.requestPrivateGroup(
        groupId: groupId,
      );

      emit(RequestPrivateGroupSuccess(data: result));
    } catch (e) {
      emit(RequestPrivateGroupError(error: e));
    }
  }
}
