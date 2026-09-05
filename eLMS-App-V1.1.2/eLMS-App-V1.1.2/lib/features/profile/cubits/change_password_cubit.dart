import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChangePasswordState {}

class ChangePasswordInitial extends ChangePasswordState {}

class ChangePasswordInProgress extends ChangePasswordState {}

class ChangePasswordSuccess extends ChangePasswordState {}

final class ChangePasswordFail extends ErrorState
    implements ChangePasswordState {
  ChangePasswordFail({required super.error});
}

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final AuthRepository _repository;
  ChangePasswordCubit(this._repository) : super(ChangePasswordInitial());

  void changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      emit(ChangePasswordInProgress());
      await _repository.changePassword(
        currentPassword: currentPassword,
        confirmPassword: confirmPassword,
        newPassword: newPassword,
      );
      emit(ChangePasswordSuccess());
    } catch (e) {
      emit(ChangePasswordFail(error: e));
    }
  }
}
