import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/category_model.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/features/category/repositories/category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchCategoryState implements BaseState {}

class FetchCategoryInitial extends FetchCategoryState {}

base class FetchCategoryInProgress extends ProgressState
    implements FetchCategoryState {}

final class FetchCategorySuccess extends PaginatedApiSuccessState<CategoryModel>
    implements FetchCategoryState {
  FetchCategorySuccess({
    required super.total,
    required super.data,
    required super.isLoadingMore,
    required super.hasLoadingMoreError,
    required super.currentPage,
    required super.totalPage,
  });

  @override
  PaginatedApiSuccessState<CategoryModel> copyWith({
    List<CategoryModel>? data,
    int? total,
    bool? hasMore,
    bool? hasLoadingMoreError,
    bool? isLoadingMore,
    int? currentPage,
    int? totalPage,
  }) {
    return FetchCategorySuccess(
      total: total ?? this.total,
      data: data ?? this.data,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadingMoreError: hasLoadingMoreError ?? this.hasLoadingMoreError,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
    );
  }
}

final class FetchCategoryFail<T> extends ErrorState<T>
    implements FetchCategoryState {
  FetchCategoryFail({required super.error});
}

class FetchCategoryCubit extends Cubit<FetchCategoryState>
    with PaginationCapability<FetchCategoryState, CategoryModel> {
  final CategoryRepository _repository;
  final bool isTree;
  FetchCategoryCubit(this._repository, {this.isTree = false}) : super(FetchCategoryInitial()) {
    fetch();
  }

  @override
  Future<void> fetch() async {
    await super.fetch();
    try {
      if (isForceFetch()) emit(FetchCategoryInProgress());
      final PaginatedDataClass<CategoryModel> result = await _repository.fetch(
        page: currentPage,
        isTree: isTree,
      );

      data = result.data;

      emit(
        FetchCategorySuccess(
          total: result.total,
          data: data,
          currentPage: result.currentPage,
          totalPage: result.totalPage,
          isLoadingMore: false,
          hasLoadingMoreError: false,
        ),
      );
    } catch (e) {
      emit(FetchCategoryFail(error: e));
    }
  }
}
