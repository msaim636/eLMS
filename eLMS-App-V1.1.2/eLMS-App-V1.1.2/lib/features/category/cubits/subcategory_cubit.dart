import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/category_model.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/features/category/repositories/category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubcategoryCubit extends Cubit<SubcategoryState> {
  final CategoryRepository _repository;

  SubcategoryCubit(this._repository) : super(SubcategoryInitial());

  Future<void> fetchSubcategories(int parentCategoryId) async {
    emit(SubcategoryProgress());

    try {
      final result = await _repository.fetch(id: parentCategoryId.toString());

      // The API returns the parent category with subcategories array nested within it
      // We need to extract the subcategories from the parent category
      List<CategoryModel> subcategories = [];
      if (result.data.isNotEmpty) {
        final parentCategory = result.data.first;
        if (parentCategory.subcategories != null) {
          subcategories = parentCategory.subcategories!;
        }
      }

      emit(SubcategorySuccess(data: subcategories));
    } catch (e) {
      if (e is CustomException) {
        emit(SubcategoryError(error: e));
      } else {
        emit(SubcategoryError(error: AppException.from(e as Exception)));
      }
    }
  }
}

abstract base class SubcategoryState extends BaseState {}

final class SubcategoryInitial extends SubcategoryState {}

final class SubcategoryProgress extends ProgressState
    implements SubcategoryState {}

final class SubcategorySuccess extends SubcategoryState {
  final List<CategoryModel> data;

  SubcategorySuccess({required this.data});
}

base class SubcategoryError extends ErrorState<CustomException>
    implements SubcategoryState {
  SubcategoryError({required super.error});
}
