import 'package:elms/core/api/api_params.dart';
import 'package:elms/common/models/category_model.dart';

/// Abstract base class that defines the common structure for different types of course lists.
/// This class serves as a contract for all course list implementations, ensuring they have
/// consistent properties and behavior.
abstract class CourseListType {
  /// Whether to display filters in the course list UI
  bool showFilters;

  /// The title to be displayed at the top of the course list screen
  String screenTitle;

  CourseListType({this.showFilters = true, required this.screenTitle});

  /// Converts the course list data to a format suitable for API requests
  /// @return A map containing the API parameters
  Map<String, dynamic> toApiValues();
}

/// Represents a basic course list without any specific filtering or categorization.
/// This is the simplest implementation of CourseListType.
class CourseList extends CourseListType {
  final String? featureSectionType;

  CourseList({required super.screenTitle, this.featureSectionType});

  @override
  Map<String, dynamic> toApiValues() {
    return featureSectionType != null
        ? {'feature_section': featureSectionType}
        : {};
  }
}

/// Represents a course list filtered by a specific category and its subcategories.
/// This implementation includes category-specific filtering and subcategory information.
class CourseListForCategory extends CourseListType {
  /// The ID of the main category to filter courses by
  final CategoryModel category;

  CourseListForCategory({required this.category, required super.screenTitle});

  @override
  Map<String, dynamic> toApiValues() {
    return {ApiParams.categoryId: category.id};
  }
}

/// Represents a course list filtered by search query.
/// This implementation is used when users search for courses using keywords.
class CourseListForSearch extends CourseListType {
  /// The search query string used to filter courses
  final String searchQuery;

  CourseListForSearch({required this.searchQuery, String? screenTitle})
    : super(screenTitle: screenTitle ?? searchQuery, showFilters: true);

  @override
  Map<String, dynamic> toApiValues() {
    return {ApiParams.search: searchQuery};
  }
}
