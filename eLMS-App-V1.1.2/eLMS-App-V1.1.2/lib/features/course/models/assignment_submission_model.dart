import 'package:elms/common/enums.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
class AssignmentSubmissionModel extends Model {
  final int id;
  final String? submittedFile;
  final String? fileName;
  final int? fileSize;
  final String? fileType;
  final SubmissionStatus status;
  final String statusLabel;
  final String? feedback;
  final String? grade;
  final String? comment;
  final String submittedAt;
  final String submittedAtFormatted;
  final String timeAgo;
  final String updatedAt;
  final bool canResubmit;
  final bool canEdit;
  final bool canDelete;

  AssignmentSubmissionModel({
    required this.id,
    this.submittedFile,
    this.fileName,
    this.fileSize,
    this.fileType,
    required this.status,
    required this.statusLabel,
    this.feedback,
    this.grade,
    this.comment,
    required this.submittedAt,
    required this.submittedAtFormatted,
    required this.timeAgo,
    required this.updatedAt,
    required this.canResubmit,
    required this.canEdit,
    required this.canDelete,
  });

  AssignmentSubmissionModel.fromJson(Map<String, dynamic> json)
    : id = json.require<int>('id'),
      submittedFile = json.optional<String>('submitted_file'),
      fileName = json.optional<String>('file_name'),
      fileSize = json.optional<int>('file_size'),
      fileType = json.optional<String>('file_type'),
      status = _parseStatus(json.require<String>('status')),
      statusLabel = json.require<String>('status_label'),
      feedback = json.optional<String>('feedback'),
      grade = json.optional<String>('grade'),
      comment = json.optional<String>('comment'),
      submittedAt = json.require<String>('submitted_at'),
      submittedAtFormatted = json.require<String>('submitted_at_formatted'),
      timeAgo = json.require<String>('time_ago'),
      updatedAt = json.require<String>('updated_at'),
      canResubmit = json.optional<bool>('can_resubmit') ?? false,
      canEdit = json.optional<bool>('can_edit') ?? false,
      canDelete = json.optional<bool>('can_delete') ?? false;

  static SubmissionStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return SubmissionStatus.submitted;
      case 'in_review':
      case 'inreview':
      case 'pending':
        return SubmissionStatus.inReview;
      case 'accepted':
      case 'approved':
        return SubmissionStatus.accepted;
      case 'rejected':
      case 'failed':
        return SubmissionStatus.rejected;
      case 'suspended':
        return SubmissionStatus.suspended;
      default:
        return SubmissionStatus.submitted;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'submitted_file': submittedFile,
      'file_name': fileName,
      'file_size': fileSize,
      'file_type': fileType,
      'status': status.name,
      'status_label': statusLabel,
      'feedback': feedback,
      'grade': grade,
      'comment': comment,
      'submitted_at': submittedAt,
      'submitted_at_formatted': submittedAtFormatted,
      'time_ago': timeAgo,
      'updated_at': updatedAt,
      'can_resubmit': canResubmit,
      'can_edit': canEdit,
      'can_delete': canDelete,
    };
  }
}
