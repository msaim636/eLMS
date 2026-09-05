// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class SearchSuggestionItemModel extends Model {
  final String? type;
  final String? text;
  final String? slug;
  final String? icon;
  final String? authorName;
  final String? courseImage;
  final int? courseId;

  SearchSuggestionItemModel({
    this.type,
    this.text,
    this.slug,
    this.icon,
    this.authorName,
    this.courseImage,
    this.courseId,
  });

  factory SearchSuggestionItemModel.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionItemModel(
      type: json.optional<String>('type'),
      text: json.optional<String>('text'),
      slug: json.optional<String>('slug'),
      icon: json.optional<String>('icon'),
      authorName: json.optional<String>('author_name'),
      courseImage: json.optional<String>('course_image'),
      courseId: json.optional<int>('course_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (text != null) 'text': text,
      if (slug != null) 'slug': slug,
      if (icon != null) 'icon': icon,
      if (authorName != null) 'author_name': authorName,
      if (courseImage != null) 'course_image': courseImage,
      if (courseId != null) 'course_id': courseId,
    };
  }
}

class SearchSuggestionDataModel extends Model {
  final List<SearchSuggestionItemModel> topCourses;
  final List<SearchSuggestionItemModel> otherSuggestions;
  final int totalCourses;
  final int totalOther;
  final String query;

  SearchSuggestionDataModel({
    required this.topCourses,
    required this.otherSuggestions,
    required this.totalCourses,
    required this.totalOther,
    required this.query,
  });

  factory SearchSuggestionDataModel.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionDataModel(
      topCourses:
          (json.optional<List>('top_courses'))
              ?.map((item) => SearchSuggestionItemModel.fromJson(item))
              .toList() ??
          [],
      otherSuggestions:
          (json.optional<List>('other_suggestions'))
              ?.map((item) => SearchSuggestionItemModel.fromJson(item))
              .toList() ??
          [],
      totalCourses: json.optional<int>('total_courses') ?? 0,
      totalOther: json.optional<int>('total_other') ?? 0,
      query: json.optional<String>('query') ?? '',
    );
  }

  List<SearchSuggestionItemModel> get allSuggestions {
    return [...topCourses, ...otherSuggestions];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'top_courses': topCourses.map((item) => item.toJson()).toList(),
      'other_suggestions': otherSuggestions
          .map((item) => item.toJson())
          .toList(),
      'total_courses': totalCourses,
      'total_other': totalOther,
      'query': query,
    };
  }
}
