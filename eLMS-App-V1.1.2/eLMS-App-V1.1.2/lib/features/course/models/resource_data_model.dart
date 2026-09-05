// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:elms/common/enums.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class CourseResourcesModel {
  final AllResources allResources;
  final List<LectureModel> currentLectureResources;

  CourseResourcesModel({
    required this.allResources,
    required this.currentLectureResources,
  });

  factory CourseResourcesModel.fromJson(Map<String, dynamic> json) {
    final data = json.optional<Map<String, dynamic>>('data') ?? {};
    final allResources =
        data.optional<Map<String, dynamic>>('all_resources') ?? {};

    // current_lecture_resources is a list of lecture objects (same shape as
    // all_resources.lectures), NOT flat resource objects.
    final currentLectureResources =
        (data.optional<List>('current_lecture_resources') ?? [])
            .map((e) => LectureModel.fromJson(e as Map<String, dynamic>))
            .toList();

    // parse chapters
    final chapters = (allResources.optional<List>('chapters') ?? [])
        .map((e) => ChapterModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // parse lectures and merge into matching chapters
    final lectures = (allResources.optional<List>('lectures') ?? [])
        .map((e) => LectureModel.fromJson(e as Map<String, dynamic>))
        .toList();

    for (var chapter in chapters) {
      final chapterLectures = lectures
          .where((l) => l.chapterId == chapter.chapterId)
          .toList();
      chapter.lectureResources.addAll(chapterLectures);
    }

    // lectures whose chapter_id has no matching chapter entry → create synthetic chapters
    final assignedChapterIds = chapters.map((c) => c.chapterId).toSet();
    final unassigned = lectures
        .where((l) => !assignedChapterIds.contains(l.chapterId))
        .toList();
    final Map<int, List<LectureModel>> byChapter = {};
    for (final lecture in unassigned) {
      byChapter.putIfAbsent(lecture.chapterId, () => []).add(lecture);
    }
    for (final entry in byChapter.entries) {
      final first = entry.value.first;
      chapters.add(
        ChapterModel(
          chapterId: first.chapterId,
          chapterTitle: first.chapterTitle,
          resources: [],
          lectureResources: entry.value,
        ),
      );
    }

    return CourseResourcesModel(
      allResources: AllResources(chapters: chapters),
      currentLectureResources: currentLectureResources,
    );
  }
}

class AllResources {
  final List<ChapterModel> chapters;

  AllResources({required this.chapters});
}

extension CourseResourcesModelX on CourseResourcesModel {
  /// Flattens all [ResourceModel] items from every [LectureModel] in
  /// [currentLectureResources] into a single list for display in the UI.
  List<ResourceModel> get flatCurrentLectureResources =>
      currentLectureResources.expand((l) => l.resources).toList();
}

class ChapterModel {
  final int chapterId;
  final String chapterTitle;
  final List<ResourceModel> resources;
  final List<LectureModel> lectureResources;

  ChapterModel({
    required this.chapterId,
    required this.chapterTitle,
    required this.resources,
    List<LectureModel>? lectureResources,
  }) : lectureResources = lectureResources ?? [];

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      chapterId: json.require<int>('chapter_id'),
      chapterTitle: json.optional<String>('chapter_title') ?? '',
      resources: (json.optional<List>('resources') ?? [])
          .map((e) => ResourceModel.fromJson(e))
          .toList(),
      lectureResources: (json.optional<List>('lecture_resources') ?? [])
          .map((e) => LectureModel.fromJson(e))
          .toList(),
    );
  }
}

class LectureModel {
  final int id;
  final String title;
  final int chapterId;
  final String chapterTitle;
  final int? lectureOrder;
  final List<ResourceModel> resources;

  LectureModel({
    required this.id,
    required this.title,
    required this.chapterId,
    required this.chapterTitle,
    this.lectureOrder,
    required this.resources,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: json.require<int>('id'),
      title: json.optional<String>('title') ?? '',
      chapterId: json.require<int>('chapter_id'),
      chapterTitle: json.optional<String>('chapter_title') ?? '',
      lectureOrder: json.optional<int>('lecture_order'),
      resources: (json.optional<List>('resources') ?? [])
          .map((e) => ResourceModel.fromJson(e))
          .toList(),
    );
  }
}

class ResourceModel {
  final int? id;
  final String? title;
  final ResourceType type;
  final String? fileUrl;
  final String? externalUrl;
  final String? fileName;
  final String? fileExtension;
  final String? description;
  final String? resourceType;
  final String? createdAt;

  ResourceModel({
    this.id,
    this.title,
    required this.type,
    this.fileUrl,
    this.externalUrl,
    this.fileName,
    this.fileExtension,
    this.description,
    this.resourceType,
    this.createdAt,
  });

  /// Returns the best available display title for this resource.
  ///
  /// Priority:
  /// 1. For external links → always use [title].
  /// 2. [file_name] from the API (e.g. "test resoucre.webp").
  /// 3. [title] if it is meaningful (not just a bare extension like ".mp4").
  /// 4. The last path segment of [fileUrl] as a last resort.
  String get getTitle {
    if (type == ResourceType.externalLink) {
      return title ?? externalUrl ?? '';
    }

    // A title that is ONLY an extension (e.g. ".mp4") is not useful.
    final bool titleIsMeaningful =
        title != null &&
        title!.isNotEmpty &&
        !RegExp(r'^\.[a-zA-Z0-9]+$').hasMatch(title!);

    return fileName ?? // "test resoucre.webp"
        (titleIsMeaningful ? title : null) ?? // real title
        fileUrl?.split('/').last ?? // hashed url filename
        '';
  }

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    final typeString = json.optional<String>('type') ?? '';
    final resourceType = typeString == 'external_link'
        ? ResourceType.externalLink
        : ResourceType.download;

    return ResourceModel(
      id: json.optional<int>('id'),
      title: json.optional<String>('title'),
      type: resourceType,
      fileUrl: json.optional<String>('file_url'),
      externalUrl: json.optional<String>('external_url'),
      fileName: json.optional<String>('file_name'),
      fileExtension: json.optional<String>('file_extension'),
      description: json.optional<String>('description'),
      resourceType: json.optional<String>('resource_type'),
      createdAt: json.optional<String>('created_at'),
    );
  }

  @override
  String toString() {
    return 'ResourceModel(id: $id, title: $title, type: $type, fileUrl: $fileUrl, externalUrl: $externalUrl, fileName: $fileName, fileExtension: $fileExtension, description: $description, resourceType: $resourceType, createdAt: $createdAt)';
  }
}
