import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/transaction/repositories/transaction_history_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DownloadInvoiceCubit extends Cubit<DownloadInvoiceState> {
  final TransactionHistoryRepository _repository;

  DownloadInvoiceCubit(this._repository) : super(DownloadInvoiceInitial());

  Future<void> downloadInvoice({required int orderId}) async {
    try {
      emit(DownloadInvoiceProgress());
      final String filePath = await _repository.downloadInvoice(
        orderId: orderId,
      );
      emit(DownloadInvoiceSuccess(filePath: filePath));
    } catch (e) {
      emit(DownloadInvoiceError(error: e.toString()));
    }
  }

  void reset() {
    emit(DownloadInvoiceInitial());
  }
}

abstract base class DownloadInvoiceState extends BaseState {}

final class DownloadInvoiceInitial extends DownloadInvoiceState {}

final class DownloadInvoiceProgress extends ProgressState
    implements DownloadInvoiceState {}

final class DownloadInvoiceSuccess extends BaseState
    implements DownloadInvoiceState {
  final String filePath;

  DownloadInvoiceSuccess({required this.filePath});
}

final class DownloadInvoiceError extends ErrorState<String>
    implements DownloadInvoiceState {
  DownloadInvoiceError({required super.error});
}
