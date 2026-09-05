import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class BlendedColorImage extends StatelessWidget {
  final String imagePath;
  final Color? color;
  final double intensity;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const BlendedColorImage({
    super.key,
    required this.imagePath,
    this.color,
    this.intensity = 0.8,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final blendColor = color ?? context.color.primary;
    final r = blendColor.r;
    final g = blendColor.g;
    final b = blendColor.b;

    return ColorFiltered(
      colorFilter: ColorFilter.matrix([
        r * intensity,
        r * intensity,
        r * intensity,
        0,
        0,
        g * intensity,
        g * intensity,
        g * intensity,
        0,
        0,
        b * intensity,
        b * intensity,
        b * intensity,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: CustomImage(
        imagePath,
        width: width,
        height: height,
        fit: fit ?? .contain,
      ),
    );
  }
}
