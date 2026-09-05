import 'package:elms/common/enums.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final CustomButtonType type;
  final VoidCallback? onPressed;
  final String? title;
  final Widget? customTitle;
  final Widget? preFix;
  final double border;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? textColor;
  final bool fullWidth;
  final double? height;
  final Color? disabledColor;
  final double? width;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final double? textSize;
  final double radius;
  final int titleMaxLines;
  final bool elipsis;

  const CustomButton({
    super.key,
    this.onPressed,
    this.title,
    this.radius = 6,
    this.customTitle,
    this.border = 0.0,
    this.borderColor,
    this.preFix,
    this.backgroundColor,
    this.textColor,
    this.fullWidth = false,
    this.height = 45,
    this.width,
    this.disabledColor,
    this.isLoading = false,
    this.textSize,
    this.type = CustomButtonType.primary,
    this.padding,
    this.elipsis = true,
    this.titleMaxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        (type == CustomButtonType.outlined && backgroundColor == null)
        ? context.color.surface
        : backgroundColor ?? context.color.primary;

    return MaterialButton(
      onPressed: onPressed,
      height: height,
      color: color,
      elevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      highlightColor: context.color.outline,
      minWidth: fullWidth ? context.screenWidth : width,
      disabledColor: disabledColor ?? context.color.outline.darken(0.1),
      textColor: textColor ?? color.getAdaptiveTextColor(),
      padding: padding,

      materialTapTargetSize: .shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: borderColor ?? context.color.outline,
          width: type == CustomButtonType.outlined ? 1 : border,
        ),
      ),
      child:
          customTitle ??
          Row(
            mainAxisSize: .min,
            mainAxisAlignment: .center,
            children: [
              if (isLoading)
                Container(
                  height: 15,
                  width: 15,
                  margin: const .symmetric(horizontal: 4),
                  child: CircularProgressIndicator(
                    color: context.color.surface,
                    strokeWidth: 1.6,
                  ),
                ),
              if (preFix != null) preFix!,
              Flexible(
                child: Text(
                  title ?? '',
                  maxLines: titleMaxLines,
                  overflow: elipsis ? TextOverflow.ellipsis : TextOverflow.fade,

                  style: TextStyle(fontSize: textSize),
                ),
              ),
            ],
          ),
    );
  }
}
