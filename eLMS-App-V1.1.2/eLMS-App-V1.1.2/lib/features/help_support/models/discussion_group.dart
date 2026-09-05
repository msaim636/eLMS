import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class HelpDeskDiscussionGroupModel extends Model {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String? image;
  final int isPrivate;
  final int rowOrder;
  final int isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  HelpDeskDiscussionGroupModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.image,
    required this.isPrivate,
    required this.rowOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HelpDeskDiscussionGroupModel.fromJson(Map<String, dynamic> json) {
    return HelpDeskDiscussionGroupModel(
      id: json.optional<int>('id') ?? 0,
      name: json.optional<String>('name') ?? '',
      slug: json.optional<String>('slug') ?? '',
      description: json.optional<String>('description') ?? '',
      image: json.optional<String>('image'),
      isPrivate: json.optional<int>('is_private') ?? 0,
      rowOrder: json.optional<int>('row_order') ?? 0,
      isActive: json.optional<int>('is_active') ?? 1,
      createdAt:
          DateTime.tryParse(json.optional<String>('created_at') ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json.optional<String>('updated_at') ?? '') ??
          DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image': image,
      'is_private': isPrivate,
      'row_order': rowOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getter to check if group is private
  bool get isPrivateGroup => isPrivate == 1;

  // Helper getter to check if group is active
  bool get isActiveGroup => isActive == 1;
}
