import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class CourseLanguageModel extends Model {
  final int id;
  final String name;
  final String slug;
  final int isActive;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  CourseLanguageModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory CourseLanguageModel.fromJson(Map<String, dynamic> json) {
    return CourseLanguageModel(
      id: json.require<int>('id'),
      name: json.require<String>('name'),
      slug: json.require<String>('slug'),
      isActive: json.require<int>('is_active'),
      createdAt: json.require<String>('created_at'),
      updatedAt: json.require<String>('updated_at'),
      deletedAt: json.optional<String?>('deleted_at'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'is_active': isActive,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
  };
}
