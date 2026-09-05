import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elms/utils/extensions/context_extension.dart';

class CustomNoInternetWidget extends StatelessWidget {
  final String? titleKey;
  final String? illustrator;
  final double? illustratorSize;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final String? buttonText;

  const CustomNoInternetWidget({
    super.key,
    this.titleKey,
    this.illustrator,
    this.illustratorSize = 200,
    this.onRetry,
    this.showRetryButton = true,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const .all(16),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            CustomImage(
              illustrator ?? AppIcons.noInternetIllustrator,
              height: illustratorSize,
              width: illustratorSize,
            ),
            const SizedBox(height: 24),
            Text(
              (titleKey ?? AppLabels.noInternetConnection).tr,
              textAlign: .center,
              style: TextStyle(fontSize: context.font.medium),
            ),
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(buttonText ?? AppLabels.retry.tr),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
