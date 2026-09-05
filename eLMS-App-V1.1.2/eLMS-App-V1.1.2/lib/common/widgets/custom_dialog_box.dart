import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/utils/extensions/color_extension.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

final class DialogButton {
  final String title;
  final VoidCallback? onTap;
  final Color? color;
  final DialogButtonStyle style;
  DialogButton({
    required this.title,
    this.onTap,
    this.color,
    required this.style,
  });
}

class CustomDialogBox extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? content;
  final List<DialogButton>? actions;
  final double actionSpacing;
  final bool showHeader;
  final TextStyle? subtitleStyle;
  final int subtitleMaxLines;

  const CustomDialogBox({
    super.key,
    this.content,
    this.title,
    this.actions,
    this.actionSpacing = 10,
    this.showHeader = true,
    this.subtitle,
    this.subtitleStyle,
    this.subtitleMaxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: .antiAlias,
      backgroundColor: context.color.surface,
      insetPadding: const .all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const .symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: .min,
          children: [
            if (showHeader) _buildHeader(context),
            const SizedBox(height: 10),
            if (content != null) Flexible(child: content!),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const .only(top: 10),
      child: Row(
        spacing: actionSpacing,
        children: [
          ...actions?.map((e) {
                final bool isOutlined = e.style == DialogButtonStyle.outlined;
                return Expanded(
                  child: CustomButton(
                    title: e.title,
                    onPressed: e.onTap,

                    backgroundColor: isOutlined
                        ? context.color.surface
                        : e.color,
                    borderColor: isOutlined ? e.color : null,
                    radius: 4,
                    height: 40,
                    textColor: e.onTap == null
                        ? context.color.outline.brighten(0.09)
                        : isOutlined
                        ? e.color
                        : e.color?.getAdaptiveTextColor(),
                    type: isOutlined
                        ? CustomButtonType.outlined
                        : CustomButtonType.primary,
                  ),
                );
              }) ??
              [],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  CustomText(
                    title ?? '',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(fontWeight: .w500),
                  ),
                  if (subtitle != null)
                    CustomText(
                      subtitle ?? '',
                      maxLines: subtitleMaxLines,
                      ellipsis: true,
                      style:
                          subtitleStyle ??
                          Theme.of(
                            context,
                          ).textTheme.titleMedium!.copyWith(fontWeight: .w500),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: CustomImage(
                AppIcons.closeCircle,
                color: context.color.textPrimary,
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
