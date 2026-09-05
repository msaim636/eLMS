import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/wallet/models/withdrawal_request_model.dart';
import 'package:elms/features/wallet/repository/wallet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class WithdrawalState {}

class WithdrawalInitial extends WithdrawalState {}

class WithdrawalInProgress extends WithdrawalState {}

class WithdrawalSuccess extends WithdrawalState {
  final Map<String, dynamic> response;
  WithdrawalSuccess({required this.response});
}

final class WithdrawalFail extends ErrorState implements WithdrawalState {
  WithdrawalFail({required super.error});
}

class WithdrawalCubit extends Cubit<WithdrawalState> {
  final WalletRepository _walletRepository;

  WithdrawalCubit(this._walletRepository) : super(WithdrawalInitial());

  Future<void> submitWithdrawalRequest({
    required num amount,
    required String accountHolderName,
    required String accountNumber,
    required String bankName,
    required String otherDetails,
  }) async {
    try {
      emit(WithdrawalInProgress());

      final WithdrawalRequestModel request =
          WithdrawalRequestModel.bankTransfer(
            amount: amount,
            accountHolderName: accountHolderName,
            accountNumber: accountNumber,
            bankName: bankName,
            otherDetails: otherDetails,
          );

      final Map<String, dynamic> response = await _walletRepository
          .submitWithdrawalRequest(request: request);

      emit(WithdrawalSuccess(response: response));
    } catch (e) {
      emit(WithdrawalFail(error: e));
    }
  }

  void reset() {
    emit(WithdrawalInitial());
  }
}
