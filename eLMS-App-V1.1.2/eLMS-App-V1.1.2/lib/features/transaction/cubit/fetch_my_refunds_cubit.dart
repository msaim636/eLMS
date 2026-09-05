import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/features/transaction/models/my_refund_model.dart';
import 'package:elms/features/transaction/repository/refund_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchMyRefundsState {}

class FetchMyRefundsInitial extends FetchMyRefundsState {}

class FetchMyRefundsProgress extends FetchMyRefundsState {}

class FetchMyRefundsSuccess extends PaginatedApiSuccessState<MyRefundModel>
    implements FetchMyRefundsState {
  FetchMyRefundsSuccess({
    required super.total,
    required super.data,
    required super.isLoadingMore,
    required super.hasLoadingMoreError,
    required super.currentPage,
    required super.totalPage,
  });

  @override
  FetchMyRefundsSuccess copyWith({
    int? total,
    List<MyRefundModel>? data,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasLoadingMoreError,
    int? currentPage,
    int? totalPage,
  }) {
    return FetchMyRefundsSuccess(
      total: total ?? this.total,
      data: data ?? this.data,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadingMoreError: hasLoadingMoreError ?? this.hasLoadingMoreError,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
    );
  }
}

base class FetchMyRefundsError extends ErrorState
    implements FetchMyRefundsState {
  FetchMyRefundsError({required super.error});
}

class FetchMyRefundsCubit extends Cubit<FetchMyRefundsState>
    with PaginationCapability<FetchMyRefundsState, MyRefundModel> {
  final RefundRepository _repository;

  FetchMyRefundsCubit(this._repository) : super(FetchMyRefundsInitial());

  @override
  Future<void> fetch() async {
    try {
      // Call super to handle pagination logic
      await super.fetch();

      // Emit progress state only for initial fetch
      if (currentPage == 1) {
        emit(FetchMyRefundsProgress());
      }

      final PaginatedDataClass<MyRefundModel> result = await _repository
          .fetchMyRefunds(page: currentPage);

      // Update data using pagination capability
      data = result.data;

      emit(
        FetchMyRefundsSuccess(
          total: result.total,
          data: data,
          isLoadingMore: false,
          hasLoadingMoreError: false,
          currentPage: result.currentPage,
          totalPage: result.totalPage,
        ),
      );
    } catch (e) {
      if (state is FetchMyRefundsSuccess && currentPage > 1) {
        // If error during pagination, update the success state
        final successState = state as FetchMyRefundsSuccess;
        emit(
          successState.copyWith(
            isLoadingMore: false,
            hasLoadingMoreError: true,
          ),
        );
      } else {
        emit(FetchMyRefundsError(error: e));
      }
    }
  }
}
