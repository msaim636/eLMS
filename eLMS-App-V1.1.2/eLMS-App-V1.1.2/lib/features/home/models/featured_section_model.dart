import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/models/instructor_model.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class FeaturedSectionModel extends Model {
  final int id;
  final String title;
  final String type;
  final List<Model?> data;

  FeaturedSectionModel({
    required this.id,
    required this.title,
    required this.type,
    required this.data,
  });

  static final Map<Model Function(Map<String, dynamic> json), List<String>>
  modelBindings = {
    CourseModel.fromJson: [
      "my_learning",
      'newly_added_courses',
      "most_viewed_courses",
      'free_courses',
      "top_rated_courses",
      "most_viewed_courses",
      "searching_based",
      'recommend_for_you',
      'wishlist',
    ],
    InstructorModel.fromMap: ['top_rated_instructors'],
  };

  factory FeaturedSectionModel.fromJson(Map<String, dynamic> json) {
    return FeaturedSectionModel(
      id: json.require<int>('id'),
      title: json.optional<String>('title') ?? '',
      type: json.require<String>('type'),
      data: (json.optional('data') is Map)
          ? []
          : (json.require<List<dynamic>>('data')).map((e) {
              return _buildData(e, json.require<String>('type'));
            }).toList(),
    );
  }
  static Model? _buildData(Map<String, dynamic> model, String type) {
    final MapEntry<Model Function(Map<String, dynamic> json), List<String>>?
    entry = modelBindings.entries
        .where(
          (MapEntry<Function, List<String>> entry) =>
              entry.value.contains(type),
        )
        .firstOrNull;

    return entry?.key(model);
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    // 'data': data.map((e) => e.toJson()).toList(),
  };
}
