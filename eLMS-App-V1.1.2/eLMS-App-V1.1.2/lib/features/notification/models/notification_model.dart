import 'package:elms/utils/extensions/data_type_extensions.dart';

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String notificationType;
  final int typeId;
  final String? typeLink;
  final String? slug;
  final String? image;
  final DateTime dateSent;
  final String dateSentFormatted;
  final String timeAgo;
  final bool isRead;
  final String? readAt;
  final InstructorDetailsModel? instructorDetails;
  final TeamMemberModel? teamMembers;
  final String? invitationStatus;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.typeId,
    this.typeLink,
    this.slug,
    this.image,
    required this.dateSent,
    required this.dateSentFormatted,
    required this.timeAgo,
    required this.isRead,
    this.readAt,
    this.instructorDetails,
    this.teamMembers,
    this.invitationStatus,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json.require<String>('id'),
      type: json.require<String>('type'),
      title: json.require<String>('title'),
      message: json.require<String>('message'),
      notificationType: json.require<String>('notification_type'),
      typeId: json.optional<int>('type_id') ?? 0,
      typeLink: json.optional<String>('type_link'),
      slug: json.optional<String>('slug'),
      image: json.optional<String>('image'),
      dateSent: DateTime.parse(json.require<String>('date_sent')),
      dateSentFormatted: json.require<String>('date_sent_formatted'),
      timeAgo: json.require<String>('time_ago'),
      isRead: json.optional<bool>('is_read') ?? false,
      readAt: json.optional<String>('read_at'),
      instructorDetails:
          json.optional<Map<String, dynamic>>('instructor_details') != null
          ? InstructorDetailsModel.fromJson(
              json.require<Map<String, dynamic>>('instructor_details'),
            )
          : null,
      teamMembers: json['team_members'] is Map<String, dynamic>
          ? TeamMemberModel.fromJson(
              json['team_members'] as Map<String, dynamic>,
            )
          : null,
      invitationStatus: json.optional<String>('invitation_status'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'type_id': typeId,
      'type_link': typeLink,
      'slug': slug,
      'image': image,
      'date_sent': dateSent.toIso8601String(),
      'date_sent_formatted': dateSentFormatted,
      'time_ago': timeAgo,
      'is_read': isRead,
      'read_at': readAt,
      'instructor_details': instructorDetails?.toJson(),
      'team_members': teamMembers?.toJson(),
      'invitation_status': invitationStatus,
    };
  }
}

class InstructorDetailsModel {
  final int id;
  final int userId;
  final String name;
  final String slug;
  final String profile;

  InstructorDetailsModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.slug,
    required this.profile,
  });

  factory InstructorDetailsModel.fromJson(Map<String, dynamic> json) {
    return InstructorDetailsModel(
      id: json.require<int>('id'),
      userId: json.require<int>('user_id'),
      name: json.require<String>('name'),
      slug: json.require<String>('slug'),
      profile: json.optional<String>('profile') ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'slug': slug,
      'profile': profile,
    };
  }
}

class TeamMemberModel {
  final int id;
  final int instructorId;
  final int userId;
  final String status;
  final String? invitationToken;
  final String createdAt;
  final String updatedAt;

  TeamMemberModel({
    required this.id,
    required this.instructorId,
    required this.userId,
    required this.status,
    required this.invitationToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json.require<int>('id'),
      instructorId: json.require<int>('instructor_id'),
      userId: json.require<int>('user_id'),
      status: json.require<String>('status'),
      invitationToken: json.optional<String>('invitation_token'),
      createdAt: json.require<String>('created_at'),
      updatedAt: json.require<String>('updated_at'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instructor_id': instructorId,
      'user_id': userId,
      'status': status,
      'invitation_token': invitationToken,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
