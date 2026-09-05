import 'package:elms/features/help_support/models/discussion_message.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

enum GroupPrivacy { public, private }

class DiscussionTopic {
  final String id;
  final String title;
  final String description;
  final String? iconUrl;
  final String groupId;
  final GroupPrivacy privacy;
  final DateTime createdAt;
  final int messageCount;
  final List<DiscussionMessage>? messages;
  final bool isPinned;
  final int viewCount;

  DiscussionTopic({
    required this.id,
    required this.title,
    required this.description,
    this.iconUrl,
    required this.groupId,
    this.privacy = GroupPrivacy.public,
    required this.createdAt,
    this.messageCount = 0,
    this.messages,
    this.isPinned = false,
    this.viewCount = 0,
  });

  factory DiscussionTopic.fromJson(Map<String, dynamic> json) {
    return DiscussionTopic(
      id: json.require<String>('id'),
      title: json.require<String>('title'),
      description: json.require<String>('description'),
      iconUrl: json.optional<String>('iconUrl'),
      groupId: json.require<String>('groupId'),
      privacy: json.optional<String>('privacy') == 'private'
          ? GroupPrivacy.private
          : GroupPrivacy.public,
      createdAt: DateTime.parse(json.require<String>('createdAt')),
      messageCount: json.optional<int>('messageCount') ?? 0,
      messages: json.optional<List>('messages') != null
          ? (json.optional<List>(
              'messages',
            )!).map((e) => DiscussionMessage.fromJson(e)).toList()
          : null,
      isPinned: json.optional<bool>('isPinned') ?? false,
      viewCount: json.optional<int>('viewCount') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'groupId': groupId,
      'privacy': privacy == GroupPrivacy.private ? 'private' : 'public',
      'createdAt': createdAt.toIso8601String(),
      'messageCount': messageCount,
      'messages': messages?.map((e) => e.toJson()).toList(),
      'isPinned': isPinned,
      'viewCount': viewCount,
    };
  }
}
