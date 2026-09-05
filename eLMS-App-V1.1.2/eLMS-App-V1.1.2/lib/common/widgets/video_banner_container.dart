import 'dart:typed_data';

import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoBannerContainer extends StatefulWidget {
  final double? width, height, radius;
  final String url;
  final bool extractFromVideo;
  final Color? playButtonColor;
  final Color? playBackgroundColor;
  final bool useImageCache;
  final bool hideControlIcons;
  final double blackFilmAlpha;
  final VoidCallback? onTap;

  const VideoBannerContainer({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
    required this.url,
    this.playButtonColor,
    this.playBackgroundColor,
    this.useImageCache = false,
    this.extractFromVideo = false,
    this.hideControlIcons = false,
    this.blackFilmAlpha = 0,
    this.onTap,
  });

  @override
  State<VideoBannerContainer> createState() => _VideoBannerContainerState();
}

class _VideoBannerContainerState extends State<VideoBannerContainer>
    with AutomaticKeepAliveClientMixin {
  Uint8List? extractedThumbnailData;
  @override
  void initState() {
    if (widget.extractFromVideo) {
      _fetchFromVideoURL();
    }
    super.initState();
  }

  Future<void> _fetchFromVideoURL() async {
    extractedThumbnailData = await VideoThumbnail.thumbnailData(
      video: widget.url,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 400,
      quality: 75,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius ?? 8),
      child: Stack(
        alignment: .center,
        children: [
          Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(color: context.color.outline),
          ),
          if (widget.url.isNotEmpty)
            widget.useImageCache
                ? CachedNetworkImage(
                    imageUrl: widget.url,
                    width: widget.width ?? double.infinity,
                    height: widget.height,
                    fit: .cover,
                    placeholder: (context, url) =>
                        Container(color: context.color.outline),
                    errorWidget: (context, url, error) => Container(
                      color: context.color.outline,
                      child: const Icon(Icons.error),
                    ),
                  )
                : widget.extractFromVideo
                ? (extractedThumbnailData == null
                      ? const SizedBox()
                      : Image.memory(extractedThumbnailData!))
                : CustomImage(widget.url, fit: .cover),

          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: widget.blackFilmAlpha),
            ),
          ),

          if (!widget.hideControlIcons)
            GestureDetector(
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  shape: .circle,
                  color: widget.playBackgroundColor ?? context.color.surface,
                ),
                child: CustomImage(
                  AppIcons.playIconFilled,
                  color: widget.playButtonColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
