import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double border;
  final double borderRadius;
  final Color? borderColor;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final Color? color;
  final Alignment? alignment;
  const CustomCard({
    super.key,
    required this.child,
    this.border = 1.0,
    this.borderColor,
    this.borderRadius = 8.0,
    this.margin = .zero,
    this.padding = .zero,
    this.height,
    this.color,
    this.width,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      width: width,
      alignment: alignment,
      height: height,
      clipBehavior: .antiAlias,
      foregroundDecoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? context.color.outline,
          width: border,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      decoration: BoxDecoration(
        color: color ?? context.color.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
