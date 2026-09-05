import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class GroupApprovalStatusModel extends Model {
  final GroupBasicInfo group;
  final bool isApproved;
  final String? userRequestStatus;
  final bool canPostQuestions;

  GroupApprovalStatusModel({
    required this.group,
    required this.isApproved,
    this.userRequestStatus,
    required this.canPostQuestions,
  });

  factory GroupApprovalStatusModel.fromJson(Map<String, dynamic> json) {
    return GroupApprovalStatusModel(
      group: GroupBasicInfo.fromJson(
        json.optional<Map<String, dynamic>>('group') ?? {},
      ),
      isApproved: json.optional<bool>('is_approved') ?? false,
      userRequestStatus: json.optional<String>('user_request_status'),
      canPostQuestions: json.optional<bool>('can_post_questions') ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'group': group.toJson(),
      'is_approved': isApproved,
      'user_request_status': userRequestStatus,
      'can_post_questions': canPostQuestions,
    };
  }

  /// Check if user has already sent a request (pending status)
  bool get hasPendingRequest => userRequestStatus == 'pending';

  /// Check if user's request was rejected
  bool get wasRejected => userRequestStatus == 'rejected';

  /// Check if user can send a new request
  bool get canSendRequest =>
      !isApproved && userRequestStatus == null && !hasPendingRequest;
}

class GroupBasicInfo extends Model {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String? image;
  final int isPrivate;
  final int isActive;

  GroupBasicInfo({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.image,
    required this.isPrivate,
    required this.isActive,
  });

  factory GroupBasicInfo.fromJson(Map<String, dynamic> json) {
    return GroupBasicInfo(
      id: json.optional<int>('id') ?? 0,
      name: json.optional<String>('name') ?? '',
      slug: json.optional<String>('slug') ?? '',
      description: json.optional<String>('description') ?? '',
      image: json.optional<String>('image'),
      isPrivate: json.optional<int>('is_private') ?? 0,
      isActive: json.optional<int>('is_active') ?? 1,
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
      'is_active': isActive,
    };
  }

  bool get isPrivateGroup => isPrivate == 1;
  bool get isActiveGroup => isActive == 1;
}
