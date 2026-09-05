import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_inkwell.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final String image;
  final Size size;
  final Color? color;
  final VoidCallback onTap;
  final EdgeInsets padding;

  const CustomIconButton({
    super.key,
    required this.image,
    required this.onTap,
    this.size = const Size(48, 48),
    this.color,
    this.padding = const .all(2),
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      width: size.width,
      height: size.height,
      child: CustomInkWell(
        onTap: onTap,
        color: Colors.transparent,
        child: Padding(
          padding: padding,
          child: Align(child: CustomImage(image, color: color)),
        ),
      ),
    );
  }
}
