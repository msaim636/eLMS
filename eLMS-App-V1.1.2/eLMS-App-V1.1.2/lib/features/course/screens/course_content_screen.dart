import 'package:elms/common/enums.dart';
import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_tab_bar.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/core/services/refresh_notifier.dart';
import 'package:elms/features/course/cubit/course_details_cubit.dart';
import 'package:elms/features/course/cubits/fetch_discussion_cubit.dart';
import 'package:elms/features/course/features/discussion/widgets/discussion_section.dart';
import 'package:elms/features/course/features/discussion/widgets/message_bottombar.dart';
import 'package:elms/features/course/features/quiz/widgets/start_quiz_card.dart';
import 'package:elms/features/course/repositories/discussion_repository.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/features/course/widgets/assignment_preview_widget.dart';
import 'package:elms/features/course/widgets/audio_player_widget.dart';
import 'package:elms/features/course/widgets/chapters_list_section.dart';
import 'package:elms/features/course/widgets/course_details_appbar.dart';
import 'package:elms/features/course/widgets/document_preview_widget.dart';
import 'package:elms/features/course/widgets/more_content_section.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:elms/utils/video/placeholder_target.dart';
import 'package:elms/utils/video/player_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CourseContentScreen extends StatefulWidget {
  const CourseContentScreen({
    super.key,
    required this.courseId,
    this.arguments,
  });

  final int courseId;
  final CourseContentScreenArguments? arguments;

  static Widget route([CourseContentScreenArguments? args]) {
    final CourseContentScreenArguments? arguments =
        args ??
        (Get.arguments is CourseContentScreenArguments
            ? Get.arguments as CourseContentScreenArguments
            : null);

    final int courseId =
        arguments?.course.id ??
        (throw Exception('CourseContentScreen requires course data'));

    Get.put<CourseContentScreenArguments?>(arguments, permanent: true);

    final screenSnapshot = MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CourseDetailsCubit(CourseRepository())),
        BlocProvider(
          create: (_) =>
              FetchDiscussionCubit(DiscussionRepository(), courseId: courseId),
        ),
      ],
      child: CourseContentScreen(courseId: courseId, arguments: args),
    );

    Get.put<MultiBlocProvider>(
      screenSnapshot,
      tag: 'restoreable-contentscreen',
      permanent: true,
    );
    return screenSnapshot;
  }

  @override
  State<CourseContentScreen> createState() => CourseContentScreenState();
}

