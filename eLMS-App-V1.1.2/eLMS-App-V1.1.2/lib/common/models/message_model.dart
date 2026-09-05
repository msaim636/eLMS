import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

abstract class MessageModel extends Model {
  final String id;
  final String userName;
  final String userSubtitle;
  final String content;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;
  final String type;
  final String profile;
  final String timesAgo;

  MessageModel({
    required this.id,
    required this.userName,
    required this.userSubtitle,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    required this.type,
    required this.profile,
    required this.timesAgo,
  });
}

class Message extends MessageModel {
  Message({
    required super.id,
    required super.content,
    required super.senderId,
    required super.receiverId,
    required super.timestamp,
    required super.type,
    required super.userName,
    required super.userSubtitle,
    required super.profile,
    required super.timesAgo,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json.require<int>('id').toString(),
      content:
          json.require<String?>('message') ??
          json.require<String?>('reply') ??
          '',
      senderId: json.require<int>('user_id').toString(),
      receiverId: json.optional<int>('parent_id')?.toString() ?? '',
      timestamp: DateTime.parse(json.require<String>('created_at')),
      type: 'reply',
      userName: json.require<Map<String, dynamic>>('user')['name'],
      userSubtitle: 'Student',
      profile: json.require<Map<String, dynamic>>('user')['profile'] ?? '',
      timesAgo: json.require<String>('time_ago'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'type': type,
      'userName': userName,
    };
  }
}

class DiscussionModel extends MessageModel {
  final List<Message> replies;
  DiscussionModel({
    required super.id,
    required super.content,
    required super.senderId,
    required super.receiverId,
    required super.timestamp,
    required super.type,
    required super.profile,
    required super.userName,
    required super.userSubtitle,
    required super.timesAgo,
    required this.replies,
  });

  factory DiscussionModel.fromJson(Map<String, dynamic> json) {
    return DiscussionModel(
      id: json.require<int>('id').toString(),
      content: json.require<String>('message'),
      senderId: json.require<int>('user_id').toString(),
      receiverId: json.require<int>('course_id').toString(),
      timestamp: DateTime.parse(json.require<String>('created_at')),
      type: 'discussion',
      userName: json.require<Map<String, dynamic>>('user')['name'],
      userSubtitle: 'Student',
      profile: json.require<Map<String, dynamic>>('user')['profile'] ?? '',
      timesAgo: json.require<String>('time_ago'),
      replies:
          json.optional<List>('replies')?.map((reply) {
            return Message.fromJson(reply as Map<String, dynamic>);
          }).toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'type': type,
      'userName': userName,
    };
  }
}
