import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/help_support/models/discussion_topic.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class QuestionAuthor {
  final int id;
  final String name;
  final String? avatar;

  QuestionAuthor({required this.id, required this.name, this.avatar});

  factory QuestionAuthor.fromJson(Map<String, dynamic> json) {
    return QuestionAuthor(
      id: json.optional<int>('id') ?? 0,
      name: json.optional<String>('name') ?? '',
      avatar: json.optional<String>('avatar'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'avatar': avatar};
  }
}

class QuestionGroup {
  final int id;
  final String name;
  final String slug;

  QuestionGroup({required this.id, required this.name, required this.slug});

  factory QuestionGroup.fromJson(Map<String, dynamic> json) {
    return QuestionGroup(
      id: json.optional<int>('id') ?? 0,
      name: json.optional<String>('name') ?? '',
      slug: json.optional<String>('slug') ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug};
  }
}

class DiscussionQuestionModel extends Model {
  final int id;
  final String slug;
  final String title;
  final String description;
  final int isPrivate;
  final DateTime createdAt;
  final String createdAtFormatted;
  final String timeAgo;
  final DateTime updatedAt;
  final QuestionAuthor author;
  final QuestionGroup group;
  final int repliesCount;
  final int viewsCount;

  DiscussionQuestionModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.isPrivate,
    required this.createdAt,
    required this.createdAtFormatted,
    required this.timeAgo,
    required this.updatedAt,
    required this.author,
    required this.group,
    required this.repliesCount,
    required this.viewsCount,
  });

  factory DiscussionQuestionModel.fromJson(Map<String, dynamic> json) {
    return DiscussionQuestionModel(
      id: json.optional<int>('id') ?? 0,
      slug: json.optional<String>('slug') ?? '',
      title: json.optional<String>('title') ?? '',
      description: json.optional<String>('description') ?? '',
      isPrivate: json.optional<int>('is_private') ?? 0,
      createdAt:
          DateTime.tryParse(json.optional<String>('created_at') ?? '') ??
          DateTime.now(),
      createdAtFormatted: json.optional<String>('created_at_formatted') ?? '',
      timeAgo: json.optional<String>('time_ago') ?? '',
      updatedAt:
          DateTime.tryParse(json.optional<String>('updated_at') ?? '') ??
          DateTime.now(),
      author: QuestionAuthor.fromJson(
        json.optional<Map<String, dynamic>>('author') ?? {},
      ),
      group: QuestionGroup.fromJson(
        json.optional<Map<String, dynamic>>('group') ?? {},
      ),
      repliesCount: json.optional<int>('replies_count') ?? 0,
      viewsCount: json.optional<int>('views_count') ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'description': description,
      'is_private': isPrivate,
      'created_at': createdAt.toIso8601String(),
      'created_at_formatted': createdAtFormatted,
      'time_ago': timeAgo,
      'updated_at': updatedAt.toIso8601String(),
      'author': author.toJson(),
      'group': group.toJson(),
      'replies_count': repliesCount,
      'views_count': viewsCount,
    };
  }

  // Helper getter to check privacy
  GroupPrivacy get privacy =>
      isPrivate == 1 ? GroupPrivacy.private : GroupPrivacy.public;

  // Helper getter for private status
  bool get isPrivateQuestion => isPrivate == 1;
}
