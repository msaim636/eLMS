import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/course/models/assignment_submission_model.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class AssignmentGroupModel extends Model {
  final List<AssignmentChapter> chapters;
  final List<AssignmentChapter> currentChapter;
  factory AssignmentGroupModel.fromJson(Map<String, dynamic> json) {
    return AssignmentGroupModel(
      chapters: (json.require<List>(
        'chapters',
      )).map((e) => AssignmentChapter.fromJson(e)).toList(),
      currentChapter: (json.require<List>(
        'current_chapter_assignments',
      )).map((e) => AssignmentChapter.fromJson(e)).toList(),
    );
  }

  AssignmentGroupModel({required this.chapters, required this.currentChapter});

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

class AssignmentModel extends Model {
  final int id;
  int courseId;
  final String title;
  final String description;
  final String instructions;
  final String points;
  final int dueDays;
  final int? maxFileSize;
  final List<String> allowedFileTypes;
  final bool canSkip;
  final bool isActive;
  final CourseInfo course;
  final String createdAt;
  final String createdAtFormatted;
  final String timeAgo;
  final List<AssignmentSubmissionModel> submissions;
  final SubmissionStats submissionStats;
  final String? media;
  final String? mediaExtension;
  final String? mediaUrl;

  AssignmentModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.instructions,
    required this.points,
    required this.dueDays,
    this.maxFileSize,
    required this.allowedFileTypes,
    required this.canSkip,
    required this.isActive,
    required this.course,
    required this.createdAt,
    required this.createdAtFormatted,
    required this.timeAgo,
    required this.submissions,
    required this.submissionStats,
    this.media,
    this.mediaExtension,
    this.mediaUrl,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    final courseInfo = CourseInfo.fromJson(
      json.optional<Map<String, dynamic>>('course') ?? {},
    );
    return AssignmentModel(
      id: json.optional<int>('id') ?? 0,
      courseId: courseInfo.id,
      title: json.optional<String>('title') ?? '',
      description: json.optional<String>('description') ?? '',
      instructions: json.optional<String>('instructions') ?? '',
      points: json.optional<String>('points') ?? '0',
      dueDays: json.optional<int>('due_days') ?? 0,
      maxFileSize: json.optional<int>('max_file_size'),
      allowedFileTypes: json.optional<List>('allowed_file_types') != null
          ? List<String>.from(json.require<List>('allowed_file_types'))
          : [],
      canSkip: json.optional<bool>('can_skip') ?? false,
      isActive: json.optional<bool>('is_active') ?? false,
      course: courseInfo,
      createdAt: json.optional<String>('created_at') ?? '',
      createdAtFormatted: json.optional<String>('created_at_formatted') ?? '',
      timeAgo: json.optional<String>('time_ago') ?? '',
      submissions: json.optional<List>('submissions') != null
          ? (json.require<List>(
              'submissions',
            )).map((s) => AssignmentSubmissionModel.fromJson(s)).toList()
          : [],
      submissionStats: SubmissionStats.fromJson(
        json.optional<Map<String, dynamic>>('submission_stats') ?? {},
      ),
      media: json.optional<String>('media'),
      mediaExtension: json.optional<String>('media_extension'),
      mediaUrl: json.optional<String>('media_url'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'instructions': instructions,
      'points': points,
      'due_days': dueDays,
      'max_file_size': maxFileSize,
      'allowed_file_types': allowedFileTypes,
      'can_skip': canSkip,
      'is_active': isActive,
      'course': course.toJson(),
      'created_at': createdAt,
      'created_at_formatted': createdAtFormatted,
      'time_ago': timeAgo,
      'submissions': submissions.map((s) => s.toJson()).toList(),
      'submission_stats': submissionStats.toJson(),
      'media': media,
      'media_extension': mediaExtension,
      'media_url': mediaUrl,
    };
  }
}

class AssignmentChapter extends Model {
  final int id;
  final String title;
  final String courseName;
  final String courseImage;
  final int courseId;

  final List<AssignmentModel> assignments;

  AssignmentChapter({
    required this.id,
    required this.title,
    required this.assignments,
    required this.courseImage,
    required this.courseName,
    required this.courseId,
  });

  factory AssignmentChapter.fromJson(Map<String, dynamic> json) {
    return AssignmentChapter(
      id: json.optional<int>('chapter_id') ?? 0,
      title: json.optional<String>('chapter_title') ?? '',
      courseImage: json.optional<String>('course_image') ?? "",
      courseName: json.optional<String>('course_name') ?? '',
      courseId: json.require<int>('course_id'),
      assignments: (json.require<List>('assignments')).map((e) {
        return AssignmentModel.fromJson(e)
          ..courseId = json.require<int>('course_id');
      }).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}

class CourseInfo extends Model {
  final int id;
  final String title;

  CourseInfo({required this.id, required this.title});

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(
      id: json.optional<int>('id') ?? 0,
      title: json.optional<String>('title') ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}

class SubmissionStats extends Model {
  final int totalSubmissions;
  final int acceptedSubmissions;
  final int rejectedSubmissions;
  final int pendingSubmissions;
  final String? latestStatus;
  final bool hasSubmissions;

  SubmissionStats({
    required this.totalSubmissions,
    required this.acceptedSubmissions,
    required this.rejectedSubmissions,
    required this.pendingSubmissions,
    this.latestStatus,
    required this.hasSubmissions,
  });

  factory SubmissionStats.fromJson(Map<String, dynamic> json) {
    return SubmissionStats(
      totalSubmissions: json.optional<int>('total_submissions') ?? 0,
      acceptedSubmissions: json.optional<int>('accepted_submissions') ?? 0,
      rejectedSubmissions: json.optional<int>('rejected_submissions') ?? 0,
      pendingSubmissions: json.optional<int>('pending_submissions') ?? 0,
      latestStatus: json.optional<String>('latest_status'),
      hasSubmissions: json.optional<bool>('has_submissions') ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'total_submissions': totalSubmissions,
      'accepted_submissions': acceptedSubmissions,
      'rejected_submissions': rejectedSubmissions,
      'pending_submissions': pendingSubmissions,
      'latest_status': latestStatus,
      'has_submissions': hasSubmissions,
    };
  }
}

///fail state
/**
 * 
 *  AssignmentSubmissionModel(
          id: 1,
          submittedFile: "https://example.com/uploads/assignment1.pdf",
          fileName: "assignment1.pdf",
          fileSize: "1.2 MB",
          fileType: "pdf",
          status: SubmissionStatus.rejected,
          statusLabel: "Rejected",
          feedback:
              "The submitted file did not meet the required formatting guidelines.",
          grade: "0",
          comment: "Please follow the assignment template and resubmit.",
          submittedAt: "2025-10-10T14:32:00Z",
          submittedAtFormatted: "October 10, 2025 at 2:32 PM",
          timeAgo: "6 days ago",
          updatedAt: "2025-10-11T10:00:00Z",
          canResubmit: true,
          canEdit: true,
          canDelete: false,
        )
 * 
 */
