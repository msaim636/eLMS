// ignore_for_file: file_names

import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmer extends StatelessWidget {
  const CustomShimmer({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
    this.margin,
  });
  final double? height;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.color.primary.withValues(alpha: 0.1),
      highlightColor: context.color.primary.withValues(alpha: 0.4),
      child: Container(
        width: width,
        margin: margin,
        height: height ?? 10,
        decoration: BoxDecoration(
          color: context.color.primary.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
        ),
      ),
    );
  }
}

class ShimmerBuilder extends StatelessWidget {
  final Widget shimmer;
  final double spacing;
  final Axis direction;
  final int itemCount;
  final EdgeInsetsGeometry? padding;

  const ShimmerBuilder({
    super.key,
    required this.shimmer,
    this.spacing = 8.0,
    this.direction = .vertical,
    this.itemCount = AppConstant.kShimmerCount,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: direction,
      shrinkWrap: true,
      itemBuilder: (context, index) => shimmer,
      separatorBuilder: (context, index) => direction == .vertical
          ? SizedBox(height: spacing)
          : SizedBox(width: spacing),
      itemCount: itemCount,
      padding: padding,
    );
  }
}
