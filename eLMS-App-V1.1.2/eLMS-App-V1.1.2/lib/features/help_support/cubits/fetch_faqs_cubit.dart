import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/features/help_support/models/faq_model.dart';
import 'package:elms/features/help_support/repositories/help_desk_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchFaqsState {}

class FetchFaqsInitial extends FetchFaqsState {}

class FetchFaqsProgress extends FetchFaqsState {}

class FetchFaqsSuccess extends PaginatedApiSuccessState<Faq>
    implements FetchFaqsState {
  FetchFaqsSuccess({
    required super.total,
    required super.data,
    required super.isLoadingMore,
    required super.hasLoadingMoreError,
    required super.currentPage,
    required super.totalPage,
  });

  @override
  FetchFaqsSuccess copyWith({
    int? total,
    List<Faq>? data,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasLoadingMoreError,
    int? currentPage,
    int? totalPage,
  }) {
    return FetchFaqsSuccess(
      total: total ?? this.total,
      data: data ?? this.data,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadingMoreError: hasLoadingMoreError ?? this.hasLoadingMoreError,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
    );
  }
}

base class FetchFaqsError extends ErrorState implements FetchFaqsState {
  FetchFaqsError({required super.error});
}

class FetchFaqsCubit extends Cubit<FetchFaqsState>
    with PaginationCapability<FetchFaqsState, Faq> {
  final HelpDeskRepository _repository;

  FetchFaqsCubit(this._repository) : super(FetchFaqsInitial());

  @override
  Future<void> fetch() async {
    try {
      // Call super to handle pagination logic
      await super.fetch();

      // Emit progress state only for initial fetch
      if (currentPage == 1) {
        emit(FetchFaqsProgress());
      }

      final PaginatedDataClass<Faq> result = await _repository.fetchFaqs(
        page: currentPage,
      );

      // Update data using pagination capability
      data = result.data;

      emit(
        FetchFaqsSuccess(
          total: result.total,
          data: data,
          isLoadingMore: false,
          hasLoadingMoreError: false,
          currentPage: result.currentPage,
          totalPage: result.totalPage,
        ),
      );
    } catch (e) {
      if (state is FetchFaqsSuccess && currentPage > 1) {
        // If error during pagination, update the success state
        final successState = state as FetchFaqsSuccess;
        emit(
          successState.copyWith(
            isLoadingMore: false,
            hasLoadingMoreError: true,
          ),
        );
      } else {
        emit(FetchFaqsError(error: e));
      }
    }
  }
}
