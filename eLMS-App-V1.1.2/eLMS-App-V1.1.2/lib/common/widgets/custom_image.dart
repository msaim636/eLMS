import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomImage extends StatelessWidget {
  const CustomImage(
    this.imageUrl, {
    this.width,
    this.height,
    this.alignment = .center,
    this.fit = .contain,
    this.color,
    super.key,
    this.cacheHeight,
    this.cacheWidth,
    this.isCircular = false,
    this.package,
    this.radius,
    this.supportsRTL = false,
  });

  const CustomImage.circular({
    required this.imageUrl,
    this.width,
    this.height,
    this.alignment = .center,
    this.fit = .cover,
    this.color,
    super.key,
    this.cacheHeight,
    this.cacheWidth,
    this.isCircular = true,
    this.package,
    this.radius,
    this.supportsRTL = false,
  });

  final String imageUrl;
  final bool isCircular;
  final AlignmentGeometry alignment;
  final BoxFit fit;
  final Color? color;
  final double? height;
  final double? width;
  final double? cacheHeight;
  final double? cacheWidth;
  final double? radius;
  final String? package;
  final bool? supportsRTL;

  @override
  Widget build(BuildContext context) {
    final String placeholder = AppIcons.placeholder;
    final String image = imageUrl;
    final ColorFilter? colorFilter = color != null
        ? ColorFilter.mode(color!, .srcIn)
        : null;

    Widget buildErrorWidget() {
      return Container(
        width: width,
        height: height,
        color: context.color.outline.withValues(alpha: 0.7),
        child: Center(
          child: SvgPicture.asset(
            placeholder,
            width: (width ?? 100) * 0.5,
            height: (height ?? 100) * 0.5,
            package: package,
          ),
        ),
      );
    }

    Widget buildPlaceholder() {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Center(
          child: SvgPicture.asset(
            placeholder,
            width: (width ?? 100) * 0.5,
            height: (height ?? 100) * 0.5,
          ),
        ),
      );
    }

    final bool isNetworked = image.startsWith('http');
    final bool isSvg = image.endsWith('.svg');
    final bool isFile = File(image).existsSync();
    return Container(
      width: width,
      height: height,
      clipBehavior: .antiAlias,
      decoration: BoxDecoration(
        borderRadius: radius == null
            ? null
            : BorderRadius.circular(radius ?? 0),
        shape: isCircular ? .circle : .rectangle,
      ),
      child: switch ((isNetworked, isSvg, isFile)) {
        (false, false, true) => Image.file(
          File(image),
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          errorBuilder: (_, o, s) => buildErrorWidget(),
        ),
        (false, false, false) => Image.asset(
          image,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          errorBuilder: (_, o, s) => buildErrorWidget(),
          package: package,
          matchTextDirection: supportsRTL ?? false,
        ),
        (false, true, _) => SvgPicture.asset(
          image,
          width: width,
          height: height,
          colorFilter: colorFilter,
          fit: fit,
          alignment: alignment,
          package: package,
          matchTextDirection: supportsRTL ?? false,
        ),
        (true, false, _) => CachedNetworkImage(
          width: width,
          height: height,
          fit: fit,
          alignment: alignment.resolve(Directionality.of(context)),
          imageUrl: image,
          errorWidget: (_, s, o) => buildErrorWidget(),
          placeholder: (_, s) => buildPlaceholder(),
          memCacheHeight: cacheHeight?.toInt(),
          memCacheWidth: cacheWidth?.toInt(),
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 300),
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: fit,
                alignment: alignment,
              ),
            ),
          ),
        ),
        (true, true, _) => SvgPicture.network(
          image,
          width: width,
          height: height,
          colorFilter: colorFilter,
          fit: fit,
          alignment: alignment,
          matchTextDirection: supportsRTL ?? false,
          errorBuilder: (_, o, s) => buildErrorWidget(),
          placeholderBuilder: (_) => buildPlaceholder(),
        ),
      },
    );
  }
}
