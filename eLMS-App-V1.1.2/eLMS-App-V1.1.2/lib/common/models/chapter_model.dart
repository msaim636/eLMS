import 'package:elms/common/enums.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class ChapterModel extends Model {
  final int id;
  final int? courseId;
  final String title;
  final String? slug;
  final String? description;
  final bool? isActive;
  final int? chapterOrder;
  final ChapterType? chapterType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final int totalContent;
  final int lecturesCount;
  final int assignmentsCount;
  final int quizzesCount;
  final int? documentsCount;
  final bool? locked;
  final List<CurriculumModel> curriculum;

  ChapterModel({
    required this.id,
    this.courseId,
    required this.title,
    this.slug,
    this.description,
    this.isActive,
    this.chapterOrder,
    this.chapterType,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.totalContent,
    required this.lecturesCount,
    required this.assignmentsCount,
    required this.quizzesCount,
    this.documentsCount,
    this.locked,
    required this.curriculum,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json.require<int>('id'),
      courseId: json.optional<int>('course_id'),
      title: json.require<String>('title'),
      slug: json.optional<String?>('slug'),
      description: json.optional<String?>('description'),
      isActive: json.optional<bool?>('is_active'),
      chapterOrder: json.optional<int?>('chapter_order'),
      chapterType: json.optional<String?>('chapter_type') != null
          ? _parseChapterType(json.optional<String>('chapter_type')!)
          : null,
      createdAt: json.optional<String?>('created_at') != null
          ? DateTime.parse(json.optional<String>('created_at')!)
          : null,
      updatedAt: json.optional<String?>('updated_at') != null
          ? DateTime.parse(json.optional<String>('updated_at')!)
          : null,
      deletedAt: json.optional<String?>('deleted_at') != null
          ? DateTime.parse(json.optional<String>('deleted_at')!)
          : null,
      totalContent: json.optional<int?>('total_content') ?? 0,
      lecturesCount: json.optional<int?>('lectures_count') ?? 0,
      assignmentsCount: json.optional<int?>('assignments_count') ?? 0,
      quizzesCount: json.optional<int?>('quizzes_count') ?? 0,
      documentsCount: json.optional<int?>('documents_count'),
      locked: json.optional<bool?>('locked'),
      curriculum: json.optional<List<dynamic>?>('curriculum') != null
          ? List<CurriculumModel>.from(
              (json.optional<List>('curriculum')!).map(
                (x) => CurriculumModel.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  static ChapterType _parseChapterType(String? type) {
    switch (type?.toLowerCase()) {
      case 'video':
        return ChapterType.video;
      case 'quiz':
        return ChapterType.quiz;
      case 'resource':
        return ChapterType.resource;
      default:
        return ChapterType.video;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'slug': slug,
      'description': description,
      'is_active': isActive,
      'chapter_order': chapterOrder,
      'chapter_type': chapterType?.name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'total_content': totalContent,
      'lectures_count': lecturesCount,
      'assignments_count': assignmentsCount,
      'quizzes_count': quizzesCount,
      'documents_count': documentsCount,
      'locked': locked,
      'curriculum': curriculum.map((x) => x.toJson()).toList(),
    };
  }
}

class ResourceModel extends Model {
  final int id;
  final String title;
  final String type; // e.g., 'url', 'file'
  final String? file;
  final String? fileExtension;
  final String? url;
  final int order;
  final bool isActive;

  ResourceModel({
    required this.id,
    required this.title,
    required this.type,
    this.file,
    this.fileExtension,
    this.url,
    required this.order,
    required this.isActive,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json.require<int>('id'),
      title: json.require<String>('title'),
      type: json.require<String>('type'),
      file: json.optional<String?>('file'),
      fileExtension: json.optional<String?>('file_extension'),
      url: json.optional<String?>('url'),
      order: json.require<int>('order'),
      isActive: json.require<bool>('is_active'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'file': file,
      'file_extension': fileExtension,
      'url': url,
      'order': order,
      'is_active': isActive,
    };
  }
}

class CurriculumModel extends Model {
  final int id;
  final String title;
  final String slug;
  final String? description;
  final String? type;
  final String? lectureType; // maps JSON lecture_type
  final String? file;
  final String? fileType;
  final String? fileUrl;

  final int? hours;
  final int? minutes;
  final int? seconds;
  final bool freePreview;
  final bool isActive;
  final int? chapterOrder;
  final bool hasResources;
  final List<ResourceModel> resources;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Question>? questions;
  final int? totalPoints;
  final int? passingScore;
  final bool? canSkip;

  CurriculumModel({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.type,
    required this.lectureType,
    this.file,
    this.fileType,
    this.fileUrl,
    this.hours,
    this.minutes,
    this.seconds,
    required this.freePreview,
    required this.isActive,
    this.chapterOrder,
    required this.hasResources,
    required this.resources,
    this.createdAt,
    this.updatedAt,
    required this.isCompleted,
    this.questions,
    this.totalPoints,
    this.passingScore,
    this.canSkip,
  });

  factory CurriculumModel.fromJson(Map<String, dynamic> json) {
    return CurriculumModel(
      id: json.require<int>('id'),
      title: json.require<String>('title'),
      slug: json.require<String>('slug'),
      canSkip: json.optional<bool?>('can_skip'),

      description: json.optional<String?>('description'),
      type: json.optional<String?>('type'),
      lectureType: json.optional<String?>('lecture_type'),
      file: json.optional<String?>('file'),

      fileType: json.optional<String?>('file_type'),
      fileUrl: json.optional<String?>('file_url'),
      hours: json.optional<int?>('hours'),
      minutes: json.optional<int?>('minutes'),
      seconds: json.optional<int?>('seconds'),
      freePreview: json['free_preview'] is bool
          ? json['free_preview']
          : json.optional<int?>('free_preview') == 1,
      isActive: json.require<bool>('is_active'),
      chapterOrder: json.optional<int?>('chapter_order'),
      hasResources: json.require<bool?>('has_resources') ?? false,
      resources: json.optional<List<dynamic>?>('resources') != null
          ? List<ResourceModel>.from(
              (json.optional<List>(
                'resources',
              )!).map((x) => ResourceModel.fromJson(x as Map<String, dynamic>)),
            )
          : [],
      createdAt: json.optional<String?>('created_at') != null
          ? DateTime.parse(json.optional<String>('created_at')!)
          : null,
      updatedAt: json.optional<String?>('updated_at') != null
          ? DateTime.parse(json.optional<String>('updated_at')!)
          : null,
      isCompleted: json.require<bool>('is_completed'),
      questions: json
          .optional<List>('questions')
          ?.map((e) => Question.fromJson(e))
          .toList(),
      totalPoints: json.optional<int?>('total_points'),
      passingScore: json.optional<int?>('passing_score'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'type': type,
      'lecture_type': lectureType,
      'file': file,
      'file_type': fileType,
      'file_url': fileUrl,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'free_preview': freePreview ? 1 : 0,
      'is_active': isActive,
      'chapter_order': chapterOrder,
      'has_resources': hasResources,
      'resources': resources.map((x) => x.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_completed': isCompleted,
      'questions': questions?.map((e) => e.toJson()).toList(),
      'total_points': totalPoints,
      'passing_score': passingScore,
    };
  }
}

class Question {
  final int id;
  final String question;
  final num points;
  final int order;
  final bool isActive;
  final List<Option> options;

  Question({
    required this.id,
    required this.question,
    required this.points,
    required this.order,
    required this.isActive,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json.require<int>('id'),
      question: json.require<String>('question'),
      points: num.parse(json.require('points').toString()),
      order: json.require<int>('order'),
      isActive: json.require<bool>('is_active'),
      options: (json.require<List<dynamic>>(
        'options',
      )).map((e) => Option.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'points': points.toStringAsFixed(2),
      'order': order,
      'is_active': isActive,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

class Option {
  final int id;
  final String option;
  final int? order;
  final bool isActive;

  Option({
    required this.id,
    required this.option,
    this.order,
    required this.isActive,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json.require<int>('id'),
      option: json.require<String>('option'),
      order: json.optional<int>('order'),
      isActive: json.require<bool>('is_active'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'option': option, 'order': order, 'is_active': isActive};
  }
}
