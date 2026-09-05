import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteAccountState extends BaseState {}

class DeleteAccountInitial extends DeleteAccountState {}

class DeleteAccountInProgress extends ProgressState
    implements DeleteAccountState {}

class DeleteAccountSuccess extends BaseState implements DeleteAccountState {}

final class DeleteAccountFailed extends ErrorState
    implements DeleteAccountState {
  DeleteAccountFailed({required super.error});
}

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final AuthRepository _authRepository;

  DeleteAccountCubit(this._authRepository) : super(DeleteAccountInitial());

  Future<void> deleteAccount({required String firebaseToken}) async {
    try {
      emit(DeleteAccountInProgress());

      await _authRepository.deleteAccount(firebaseToken: firebaseToken);

      emit(DeleteAccountSuccess());
    } catch (e) {
      emit(DeleteAccountFailed(error: e));
    }
  }
}
