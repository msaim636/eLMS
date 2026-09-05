import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign textAlign;
  final TextDecoration? decoration;
  final String? family;
  final int? maxLines;
  final bool ellipsis;
  final double? height;
  final bool? softWrap;

  const CustomText(
    this.text, {
    super.key,
    this.style = const TextStyle(),
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign = .start,
    this.decoration,
    this.family,
    this.maxLines,
    this.ellipsis = false,
    this.height,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: ellipsis ? .ellipsis : .clip,
      maxLines: maxLines,
      softWrap: softWrap,
      style: style.copyWith(
        fontSize: fontSize ?? style.fontSize,
        fontWeight: fontWeight ?? style.fontWeight,
        height: height ?? style.height,
        color: color ?? style.color ?? context.color.textPrimary,
        decoration: decoration ?? style.decoration,
        fontFamily: family ?? style.fontFamily,
      ),
    );
  }
}
