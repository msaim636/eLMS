import 'package:elms/common/cubits/paginated_api_cubit.dart';
import 'package:elms/common/models/category_model.dart';
import 'package:elms/common/models/instructor_model.dart';
import 'package:elms/core/api/api_lists.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/course/models/filter.dart';
import 'package:elms/features/course/screens/filter_screen.dart';

class ExploreInstructorsCubit extends PaginatedApiCubit<InstructorModel> {
  String _searchQuery = '';

  List<Filter> instructorFilters = [
    CategoryFilter(
      titleKey: AppLabels.categories,
      apiKey: ApiParams.categoryId,
      categories: [],
      selectedValues: [],
    ),
    RatingFilter(
      titleKey: AppLabels.rating,
      apiKey: 'rating',
      values: [
        FilterValue(titleKey: '5', apiValue: '5'),
        FilterValue(titleKey: '4', apiValue: '4'),
        FilterValue(titleKey: '3', apiValue: '3'),
        FilterValue(titleKey: '2', apiValue: '2'),
        FilterValue(titleKey: '1', apiValue: '1'),
      ],
      selectedValues: [],
    ),
  ];

  void search(String query) {
    _searchQuery = query;
    fetchData();
  }

  void applyFilters(List<Filter> filters) {
    instructorFilters = filters;
    fetchData();
  }

  void updateCategoryValues(List<CategoryModel> categories) {
    final categoryFilter = instructorFilters.firstWhere(
      (f) => f.apiKey == ApiParams.categoryId,
    );
    if (categoryFilter is CategoryFilter) {
      categoryFilter.updateCategories(categories);
    }
  }

  @override
  String get apiUrl => Apis.getInstructors;

  @override
  InstructorModel Function(Map<String, dynamic>) get fromJson =>
      InstructorModel.fromMap;

  @override
  bool get useAuthToken => false;

  @override
  Map<String, dynamic>? get extraParams {
    final Map<String, dynamic> params = {};
    if (_searchQuery.isNotEmpty) {
      params[ApiParams.search] = _searchQuery;
    }
    for (final filter in instructorFilters) {
      if (filter.selectedValues.isNotEmpty) {
        params[filter.apiKey] = filter.selectedValues
            .map((e) => e.apiValue)
            .join(',');
      }
    }
    return params.isNotEmpty ? params : null;
  }
}
