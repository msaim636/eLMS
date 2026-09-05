import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ResetPasswordState {}

class ResetPasswordInitial extends ResetPasswordState {}

class ResetPasswordInProgress extends ResetPasswordState {}

class ResetPasswordSuccess extends ResetPasswordState {}

final class ResetPasswordFailed extends ErrorState
    implements ResetPasswordState {
  ResetPasswordFailed({required super.error});
}

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepository _authRepository;
  ResetPasswordCubit(this._authRepository) : super(ResetPasswordInitial());

  void reset({
    required String password,
    required String confirmPassword,
    required String firebaseToken,
  }) async {
    try {
      emit(ResetPasswordInProgress());
      await _authRepository.resetPassword(
        confirmPassword: confirmPassword,
        firebaseToken: firebaseToken,
        password: password,
      );
      emit(ResetPasswordSuccess());
    } catch (e) {
      emit(ResetPasswordFailed(error: e));
    }
  }
}
