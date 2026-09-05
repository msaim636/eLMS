import 'package:elms/core/error_management/exceptions.dart';

abstract class PaginatedApiState {}

class PaginatedApiInitialState extends PaginatedApiState {}

class PaginatedApiLoadingState extends PaginatedApiState {}

class PaginatedApiSuccessState<T> extends PaginatedApiState {
  final int totalPages;
  final List<T> data;
  final int currentPage;

  PaginatedApiSuccessState({
    required this.data,
    required this.totalPages,
    required this.currentPage,
  });
}

class PaginatedApiLoadingMore<T> extends PaginatedApiSuccessState<T> {
  PaginatedApiLoadingMore({
    required super.data,
    required super.totalPages,
    required super.currentPage,
  });
}

class PaginatedApiLoadingMoreError<T> extends PaginatedApiSuccessState<T> {
  PaginatedApiLoadingMoreError({
    required super.data,
    required super.totalPages,
    required super.currentPage,
    required this.exception,
  });
  final CustomException exception;
}

class PaginatedApiFailureState extends PaginatedApiState {
  final CustomException exception;

  PaginatedApiFailureState({required this.exception});
}
