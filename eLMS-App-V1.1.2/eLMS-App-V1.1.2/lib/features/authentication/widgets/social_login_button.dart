import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String iconPath;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final double borderRadius;
  final Color? iconColor;

  const SocialLoginButton({
    super.key,
    required this.onPressed,
    required this.iconPath,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.height = 48,
    this.width = double.infinity,
    this.borderRadius = 8,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CustomButton(
        type: CustomButtonType.outlined,
        onPressed: onPressed,
        customTitle: Row(
          mainAxisAlignment: .center,
          children: [
            CustomImage(iconPath, width: 24, height: 24, color: iconColor),
            const SizedBox(width: 12),
            Text(
              text,
              style: context.textTheme.bodyMedium?.copyWith(
                color: textColor ?? context.color.onSurface,
                fontWeight: .w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
