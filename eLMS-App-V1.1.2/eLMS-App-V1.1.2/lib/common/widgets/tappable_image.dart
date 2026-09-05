import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/fullscreen_image_viewer.dart';
import 'package:flutter/material.dart';

class TappableImage extends StatelessWidget {
  const TappableImage(
    this.imageUrl, {
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.fit = BoxFit.contain,
    this.color,
    super.key,
    this.cacheHeight,
    this.cacheWidth,
    this.isCircular = false,
    this.package,
    this.radius,
    this.enableFullscreenView = true,
    this.onTap,
  });

  const TappableImage.circular({
    required this.imageUrl,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
    this.color,
    super.key,
    this.cacheHeight,
    this.cacheWidth,
    this.isCircular = true,
    this.package,
    this.radius,
    this.enableFullscreenView = true,
    this.onTap,
  });

  final String imageUrl;
  final bool isCircular;
  final Alignment alignment;
  final BoxFit fit;
  final Color? color;
  final double? height;
  final double? width;
  final double? cacheHeight;
  final double? cacheWidth;
  final double? radius;
  final String? package;
  final bool enableFullscreenView;
  final VoidCallback? onTap;

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
    } else if (enableFullscreenView) {
      FullscreenImageViewer.show(context: context, imageUrl: imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = CustomImage(
      imageUrl,
      width: width,
      height: height,
      alignment: alignment,
      fit: fit,
      color: color,
      cacheHeight: cacheHeight,
      cacheWidth: cacheWidth,
      isCircular: isCircular,
      package: package,
      radius: radius,
    );

    if (enableFullscreenView || onTap != null) {
      return GestureDetector(onTap: () => _handleTap(context), child: image);
    }

    return image;
  }
}
