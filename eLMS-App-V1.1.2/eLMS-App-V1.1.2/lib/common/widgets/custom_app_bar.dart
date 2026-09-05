import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/common/widgets/custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userName;
  final String? title;
  final Widget? customTitle;
  final bool showBackButton;
  final List<Widget> actions;
  final double height;
  final VoidCallback? onTapBack;

  const CustomAppBar({
    super.key,
    this.userName,
    this.title,
    this.showBackButton = false,
    this.actions = const [],
    this.customTitle,
    this.height = kToolbarHeight + 10,
    this.onTapBack,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.color.surface,
      elevation: 3,
      shadowColor: context.color.outline.withValues(alpha: 0.4),
      child: Padding(
        padding: const .symmetric(horizontal: 16, vertical: 10),
        child: SafeArea(
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  onPressed: onTapBack ?? () => Navigator.pop(context),
                  icon: CustomImage(
                    AppIcons.arrowLeft,
                    color: context.color.onSurface,
                  ),
                ),
              Expanded(
                child:
                    customTitle ??
                    CustomText(
                      title ?? '',
                      style: TextStyle(fontSize: context.font.xxLarge),
                      softWrap: true,
                      ellipsis: true,
                      maxLines: 1,
                    ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
