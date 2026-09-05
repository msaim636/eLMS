import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_no_internet_widget.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elms/utils/extensions/context_extension.dart';

class CustomErrorWidget<T> extends StatelessWidget {
  final T error;
  final String? title;
  final String? illustrator;
  final String? buttonText;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final double? illustratorSize;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final EdgeInsetsGeometry? padding;

  const CustomErrorWidget({
    super.key,
    required this.error,
    this.title,
    this.illustrator,
    this.buttonText,
    this.onRetry,
    this.showRetryButton = true,
    this.illustratorSize = 200,
    this.titleStyle,
    this.messageStyle,
    this.padding = const .all(16),
  });

  factory CustomErrorWidget.fromErrorState({
    required ErrorState errorState,
    String? title,
    String? illustrator,
    String? buttonText,
    VoidCallback? onRetry,
    bool showRetryButton = true,
    double? illustratorSize,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    EdgeInsetsGeometry? padding,
  }) {
    return CustomErrorWidget(
      error: errorState.error,
      title: title,
      illustrator: illustrator,
      buttonText: buttonText,
      onRetry: onRetry,
      showRetryButton: showRetryButton,
      illustratorSize: illustratorSize,
      titleStyle: titleStyle,
      messageStyle: messageStyle,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if the error is a no-internet error
    if (error is NoInternetException) {
      return CustomNoInternetWidget(
        onRetry: onRetry,
        showRetryButton: showRetryButton,
        buttonText: buttonText,
        illustratorSize: illustratorSize,
      );
    }
    final exception = UiUtils.friendlyErrorMessage(error as Object);

    return Center(
      child: Padding(
        padding: padding ?? .zero,
        child: Column(
          mainAxisAlignment: .center,
          children: [
            CustomImage(
              illustrator ?? AppIcons.errorIllustrator,
              height: illustratorSize,
              width: illustratorSize,
            ),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                textAlign: .center,
                style: titleStyle ?? TextStyle(fontSize: context.font.xxLarge),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              exception,
              textAlign: .center,
              style: messageStyle ?? TextStyle(fontSize: context.font.medium),
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
