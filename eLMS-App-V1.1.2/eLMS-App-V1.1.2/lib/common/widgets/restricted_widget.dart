import 'dart:io';

import 'package:elms/common/enums.dart';

import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Warning dialog shown when a user with a negative wallet balance (caused by
/// an iOS IAP refund) tries to access a purchased course.
///
/// On iOS an "Add Money" button is provided alongside a Cancel button.
/// On other platforms only the Cancel button is shown.
class NegativeWalletCourseAccessDialog extends StatefulWidget {
  const NegativeWalletCourseAccessDialog._();

  /// Shows the dialog and resolves when dismissed.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const NegativeWalletCourseAccessDialog._(),
    );
  }

  @override
  State<NegativeWalletCourseAccessDialog> createState() =>
      _NegativeWalletCourseAccessDialogState();
}

class _NegativeWalletCourseAccessDialogState
    extends State<NegativeWalletCourseAccessDialog> {
  void _onTapAddMoney() {
    Navigator.of(context).pop();
    Get.toNamed(AppRoutes.addMoneyScreen);
  }

  void _onTapCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.color.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.color.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: CustomImage(
                AppIcons.warning,
                width: 60,
                height: 60,
                fit: BoxFit.none,
              ),
            ),
            const SizedBox(height: 20),
            CustomText(
              AppLabels.negativeWalletCourseAccessTitle.tr,
              textAlign: TextAlign.center,
              fontSize: context.font.medium,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 12),
            CustomText(
              AppLabels.negativeWalletCourseAccessDescription.tr,
              textAlign: TextAlign.center,
              fontSize: context.font.small,
              fontWeight: FontWeight.w400,
            ),
            const SizedBox(height: 24),
            if (Platform.isIOS) ...[
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  title: AppLabels.addMoney.tr,
                  onPressed: _onTapAddMoney,
                  height: 48,
                  radius: 8,
                  fullWidth: true,
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                title: AppLabels.cancel.tr,
                onPressed: _onTapCancel,
                height: 48,
                radius: 8,
                fullWidth: true,
                type: CustomButtonType.outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Warning dialog shown when a user with a negative wallet balance (caused by
/// an iOS IAP refund) tries to make a new course purchase.
///
/// On iOS an "Add Money" button is provided alongside a Cancel button.
/// On other platforms only the Cancel button is shown.
class NegativeWalletPurchaseDialog extends StatefulWidget {
  const NegativeWalletPurchaseDialog._();

  /// Shows the dialog and resolves when dismissed.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const NegativeWalletPurchaseDialog._(),
    );
  }

  @override
  State<NegativeWalletPurchaseDialog> createState() =>
      _NegativeWalletPurchaseDialogState();
}

class _NegativeWalletPurchaseDialogState
    extends State<NegativeWalletPurchaseDialog> {
  void _onTapAddMoney() {
    Navigator.of(context).pop();
    Get.toNamed(AppRoutes.addMoneyScreen);
  }

  void _onTapCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.color.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.color.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: CustomImage(
                AppIcons.warning,
                width: 60,
                height: 60,
                fit: BoxFit.none,
              ),
            ),
            const SizedBox(height: 20),
            CustomText(
              AppLabels.negativeWalletPurchaseTitle.tr,
              textAlign: TextAlign.center,
              fontSize: context.font.medium,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 12),
            CustomText(
              AppLabels.negativeWalletPurchaseDescription.tr,
              textAlign: TextAlign.center,
              fontSize: context.font.small,
              fontWeight: FontWeight.w400,
            ),
            const SizedBox(height: 24),
            if (Platform.isIOS) ...[
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  title: AppLabels.addMoney.tr,
                  onPressed: _onTapAddMoney,
                  height: 48,
                  radius: 8,
                  fullWidth: true,
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                title: AppLabels.cancel.tr,
                onPressed: _onTapCancel,
                height: 48,
                radius: 8,
                fullWidth: true,
                type: CustomButtonType.outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
