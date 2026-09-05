import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final List<String> tabs;
  final TabController? controller;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final Function(int)? onTap;
  final bool isScrollable;
  final double? height;
  final double? indicatorWeight;
  final bool useEllipsis;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.margin,
    this.padding,
    this.borderRadius = 100,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.onTap,
    this.isScrollable = false,
    this.height,
    this.indicatorWeight,
    this.useEllipsis = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = selectedColor ?? context.color.primary;
    final surfaceColor = backgroundColor ?? context.color.surface;
    final defaultBorderRadius = borderRadius ?? 100.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      margin:
          margin ??
          const EdgeInsetsDirectional.symmetric(
            horizontal: 16,
          ).add(const EdgeInsetsDirectional.only(top: 10)),
      padding: padding ?? const .all(6),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        isScrollable: isScrollable,
        tabs: tabs
            .map(
              (tab) => useEllipsis
                  ? Tab(
                      child: Text(
                        tab,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    )
                  : Tab(text: tab),
            )
            .toList(),
        dividerHeight: 0,
        splashBorderRadius: BorderRadius.circular(defaultBorderRadius),
        indicatorSize: .tab,
        indicatorWeight: indicatorWeight ?? 0,
        indicatorColor: primaryColor,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          color: primaryColor,
        ),
        labelStyle:
            labelStyle ??
            TextStyle(
              color: primaryColor.getAdaptiveTextColor(),
              fontWeight: .w500,
              height: 1.25,
            ),
        unselectedLabelStyle:
            unselectedLabelStyle ??
            TextStyle(
              color: unselectedColor ?? context.color.onSurface,
              fontWeight: .w500,
            ),
        labelColor: primaryColor.getAdaptiveTextColor(),
        unselectedLabelColor: unselectedColor ?? context.color.onSurface,
      ),
    );
  }
}

// Extension to get contrasting text color for a background color
extension ColorExtension on Color {
  Color getAdaptiveTextColor() {
    return computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
