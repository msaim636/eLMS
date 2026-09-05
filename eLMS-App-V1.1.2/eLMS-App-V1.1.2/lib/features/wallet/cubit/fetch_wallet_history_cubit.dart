import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/features/wallet/models/wallet_transaction_model.dart';
import 'package:elms/features/wallet/repository/wallet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchWalletHistoryState {}

class FetchWalletHistoryInitial extends FetchWalletHistoryState {}

class FetchWalletHistoryProgress extends FetchWalletHistoryState {}

class FetchWalletHistorySuccess
    extends PaginatedApiSuccessState<WalletTransactionModel>
    implements FetchWalletHistoryState {
  final bool isWalletRequestPending;
  FetchWalletHistorySuccess({
    required super.total,
    required super.data,
    required super.isLoadingMore,
    required super.hasLoadingMoreError,
    required super.currentPage,
    required super.totalPage,
    required this.isWalletRequestPending,
  });

  @override
  FetchWalletHistorySuccess copyWith({
    int? total,
    List<WalletTransactionModel>? data,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasLoadingMoreError,
    int? currentPage,
    int? totalPage,
    bool? isWalletRequestPending,
  }) {
    return FetchWalletHistorySuccess(
      total: total ?? this.total,
      data: data ?? this.data,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadingMoreError: hasLoadingMoreError ?? this.hasLoadingMoreError,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
      isWalletRequestPending:
          isWalletRequestPending ?? this.isWalletRequestPending,
    );
  }
}

base class FetchWalletHistoryError extends ErrorState
    implements FetchWalletHistoryState {
  FetchWalletHistoryError({required super.error});
}

class FetchWalletHistoryCubit extends Cubit<FetchWalletHistoryState>
    with PaginationCapability<FetchWalletHistoryState, WalletTransactionModel> {
  final WalletRepository _repository;
  String filterType = 'received';

  FetchWalletHistoryCubit(this._repository)
    : super(FetchWalletHistoryInitial());

  void setFilter(String type) {
    if (filterType == type) return;
    filterType = type;
    emit(FetchWalletHistoryProgress());
    fetch();
  }

  @override
  Future<void> fetch() async {
    try {
      // Call super to handle pagination logic
      await super.fetch();

      // Emit progress state only for initial fetch
      if (currentPage == 1 && state is! FetchWalletHistoryProgress) {
        emit(FetchWalletHistoryProgress());
      }

      final PaginatedDataClass<WalletTransactionModel> result =
          await _repository.fetchWalletHistory(
            page: currentPage, 
            filterType: filterType,
          );

      // Update data using pagination capability
      data = result.data;

      emit(
        FetchWalletHistorySuccess(
          total: result.total,
          data: data,
          isLoadingMore: false,
          hasLoadingMoreError: false,
          currentPage: result.currentPage,
          totalPage: result.totalPage,
          isWalletRequestPending:
              (result.extraData as Map)['hasWithdrawalRequestPending'],
        ),
      );
    } catch (e) {
      if (state is FetchWalletHistorySuccess && currentPage > 1) {
        // If error during pagination, update the success state
        final successState = state as FetchWalletHistorySuccess;
        emit(
          successState.copyWith(
            isLoadingMore: false,
            hasLoadingMoreError: true,
          ),
        );
      } else {
        emit(FetchWalletHistoryError(error: e));
      }
    }
  }
}
