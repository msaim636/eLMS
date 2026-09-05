import 'package:elms/utils/extensions/data_type_extensions.dart';

class DiscussionMessage {
  final String id;
  final String topicId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;
  final DateTime createdAt;
  final List<DiscussionMessage>? replies;
  final int likeCount;
  final bool isLiked;

  DiscussionMessage({
    required this.id,
    required this.topicId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    required this.createdAt,
    this.replies,
    this.likeCount = 0,
    this.isLiked = false,
  });

  factory DiscussionMessage.fromJson(Map<String, dynamic> json) {
    return DiscussionMessage(
      id: json.require<String>('id'),
      topicId: json.require<String>('topicId'),
      userId: json.require<String>('userId'),
      userName: json.require<String>('userName'),
      userAvatarUrl: json.optional<String>('userAvatarUrl'),
      content: json.require<String>('content'),
      createdAt: DateTime.parse(json.require<String>('createdAt')),
      replies: json.optional<List>('replies') != null
          ? (json.optional<List>(
              'replies',
            )!).map((e) => DiscussionMessage.fromJson(e)).toList()
          : null,
      likeCount: json.optional<int>('likeCount') ?? 0,
      isLiked: json.optional<bool>('isLiked') ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicId': topicId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'replies': replies?.map((e) => e.toJson()).toList(),
      'likeCount': likeCount,
      'isLiked': isLiked,
    };
  }
}
