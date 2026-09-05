import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class CategoryModel extends Model {
  final int id;
  final String name;
  final String image;
  final int? parentCategoryId;
  final String? description;
  final bool status;
  final String slug;
  final int subcategoriesCount;
  final int parentCategoryCount;
  final bool hasSubcategory;
  final bool hasParentCategory;
  final int courseCount;
  final List<CategoryModel>? subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.parentCategoryId,
    required this.description,
    required this.status,
    required this.slug,
    required this.subcategoriesCount,
    required this.parentCategoryCount,
    required this.hasSubcategory,
    required this.hasParentCategory,
    required this.courseCount,
    this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    List<CategoryModel>? subcategories;

    subcategories = (json.optional<List>('subcategories'))
        ?.map((subcatJson) => CategoryModel.fromJson(
            Map<String, dynamic>.from(subcatJson as Map)))
        .toList();

    return CategoryModel(
      id: json.require<int>('id'),
      name: json.require<String>('name'),
      image: json.require<String?>('image') ?? '',
      parentCategoryId: json.optional<int>('parent_category_id'),
      description: json.optional<String>('description'),
      status: json.require<bool>('status'),
      slug: json.require<String>('slug'),
      subcategoriesCount: json.optional<int>('subcategories_count') ?? 0,
      parentCategoryCount: json.optional<int>('parent_category_count') ?? 0,
      hasSubcategory: json.require<bool>('has_subcategory'),
      hasParentCategory: json.require<bool>('has_parent_category'),
      courseCount: json.optional<int>('courses_count') ?? 0,
      subcategories: subcategories,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'parent_category_id': parentCategoryId,
    'description': description,
    'status': status,
    'slug': slug,
    'subcategories_count': subcategoriesCount,
    'parent_category_count': parentCategoryCount,
    'has_subcategory': hasSubcategory,
    'has_parent_category': hasParentCategory,
    'courses_count': courseCount,
    'subcategories': subcategories?.map((e) => e.toJson()).toList(),
  };
}
