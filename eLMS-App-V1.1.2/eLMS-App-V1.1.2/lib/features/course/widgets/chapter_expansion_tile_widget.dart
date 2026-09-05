import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/widgets/custom_expandable_tile.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/course/widgets/chapter_lesson_tile.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChapterExpansionTileWidget extends StatelessWidget {
  final ChapterModel chapter;
  final bool? isExpanded;
  final VoidCallback onToggle;
  final bool sequentialAccess;
  final bool isEnrolled;
  final int? currentCurriculumId;
  final int? currentChapterId;
  final int chapterIndex;
  final int currentChapterIndex;
  final int currentCurriculumIndex;
  final Function(CurriculumModel, int lessonIndex)? onLessonTap;
  final bool isPreviousChapterLastLessonCompleted;

  const ChapterExpansionTileWidget({
    super.key,
    required this.chapter,
    this.isExpanded,
    required this.onToggle,
    this.onLessonTap,
    required this.sequentialAccess,
    this.isEnrolled = false,
    this.currentCurriculumId,
    this.currentChapterId,
    required this.chapterIndex,
    required this.currentChapterIndex,
    required this.currentCurriculumIndex,
    this.isPreviousChapterLastLessonCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomExpandableTile(
      title: chapter.title,
      subtitle: _buildChapterDetails(),
      isExpanded: isExpanded,
      onToggle: onToggle,
      content: chapter.curriculum.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: CustomText(
                  AppLabels.noCurriculumFound.tr,
                  color: context.color.textSecondary,
                ),
              ),
            )
          : ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: .zero,
              itemCount: chapter.curriculum.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 8);
              },
              itemBuilder: (context, lessonIndex) {
                final CurriculumModel lesson = chapter.curriculum[lessonIndex];

                // Calculate if this curriculum is unlocked based on global position
                // A curriculum is unlocked if:
                // 1. It's in a chapter before the current chapter, OR
                // 2. It's in the current chapter AND at or before the current curriculum position
                final bool isUnlocked = _isUnlocked(lessonIndex);

                // Lock logic:
                // - If NOT enrolled: lock all lessons EXCEPT those with free preview
                // - If enrolled: use sequential access logic
                final bool isLocked = !isEnrolled
                    ? !lesson.freePreview
                    : (sequentialAccess && !isUnlocked);

                return ChapterLessonTile(
                  key: ValueKey('${lesson.id}${lesson.isCompleted}'),
                  title: lesson.title,
                  subtitle: isEnrolled
                      ? _formatLessonDuration(
                          lesson.hours,
                          lesson.minutes,
                          lesson.seconds,
                        )
                      : null,
                  isCompleted: lesson.isCompleted,
                  icon: _getLessonTypeIcon(lesson.type, lesson.lectureType),
                  isLocked: isLocked,
                  hasPreview: lesson.freePreview && !isEnrolled,
                  isCurrent:
                      currentCurriculumId != null &&
                      lesson.id == currentCurriculumId,
                  onTap: isLocked == true
                      ? null
                      : (onLessonTap != null
                            ? () => onLessonTap!(lesson, lessonIndex)
                            : null),
                  iconColor: context.color.onSecondary,
                  textColor: context.color.onSecondary,
                  iconSize: 16,
                );
              },
            ),
    );
  }

  /// Determines if a curriculum at the given index is unlocked
  /// based on completion status and position relative to the current curriculum
  bool _isUnlocked(int lessonIndex) {
    // First lesson of first chapter is always unlocked
    if (chapterIndex == 0 && lessonIndex == 0) {
      return true;
    }

    // Check if the previous lesson is completed
    if (lessonIndex > 0) {
      // Previous lesson is in the same chapter
      final previousLesson = chapter.curriculum[lessonIndex - 1];
      if (previousLesson.isCompleted) {
        return true;
      }
    } else if (chapterIndex > 0 && lessonIndex == 0) {
      // This is the first lesson of a chapter (not the first chapter)
      // Check if the last lesson of the previous chapter is completed
      if (isPreviousChapterLastLessonCompleted) {
        return true;
      }
    }

    // If no current curriculum is set, only the first item is unlocked (handled above)
    if (currentCurriculumId == null) {
      return false;
    }

    // Position-based unlock logic (fallback)
    // If this chapter is before the current chapter, it's unlocked
    if (chapterIndex < currentChapterIndex) {
      return true;
    }

    // If this chapter is after the current chapter, it's locked
    if (chapterIndex > currentChapterIndex) {
      return false;
    }

    // Same chapter: unlock if at or before current curriculum position
    return lessonIndex <= currentCurriculumIndex;
  }

  String? _buildChapterDetails() {
    final List<String> details = [
      if (chapter.lecturesCount != 0)
        Utils.pluralize(
          chapter.lecturesCount,
          singular: AppLabels.lecture,
          plural: AppLabels.lectures,
        ),
      if (chapter.assignmentsCount != 0)
        Utils.pluralize(
          chapter.assignmentsCount,
          singular: AppLabels.assignment,
          plural: AppLabels.assignments,
        ),
      if (chapter.quizzesCount != 0)
        Utils.pluralize(
          chapter.quizzesCount,
          singular: AppLabels.quiz,
          plural: AppLabels.quizzes,
        ),
      if (_getTotalDuration().totalSeconds != 0) _formatDuration(),
    ];
    final String joined = details.join(' | ');
    return joined.isEmpty ? null : joined;
  }

  ({int totalMinutes, int totalSeconds}) _getTotalDuration() {
    int totalSeconds = 0;
    for (var curriculum in chapter.curriculum) {
      totalSeconds += (curriculum.hours ?? 0) * 3600;
      totalSeconds += (curriculum.minutes ?? 0) * 60;
      totalSeconds += curriculum.seconds ?? 0;
    }
    return (totalMinutes: totalSeconds ~/ 60, totalSeconds: totalSeconds);
  }

  String _formatDuration() {
    final int total = _getTotalDuration().totalSeconds;

    if (total == 0) return AppLabels.durationZeroMin.tr;

    return _formatHms(total ~/ 3600, (total % 3600) ~/ 60, total % 60);
  }

  String? _formatLessonDuration(int? hours, int? minutes, int? seconds) {
    final int h = hours ?? 0;
    final int m = minutes ?? 0;
    final int s = seconds ?? 0;
    if (h == 0 && m == 0 && s == 0) return null;
    return AppLabels.lessonDuration.tr.replaceAll(
      '{{time}}',
      _formatHms(h, m, s),
    );
  }

  /// Builds a localized duration string, omitting any unit that is zero so a
  /// duration like exactly one hour reads "1h" instead of "1h 0m 0s".
  String _formatHms(int hours, int minutes, int seconds) {
    if (hours > 0 && minutes > 0 && seconds > 0) {
      return AppLabels.durationHoursMinutesSeconds.tr
          .replaceAll('{{hours}}', hours.toString())
          .replaceAll('{{minutes}}', minutes.toString())
          .replaceAll('{{seconds}}', seconds.toString());
    } else if (hours > 0 && minutes > 0) {
      return AppLabels.durationHoursMinutes.tr
          .replaceAll('{{hours}}', hours.toString())
          .replaceAll('{{minutes}}', minutes.toString());
    } else if (hours > 0 && seconds > 0) {
      return AppLabels.durationHoursSeconds.tr
          .replaceAll('{{hours}}', hours.toString())
          .replaceAll('{{seconds}}', seconds.toString());
    } else if (hours > 0) {
      return AppLabels.durationHours.tr.replaceAll(
        '{{hours}}',
        hours.toString(),
      );
    } else if (minutes > 0 && seconds > 0) {
      return AppLabels.durationMinutesSeconds.tr
          .replaceAll('{{minutes}}', minutes.toString())
          .replaceAll('{{seconds}}', seconds.toString());
    } else if (minutes > 0) {
      return AppLabels.durationMinutes.tr.replaceAll(
        '{{minutes}}',
        minutes.toString(),
      );
    } else {
      return AppLabels.durationSeconds.tr.replaceAll(
        '{{seconds}}',
        seconds.toString(),
      );
    }
  }

  String _getLessonTypeIcon(String? type, String? lectureType) {
    final lowerType = type?.toLowerCase();

    switch (lowerType) {
      case 'video':
        return AppIcons.videoOutline;
      case 'pdf':
      case 'file':
      case 'document':
        return AppIcons.note;
      case 'quiz':
        return AppIcons.game;
      case 'assignment':
        return AppIcons.attachSquare;
      case 'link':
      case 'url':
        return AppIcons.link;
      default:
        return AppIcons.videoOutline;
    }
  }
}
