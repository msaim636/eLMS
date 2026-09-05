import 'package:elms/common/models/course_details_model.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/video_player/bloc/video_player_bloc.dart';
import 'package:elms/features/video_player/video_player.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class VideoPreviewScreen extends StatefulWidget {
  final PreviewVideoModel current;
  final List<PreviewVideoModel> previewVideos;

  const VideoPreviewScreen({
    super.key,
    required this.previewVideos,
    required this.current,
  });

  static Widget route() {
    final args = Get.arguments as Map<String, dynamic>;

    return VideoPreviewScreen(
      previewVideos: args['previewVideos'] as List<PreviewVideoModel>,
      current: args['currentVideo'] as PreviewVideoModel,
    );
  }

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late PreviewVideoModel _currentVideo = widget.current;

  List<PreviewVideoModel> get _otherVideos {
    return widget.previewVideos
        .asMap()
        .entries
        .where((entry) => entry.value.fileUrl != widget.current.fileUrl)
        .map((entry) => entry.value)
        .toList();
  }

  void _onTapVideoTile(PreviewVideoModel video) {
    _currentVideo = video;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.previewVideos.isEmpty) {
      return Scaffold(
        appBar: CustomAppBar(
          showBackButton: true,
          title: AppLabels.coursePreview.tr,
        ),
        body: Center(
          child: CustomText(
            AppLabels.noVideoAvailable.tr,
            style: TextStyle(fontSize: context.font.small),
            color: context.color.onSurface,
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => VideoPlayerBloc(),
      child: Scaffold(
        appBar: CustomAppBar(
          showBackButton: true,
          title: AppLabels.coursePreview.tr,
        ),
        body: SingleChildScrollView(
          padding: const .all(16),
          child: Column(
            children: [
              _buildCurrentPlayingVideoSection(),
              if (_otherVideos.isNotEmpty) _buildMoreVideoListSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreVideoListSection() {
    final List<PreviewVideoModel> videos = widget.previewVideos
        .where((element) => element.fileUrl != _currentVideo.fileUrl)
        .toList();
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          AppLabels.moreFreePreviews.tr,
          style: TextStyle(
            fontSize: context.font.medium,
            fontWeight: FontWeight.w500,
          ),
          fontWeight: .w500,
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildVideoTile(videos[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildCurrentPlayingVideoSection() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          _currentVideo.title ?? '',
          style: TextStyle(
            fontSize: context.font.medium,
            fontWeight: FontWeight.w500,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 26, top: 16),
          child: (_currentVideo.fileUrl?.isNotEmpty ?? false)
              ? CustomVideoPlayer(
                  key: Key(_currentVideo.fileUrl.hashCode.toString()),
                  url: _currentVideo.fileUrl!,
                )
              : Container(
                  height: 182,
                  width: double.infinity,
                  color: context.color.outline,
                  child: Center(
                    child: CustomText(
                      AppLabels.noVideoAvailable.tr,
                      style: TextStyle(fontSize: context.font.small),
                      color: context.color.onSurface,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildVideoTile(PreviewVideoModel video, int index) {
    return GestureDetector(
      onTap: () => _onTapVideoTile(video),
      child: CustomCard(
        borderColor: Colors.transparent,
        height: 92,
        child: Padding(
          padding: const .all(8.0),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: .expand,
                  children: [
                    if (video.thumbnail?.isNotEmpty ?? false)
                      CustomImage(video.thumbnail!, fit: BoxFit.cover)
                    else
                      Container(color: context.color.outline),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: .circle,
                          color: context.color.darkColor.withValues(alpha: 0.7),
                        ),
                        width: 40,
                        height: 40,
                        child: CustomImage(
                          AppIcons.playIconFilled,
                          color: context.color.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const .symmetric(horizontal: 8.0),
                  child: CustomText(
                    video.title ?? '',
                    style: TextStyle(fontSize: context.font.small),
                    maxLines: 3,
                    ellipsis: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
