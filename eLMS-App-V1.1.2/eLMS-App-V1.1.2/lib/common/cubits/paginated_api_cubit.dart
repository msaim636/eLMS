import 'package:elms/common/cubits/paginated_api_states.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/common/repositories/common_api_repsitory.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PaginatedApiCubit<T> extends Cubit<PaginatedApiState> {
  PaginatedApiCubit() : super(PaginatedApiInitialState());

  String get apiUrl;
  T Function(Map<String, dynamic>) get fromJson;

  Map<String, dynamic>? get extraParams => null;

  bool get useAuthToken => false;

  Future<void> fetchData() async {
    try {
      emit(PaginatedApiLoadingState());
      final PaginatedDataClass data =
          await CommonApiRepository.fetchPaginatedData<T>(
            apiUrl: apiUrl,
            fromJson: fromJson,
            extraParams: extraParams,
            hasAuthToken: useAuthToken,
            page: 1,
          );

      emit(
        PaginatedApiSuccessState<T>(
          data: data.data as List<T>,
          totalPages: data.totalPage,
          currentPage: 1,
        ),
      );
    } catch (e) {
      if (e case final CustomException exception) {
        emit(PaginatedApiFailureState(exception: exception));
      } else {
        emit(
          PaginatedApiFailureState(
            exception: AppException.from(e as Exception),
          ),
        );
      }
    }
  }

  Future<void> fetchMoreData() async {
    final PaginatedApiSuccessState<T> currentState =
        state as PaginatedApiSuccessState<T>;

    final List<T> allData = List.from(currentState.data);

    try {
      if (currentState is PaginatedApiLoadingMore) {
        return;
      }

      // Check if there are more pages to load
      if (currentState.currentPage >= currentState.totalPages) {
        return;
      }

      final int nextPage = currentState.currentPage + 1;

      emit(
        PaginatedApiLoadingMore(
          data: allData,
          totalPages: currentState.totalPages,
          currentPage: currentState.currentPage,
        ),
      );

      final PaginatedDataClass result =
          await CommonApiRepository.fetchPaginatedData<T>(
            apiUrl: apiUrl,
            fromJson: fromJson,
            extraParams: extraParams,
            page: nextPage,
            hasAuthToken: useAuthToken,
          );

      allData.addAll(result.data as List<T>);

      emit(
        PaginatedApiSuccessState<T>(
          data: allData,
          totalPages: result.totalPage,
          currentPage: nextPage,
        ),
      );
    } catch (error) {
      emit(
        PaginatedApiLoadingMoreError(
          exception: error as AppException,
          data: allData,
          totalPages: currentState.totalPages,
          currentPage: currentState.currentPage,
        ),
      );
    }
  }

  bool get hasMore {
    if (state is PaginatedApiSuccessState) {
      final successState = state as PaginatedApiSuccessState;
      return successState.currentPage < successState.totalPages;
    }
    return false;
  }

  Future<void> setAllData(List<T> data) async {
    emit(PaginatedApiSuccessState(data: data, totalPages: 1, currentPage: 1));
  }
}
