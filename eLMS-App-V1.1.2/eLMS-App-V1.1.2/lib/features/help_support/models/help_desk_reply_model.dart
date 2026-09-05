import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class ReplyAuthor {
  final int id;
  final String name;
  final String? avatar;

  ReplyAuthor({required this.id, required this.name, this.avatar});

  factory ReplyAuthor.fromJson(Map<String, dynamic> json) {
    return ReplyAuthor(
      id: json.optional<int>('id') ?? 0,
      name: json.optional<String>('name') ?? '',
      avatar: json.optional<String>('avatar'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'avatar': avatar};
  }
}

class HelpDeskReplyModel extends Model {
  final int id;
  final String reply;
  final DateTime createdAt;
  final String timeAgo;
  final ReplyAuthor author;
  final List<HelpDeskReplyModel> children;

  HelpDeskReplyModel({
    required this.id,
    required this.reply,
    required this.createdAt,
    required this.timeAgo,
    required this.author,
    this.children = const [],
  });

  factory HelpDeskReplyModel.fromJson(Map<String, dynamic> json) {
    return HelpDeskReplyModel(
      id: json.optional<int>('id') ?? 0,
      reply: json.optional<String>('reply') ?? '',
      createdAt:
          DateTime.tryParse(json.optional<String>('created_at') ?? '') ??
          DateTime.now(),
      timeAgo: json.optional<String>('time_ago') ?? '',
      author: ReplyAuthor.fromJson(
        json.optional<Map<String, dynamic>>('author') ?? {},
      ),
      children:
          (json.optional<List<dynamic>>('children'))
              ?.map(
                (child) =>
                    HelpDeskReplyModel.fromJson(child as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reply': reply,
      'created_at': createdAt.toIso8601String(),
      'time_ago': timeAgo,
      'author': author.toJson(),
      'children': children.map((child) => child.toJson()).toList(),
    };
  }
}