class CourseContentScreenState extends State<CourseContentScreen>
    with SingleTickerProviderStateMixin {
  static const double _videoHeight = 211.0;
  static const double _contentPadding = 16.0;

  late final TabController _tabController;
  late final CourseModel _course;
  String? _slug;

  final ScrollController _tab0ScrollController = ScrollController();
  final ScrollController _tab1ScrollController = ScrollController();
  final ScrollController _tab2ScrollController = ScrollController();

  final ValueNotifier<bool> _showMessageBottomBar = ValueNotifier(false);
  final ValueNotifier<CurriculumModel?> _currentCurriculum = ValueNotifier(
    null,
  );
  final ValueNotifier<int?> _currentChapterId = ValueNotifier(null);

  int _currentTabIndex = 0;
  double _opacity = 1;
  CustomException? _exception;

  @override
  void initState() {
    super.initState();

    final CourseContentScreenArguments? arguments =
        widget.arguments ??
        (Get.arguments is CourseContentScreenArguments
            ? Get.arguments as CourseContentScreenArguments
            : null);

    _course =
        arguments?.course ??
        (throw Exception(
          'CourseContentScreen requires course data via arguments',
        ));
    _slug = arguments?.slug;

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    context.read<CourseDetailsCubit>().fetchCourseDetails(_course, slug: _slug);

    PlayerManager.instance.addListener(_handlePlayerChange);
  }

  @override
  void dispose() {
    PlayerManager.instance.removeListener(_handlePlayerChange);
    _tabController.dispose();
    _showMessageBottomBar.dispose();
    _currentCurriculum.dispose();
    _currentChapterId.dispose();
    _tab0ScrollController.dispose();
    _tab1ScrollController.dispose();
    _tab2ScrollController.dispose();
    super.dispose();
  }

  void _handlePlayerChange() {
    if (!mounted) return;
    setState(() {
      _opacity = 1 - PlayerManager.instance.normalized;
    });
  }

  void _handleTabChange() {
    final bool showMessageBar = _tabController.index == 1;
    // Dismiss the keyboard before the message bar (and its text field) is
    // removed from the tree. Otherwise the focused EditableText is unmounted
    // while the IME still has pending batch edits, throwing an
    // "unfinished batch edits" assertion.
    if (!showMessageBar) FocusManager.instance.primaryFocus?.unfocus();
    _showMessageBottomBar.value = showMessageBar;
    setState(() => _currentTabIndex = _tabController.index);
  }

  /// Playable media url for a curriculum — prefers the signed `fileUrl` and
  /// falls back to `file`. Null when there is nothing to play. Mirrors the url
  /// resolution used by [_buildCurriculumPreview].
  String? _playableUrl(CurriculumModel curriculum) {
    final String? url = curriculum.fileUrl ?? curriculum.file;
    return (url != null && url.isNotEmpty) ? url : null;
  }

  /// Whether [curriculum] is rendered as the inline video player by
  /// [_buildCurriculumPreview]. Kept in lockstep with that method's branches so
  /// that selecting a lecture always loads its video into the player. Previously
  /// the tap handler used a narrow `fileType in {'video','yt'}` check that
  /// silently skipped `setVideo` for some videos (different `fileType`, or a url
  /// only present in `file`), leaving the previous video on screen.
  bool _isInlineVideo(CurriculumModel curriculum) {
    final String? type = curriculum.type?.toLowerCase();
    final String? url = _playableUrl(curriculum);
    final FileType? detectedFileType = url != null
        ? FileType.fromExtension(url)
        : null;

    if (type == 'quiz') return false;
    if (type == 'document' && detectedFileType == FileType.audio) return false;
    if (type == 'document') return false;
    if (type == 'assignment') return false;
    if (type == 'lecture' && curriculum.fileType?.toLowerCase() == 'doc') {
      return false;
    }
    return true;
  }

  /// Whether [curriculum] should play through the HLS pipeline. Primary signal
  /// is `file_type == 'hls'` (the backend's flag), but we also treat the secure
  /// `/api/video/{id}/stream` endpoint as HLS since that URL returns a manifest
  /// JSON, not a media file — feeding it to the progressive player fails with
  /// "unsupported video format".
  bool _isHlsVideo(CurriculumModel curriculum, String url) {
    return curriculum.fileType?.toLowerCase() == 'hls' ||
        url.contains('/api/video/');
  }

  int? _findChapterIdForCurriculum(
    List<ChapterModel> chapters,
    int curriculumId,
  ) {
    for (final chapter in chapters) {
      if (chapter.curriculum.any((c) => c.id == curriculumId)) {
        return chapter.id;
      }
    }
    return null;
  }

  CourseDetailsSuccess? get _detailsSuccessOrNull {
    final state = context.read<CourseDetailsCubit>().state;
    return state is CourseDetailsSuccess ? state : null;
  }

  Future<void> _markCurriculumCompleted(
    CurriculumModel curriculum,
    int chapterId,
  ) async {
    await context.read<CourseDetailsCubit>().markCurriculumCompleted(
      chapterId: chapterId,
      courseId: widget.courseId,
      curriculum: curriculum,
    );
    RefreshNotifier.instance.markMyLearningForRefresh();
  }

  void _onCurriculumTap(int chapterId, CurriculumModel curriculum) {
    _currentCurriculum.value = curriculum;
    _currentChapterId.value = chapterId;
    final String? url = _playableUrl(curriculum);
    if (url != null && _isInlineVideo(curriculum)) {
      PlayerManager.instance.setVideo(
        Uri.parse(url),
        metadata: {
          'isHLS': _isHlsVideo(curriculum, url),
          // Re-wires 90%-watched auto-completion that was dropped when playback
          // moved to the global mini-player. Read back in app.dart and handed to
          // the player as onVideoCompletion. Fires for the currently playing
          // lecture (_currentCurriculum), regular or HLS.
          'onCompletion': () => _onVideoCompletion(),
        },
      );
    }
  }

  Future<void> _onVideoCompletion() async {
    final curriculum = _currentCurriculum.value;
    if (curriculum == null) return;

    final success = _detailsSuccessOrNull;
    if (success == null) return;

    final chapterId = _findChapterIdForCurriculum(
      success.data.chapters,
      curriculum.id,
    );
    if (chapterId == null) return;

    await _markCurriculumCompleted(curriculum, chapterId);
  }

  Future<void> _onDocumentOpen() async {
    final curriculum = _currentCurriculum.value;
    if (curriculum == null) return;

    final String? documentUrl = curriculum.fileUrl ?? curriculum.file;
    if (documentUrl == null || documentUrl.isEmpty) {
      UiUtils.showSnackBar(AppLabels.documentNotFound.tr, isError: true);
      return;
    }

    final success = _detailsSuccessOrNull;
    if (success == null) return;

    final chapterId = _findChapterIdForCurriculum(
      success.data.chapters,
      curriculum.id,
    );
    if (chapterId == null) return;

    await _markCurriculumCompleted(curriculum, chapterId);

    if (!mounted) return;

    await Get.toNamed(
      AppRoutes.documentViewer,
      arguments: DocumentViewerArguments(
        documentUrl: documentUrl,
        documentTitle: curriculum.title,
      ),
    );
  }

  Future<void> _onSkipToNextLecture(CurriculumModel curriculum) async {
    final success = _detailsSuccessOrNull;
    if (success == null) return;

    final chapterId = _findChapterIdForCurriculum(
      success.data.chapters,
      curriculum.id,
    );
    if (chapterId == null) return;

    await _markCurriculumCompleted(curriculum, chapterId);

    if (!mounted) return;

    final updated = _detailsSuccessOrNull;
    if (updated == null) return;

    final next = _findNextCurriculum(updated.data.chapters, curriculum.id);
    if (next != null) {
      _onCurriculumTap(next.chapterId, next.curriculum);
    }
  }

  ({int chapterId, CurriculumModel curriculum})? _findNextCurriculum(
    List<ChapterModel> chapters,
    int currentCurriculumId,
  ) {
    bool foundCurrent = false;
    for (final chapter in chapters) {
      for (final curr in chapter.curriculum) {
        if (foundCurrent) {
          return (chapterId: chapter.id, curriculum: curr);
        }
        if (curr.id == currentCurriculumId) foundCurrent = true;
      }
    }
    return null;
  }

  void _initializeCurrentCurriculum(List<ChapterModel> chapters) {
    if (_currentCurriculum.value != null) return;

    final courseDetails = context.read<CourseDetailsCubit>().courseDetails;
    final currentCurriculumData = courseDetails?.currentCurriculum;

    if (currentCurriculumData != null) {
      for (final chapter in chapters) {
        final curriculum = chapter.curriculum.firstWhereOrNull(
          (c) => c.id == currentCurriculumData.modelId,
        );
        if (curriculum != null) {
          final String? url = _playableUrl(curriculum);
          if (url != null && _isInlineVideo(curriculum)) {
            PlayerManager.instance.setVideo(
              Uri.parse(url),
              metadata: {
                'isHLS': _isHlsVideo(curriculum, url),
                'onCompletion': () => _onVideoCompletion(),
              },
            );
          }
          _currentCurriculum.value = curriculum;
          _currentChapterId.value = chapter.id;
          return;
        }
      }
    }

    if (chapters.isNotEmpty && chapters.first.curriculum.isNotEmpty) {
      _currentCurriculum.value = chapters.first.curriculum.first;
      _currentChapterId.value = chapters.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isMinimized = _opacity <= 0.01;

    return PopScope(
      canPop: !isMinimized,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) PlayerManager.instance.maximize();
      },
      child: IgnorePointer(
        ignoring: isMinimized,
        child: Opacity(
          opacity: _opacity,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _opacity)),
            child: SafeArea(
              top: false,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Stack(
                  children: [
                    _buildMainContent(),
                    Positioned(
                      left: 0,
                      right: 0,
                      // SafeArea already insets the body by the bottom
                      // padding, so only offset for the keyboard here to
                      // avoid double-counting and floating the bar too high.
                      bottom: keyboardHeight > 0 ? keyboardHeight : 0,
                      child: _buildMessageBar(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        if (_exception == null) ...[_buildHeaderSection(), _buildTabBar()],
        SliverFillRemaining(
          child: _exception == null
              ? _buildTabContent()
              : CustomErrorWidget(error: _exception),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      toolbarHeight: kToolbarHeight + 10,
      pinned: true,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: CourseDetailsAppBar(course: _course),
    );
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _contentPadding,
          vertical: 16,
        ),
        child: BlocListener<CourseDetailsCubit, CourseDetailsState>(
          listener: (context, state) {
            if (state is CourseDetailsSuccess &&
                state.data.chapters.isNotEmpty) {
              _initializeCurrentCurriculum(state.data.chapters);
              setState(() {});
            }
            if (state is CourseDetailsError) {
              setState(() => _exception = AppException(message: state.error));
            }
          },
          child: ValueListenableBuilder<CurriculumModel?>(
            valueListenable: _currentCurriculum,
            builder: (context, curriculum, _) =>
                _buildCurriculumPreview(curriculum),
          ),
        ),
      ),
    );
  }

  Widget _buildCurriculumPreview(CurriculumModel? curriculum) {
    if (curriculum == null) {
      final hasDetails = _detailsSuccessOrNull != null;
      return hasDetails
          ? _buildPlaceholder(
              icon: Icons.video_library_outlined,
              text: AppLabels.noContentAvailable.tr,
            )
          : _buildPlaceholder(text: AppLabels.loading.tr, showProgress: true);
    }

    final String? type = curriculum.type?.toLowerCase();
    final String? fileUrl = curriculum.fileUrl ?? curriculum.file;
    final FileType? detectedFileType = fileUrl != null
        ? FileType.fromExtension(fileUrl)
        : null;

    if (type == 'quiz') return _buildQuizCard(curriculum);
    if (type == 'document' && detectedFileType == FileType.audio) {
      return _buildAudioPlayer(curriculum);
    }
    if (type == 'document') return _buildDocumentPreview(curriculum);
    if (type == 'assignment') return _buildAssignmentPreview(curriculum);
    if (type == 'lecture' && curriculum.fileType?.toLowerCase() == 'doc') {
      return _buildDocumentPreview(curriculum);
    }
    return _buildVideoPlayer();
  }

  Widget _buildQuizCard(CurriculumModel curriculum) {
    final chapters =
        _detailsSuccessOrNull?.data.chapters ?? const <ChapterModel>[];
    final chapterIndex = chapters.indexWhere(
      (c) => c.id == _currentChapterId.value,
    );
    return StartQuizCard(
      curriculum: curriculum,
      courseChapterQuizId: curriculum.id.toString(),
      courseId: _course.id,
      chapterId: _currentChapterId.value ?? 0,
      chapterIndex: chapterIndex < 0 ? 0 : chapterIndex,
      onSkipToNext: () => _onSkipToNextLecture(curriculum),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        Material(
          color: Colors.transparent,
          child: CustomTabBar(
            controller: _tabController,
            useEllipsis: true,
            tabs: [
              AppLabels.chapter.tr,
              AppLabels.discussion.tr,
              AppLabels.more.tr,
            ],
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return IndexedStack(
      index: _currentTabIndex,
      children: [
        PrimaryScrollController(
          controller: _tab0ScrollController,
          child: _buildChaptersTab(),
        ),
        PrimaryScrollController(
          controller: _tab1ScrollController,
          child: const DiscussionSection(),
        ),
        PrimaryScrollController(
          controller: _tab2ScrollController,
          child: ValueListenableBuilder<CurriculumModel?>(
            valueListenable: _currentCurriculum,
            builder: (context, currentCurriculum, _) => MoreContentSection(
              course: _course,
              currentLectureId: currentCurriculum?.id,
              chapterId: _currentChapterId.value,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChaptersTab() {
    return BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
      builder: (context, state) {
        if (state is! CourseDetailsSuccess) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomShimmer(height: 20, width: 150, borderRadius: 4),
                CustomShimmer(
                  height: 56,
                  width: double.infinity,
                  borderRadius: 8,
                ),
                CustomShimmer(
                  height: 56,
                  width: double.infinity,
                  borderRadius: 8,
                ),
                CustomShimmer(
                  height: 56,
                  width: double.infinity,
                  borderRadius: 8,
                ),
                CustomShimmer(
                  height: 56,
                  width: double.infinity,
                  borderRadius: 8,
                ),
              ],
            ),
          );
        }
        final bool sequentialAccess = state.data.sequentialAccess;
        return ValueListenableBuilder<CurriculumModel?>(
          valueListenable: _currentCurriculum,
          builder: (context, currentCurriculum, _) {
            return ValueListenableBuilder<int?>(
              valueListenable: _currentChapterId,
              builder: (context, currentChapterId, _) {
                final chapters = state.data.chapters
                    .where((chapter) => chapter.curriculum.isNotEmpty)
                    .toList();
                return ChaptersListSection(
                  chapters: chapters,
                  sequentialAccess: sequentialAccess,
                  isEnrolled: _course.isEnrolled,
                  currentCurriculumId: currentCurriculum?.id,
                  currentChapterId: currentChapterId,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onCurriculumTap: _onCurriculumTap,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBar() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showMessageBottomBar,
      builder: (context, show, _) {
        // Keep the bar (and its text field) mounted across tab switches via
        // Offstage. Unmounting a focused EditableText mid IME edit throws an
        // "unfinished batch edits" assertion.
        return Offstage(
          offstage: !show,
          child: MessageBottomBar(
            id: widget.courseId,
            destination: DiscussionDestination.course,
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder({
    required String text,
    IconData? icon,
    bool showProgress = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: _videoHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.color.surfaceContainerHighest,
          border: Border.all(color: context.color.outline),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: .center,
            spacing: 12,
            children: [
              if (showProgress) const CircularProgressIndicator(),
              if (icon != null)
                Icon(icon, size: 48, color: context.color.onSurfaceVariant),
              CustomText(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: context.color.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return PlaceHolderTarget(width: context.screenWidth, height: _videoHeight);
  }

  Widget _buildDocumentPreview(CurriculumModel curriculum) {
    return DocumentPreviewWidget(
      curriculum: curriculum,
      courseImage: _course.image,
      height: _videoHeight,
      onDocumentOpen: _onDocumentOpen,
    );
  }

  Widget _buildAssignmentPreview(CurriculumModel curriculum) {
    return AssignmentPreviewWidget(
      curriculum: curriculum,
      courseImage: _course.image,
      courseId: widget.courseId,
      chapterId: _currentChapterId.value,
      height: _videoHeight,
      onSkipToNext: () => _onSkipToNextLecture(curriculum),
    );
  }

  Widget _buildAudioPlayer(CurriculumModel curriculum) {
    return AudioPlayerWidget(
      audioUrl: curriculum.fileUrl ?? curriculum.file ?? '',
      coverImageUrl: _course.image,
      height: _videoHeight,
      onAudioCompletion: _onVideoCompletion,
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar);

  final Widget tabBar;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: overlapsContent ? Theme.of(context).colorScheme.surface : null,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
