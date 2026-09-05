import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/models/course_details_model.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/features/course/cubit/course_details_cubit.dart';
import 'package:elms/features/course/widgets/chapter_expansion_tile_widget.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ChaptersListSection extends StatefulWidget {
  final List<ChapterModel> chapters;
  final String? title;
  final EdgeInsetsGeometry padding;
  final bool sequentialAccess;
  final bool isEnrolled;
  final int? currentCurriculumId;
  final int? currentChapterId;
  final Function(int chapterId, CurriculumModel curriculum)? onCurriculumTap;
  final bool shrinkWrap;

  const ChaptersListSection({
    super.key,
    required this.chapters,
    this.title,
    this.padding = EdgeInsets.zero,
    required this.sequentialAccess,
    this.isEnrolled = false,
    this.currentCurriculumId,
    this.currentChapterId,
    this.onCurriculumTap,
    this.shrinkWrap = false,
  });

  @override
  State<ChaptersListSection> createState() => _ChaptersListSectionState();
}

class _ChaptersListSectionState extends State<ChaptersListSection> {
  late Set<int> _expandedIndices;
  final GlobalKey _currentChapterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _expandedIndices = _computeInitialExpanded();
    if (widget.isEnrolled &&
        widget.currentChapterId != null &&
        _findCurrentPosition().chapterIndex >= 9) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final ctx = _currentChapterKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Set<int> _computeInitialExpanded() {
    if (widget.isEnrolled) {
      return {_findCurrentPosition().chapterIndex};
    }
    return {0};
  }

  @override
  void didUpdateWidget(covariant ChaptersListSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnrolled &&
        (oldWidget.currentChapterId != widget.currentChapterId ||
            oldWidget.currentCurriculumId != widget.currentCurriculumId)) {
      final newIndex = _findCurrentPosition().chapterIndex;
      if (!_expandedIndices.contains(newIndex)) {
        setState(() => _expandedIndices.add(newIndex));
      }
      if (newIndex >= 9) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final ctx = _currentChapterKey.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }
  }

  /// Finds the chapter index and curriculum index for the current curriculum
  ({int chapterIndex, int curriculumIndex}) _findCurrentPosition() {
    // First try to find by currentChapterId and currentCurriculumId
    if (widget.currentChapterId != null && widget.currentCurriculumId != null) {
      for (
        int chapterIndex = 0;
        chapterIndex < widget.chapters.length;
        chapterIndex++
      ) {
        final chapter = widget.chapters[chapterIndex];
        if (chapter.id == widget.currentChapterId) {
          for (
            int currIndex = 0;
            currIndex < chapter.curriculum.length;
            currIndex++
          ) {
            if (chapter.curriculum[currIndex].id ==
                widget.currentCurriculumId) {
              return (chapterIndex: chapterIndex, curriculumIndex: currIndex);
            }
          }
        }
      }
    }

    // Fallback: find by currentCurriculumId only
    if (widget.currentCurriculumId != null) {
      for (
        int chapterIndex = 0;
        chapterIndex < widget.chapters.length;
        chapterIndex++
      ) {
        final chapter = widget.chapters[chapterIndex];
        for (
          int currIndex = 0;
          currIndex < chapter.curriculum.length;
          currIndex++
        ) {
          if (chapter.curriculum[currIndex].id == widget.currentCurriculumId) {
            return (chapterIndex: chapterIndex, curriculumIndex: currIndex);
          }
        }
      }
    }

    // Default to first chapter, first curriculum
    return (chapterIndex: 0, curriculumIndex: 0);
  }

  Widget _buildChapterTile(
    BuildContext context,
    int index,
    ({int chapterIndex, int curriculumIndex}) currentPosition,
  ) {
    final ChapterModel chapter = widget.chapters[index];

    bool isPreviousChapterLastLessonCompleted = false;
    if (index > 0) {
      final previousChapter = widget.chapters[index - 1];
      if (previousChapter.curriculum.isNotEmpty) {
        isPreviousChapterLastLessonCompleted =
            previousChapter.curriculum.last.isCompleted;
      }
    }

    final bool isCurrentChapter =
        widget.isEnrolled && index == currentPosition.chapterIndex;

    return ChapterExpansionTileWidget(
      key: isCurrentChapter ? _currentChapterKey : null,
      chapter: chapter,
      sequentialAccess: widget.sequentialAccess,
      isEnrolled: widget.isEnrolled,
      currentCurriculumId: widget.currentCurriculumId,
      currentChapterId: widget.currentChapterId,
      chapterIndex: index,
      currentChapterIndex: currentPosition.chapterIndex,
      currentCurriculumIndex: currentPosition.curriculumIndex,
      isPreviousChapterLastLessonCompleted:
          isPreviousChapterLastLessonCompleted,
      isExpanded: _expandedIndices.contains(index),
      onToggle: () {
        setState(() {
          if (_expandedIndices.contains(index)) {
            _expandedIndices.remove(index);
          } else {
            _expandedIndices.add(index);
          }
        });
      },
      onLessonTap: (CurriculumModel lesson, int lessonIndex) {
        if (widget.onCurriculumTap != null) {
          widget.onCurriculumTap!(chapter.id, lesson);
        }

        if (lesson.freePreview && !widget.isEnrolled) {
          final List<PreviewVideoModel> previews = context
              .read<CourseDetailsCubit>()
              .getPreviews()
              .where((element) => element.type != "intro")
              .toList();

          final PreviewVideoModel currentPreview = previews.firstWhere(
            (element) => element.id == lesson.id,
          );
          final String fileType = currentPreview.fileType?.toLowerCase() ?? '';
          final String type = currentPreview.type?.toLowerCase() ?? '';

          final bool isDocument =
              fileType == 'pdf' ||
              fileType == 'doc' ||
              fileType == 'document' ||
              fileType == 'file' ||
              type == 'pdf' ||
              type == 'doc' ||
              type == 'document' ||
              type == 'file';

          if (isDocument) {
            Get.toNamed(
              CourseContentRoute.documentViewer,
              arguments: DocumentViewerArguments(
                documentUrl: currentPreview.fileUrl ?? "",
                documentTitle: currentPreview.title ?? "",
              ),
            );
          } else {
            Get.toNamed(
              AppRoutes.videoPreviewScreen,
              arguments: {
                'previewVideos': previews
                    .where((element) => element.freePreview == true)
                    .toList(),
                'currentVideo': currentPreview,
              },
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = _findCurrentPosition();
    final EdgeInsets insets = widget.padding is EdgeInsets
        ? widget.padding as EdgeInsets
        : EdgeInsets.zero;

    if (widget.shrinkWrap) {
      return Padding(
        padding: insets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) ...[
              CustomText(
                widget.title!,
                style: TextStyle(
                  fontSize: context.font.xxLarge,
                  fontWeight: FontWeight.w500,
                  color: context.color.onSurface,
                ),
              ),
              const SizedBox(height: 16),
            ],
            for (int i = 0; i < widget.chapters.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              _buildChapterTile(context, i, currentPosition),
            ],
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        if (widget.title != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: insets.copyWith(top: 16, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    widget.title!,
                    style: TextStyle(
                      fontSize: context.font.xxLarge,
                      fontWeight: FontWeight.w500,
                      color: context.color.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        SliverPadding(
          padding: insets.copyWith(
            top: 16,
            bottom: 16 + MediaQuery.paddingOf(context).bottom,
          ),
          sliver: SliverList.separated(
            itemCount: widget.chapters.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) =>
                _buildChapterTile(context, index, currentPosition),
          ),
        ),
      ],
    );
  }
}
