import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class CustomExpandableTile extends StatefulWidget {
  final String? title;
  final Widget? customTitle;
  final String? subtitle;
  final Widget content;
  final bool? isExpanded;
  final VoidCallback onToggle;
  final EdgeInsetsGeometry? padding;
  final Color? titleColor;
  final Color? subtitleColor;
  final double? titleFontSize;
  final double? subtitleFontSize;
  final FontWeight? titleFontWeight;
  final FontWeight? subtitleFontWeight;
  final Widget? customIcon;
  final Color? dividerColor;
  final bool? isIconTop;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool? highlightTitle;

  const CustomExpandableTile({
    super.key,

    this.title,
    this.highlightTitle,
    this.backgroundColor,
    this.customTitle,
    required this.content,
    this.isExpanded,
    required this.onToggle,
    this.subtitle,
    this.padding,
    this.titleColor,
    this.subtitleColor,
    this.titleFontSize,
    this.subtitleFontSize,
    this.titleFontWeight,
    this.subtitleFontWeight,
    this.customIcon,
    this.dividerColor,
    this.isIconTop,
    this.borderColor,
    this.borderRadius,
  });

  @override
  State<CustomExpandableTile> createState() => _CustomExpandableTileState();
}

class _CustomExpandableTileState extends State<CustomExpandableTile> {
  late bool isExpanded = widget.isExpanded ?? false;

  @override
  void didUpdateWidget(covariant CustomExpandableTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded &&
        widget.isExpanded != null) {
      isExpanded = widget.isExpanded!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets resolvedPadding =
        (widget.padding ?? const EdgeInsets.all(10)).resolve(
          Directionality.of(context),
        );

    final EdgeInsets contentPadding = EdgeInsets.only(
      left: resolvedPadding.left,
      right: resolvedPadding.right,
      top: resolvedPadding.top,
      bottom: resolvedPadding.bottom,
    );

    return CustomCard(
      color: widget.backgroundColor,
      borderColor: widget.borderColor,
      borderRadius: widget.borderRadius ?? 8,
      child: Column(
        children: [
          // Header with expand/collapse button
          Stack(
            children: [
              ///THis is the header background color
              Positioned.fill(
                child: Container(
                  color: (isExpanded == true && widget.highlightTitle == true)
                      ? context.color.textSecondary.withValues(alpha: 0.12)
                      : Colors.transparent,
                ),
              ),
              Padding(
                padding: resolvedPadding,
                child: Column(
                  children: [
                    GestureDetector(
                      behavior: .opaque,
                      onTap: () {
                        isExpanded = !isExpanded;
                        setState(() {});
                        widget.onToggle.call();
                      },
                      child: Row(
                        crossAxisAlignment: widget.isIconTop == true
                            ? .start
                            : .center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                if (widget.customTitle != null) ...[
                                  widget.customTitle!,
                                ] else ...[
                                  CustomText(
                                    widget.title ?? '',
                                    style:
                                        TextStyle(
                                          fontSize: context.font.medium,
                                          fontWeight: FontWeight.w500,
                                        ).copyWith(
                                          fontSize: widget.titleFontSize,
                                          fontWeight:
                                              widget.titleFontWeight ?? .w500,
                                          color:
                                              widget.titleColor ??
                                              context.color.onSurface,
                                        ),
                                  ),
                                  if (widget.subtitle != null) ...[
                                    const SizedBox(height: 4),
                                    CustomText(
                                      widget.subtitle!,
                                      style:
                                          TextStyle(
                                            fontSize: context.font.xSmall,
                                          ).copyWith(
                                            fontSize: widget.subtitleFontSize,
                                            color:
                                                widget.subtitleColor ??
                                                context.color.textSecondary,
                                          ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),
                          Container(
                            decoration: const BoxDecoration(shape: .circle),
                            child: Center(
                              child: AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 300),
                                child:
                                    widget.customIcon ??
                                    CustomImage(
                                      AppIcons.arrowDown,
                                      width: 20,
                                      height: 20,
                                      color: context.color.onSurface,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ],
          ),
          // Content (shown only when expanded)
          if (isExpanded) ...[
            OverflowBox(
              maxWidth: context.screenWidth,
              maxHeight: 1,
              fit: .deferToChild,
              child: Divider(
                height: 12,
                thickness: 1,
                indent: 0,
                endIndent: 0,
                color: widget.dividerColor ?? context.color.outline,
              ),
            ),
            Padding(padding: contentPadding, child: widget.content),
          ],
        ],
      ),
    );
  }
}
