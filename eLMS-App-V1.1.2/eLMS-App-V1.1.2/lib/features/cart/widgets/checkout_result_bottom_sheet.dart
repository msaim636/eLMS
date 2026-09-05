import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class CheckoutResultBottomSheet extends StatelessWidget {
  final bool isSuccess;
  final String txn;
  final double amount;
  final VoidCallback onAction;

  const CheckoutResultBottomSheet({
    super.key,
    required this.isSuccess,
    required this.onAction,
    required this.txn,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .all(20),
      child: Column(
        mainAxisSize: .min,
        children: [
          CustomImage(
            isSuccess ? AppIcons.success : AppIcons.fail,
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 20),
          CustomCard(
            color: context.color.outline.withValues(alpha: 0.4),
            width: context.screenWidth,
            padding: const EdgeInsetsGeometry.all(16),
            child: Column(
              spacing: 16,
              children: [
                CustomText(
                  isSuccess
                      ? AppLabels.paymentSuccess.tr
                      : AppLabels.paymentFailed.tr,
                  style: TextStyle(
                    fontSize: context.font.medium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                CustomText(
                  isSuccess
                      ? AppLabels.paymentSuccessMessage.translateWithTemplate({
                          'amount': amount.toString().currency,
                        })
                      : AppLabels.paymentFailedMessage.tr,
                  style: TextStyle(fontSize: context.font.small),
                ),
                CustomButton(
                  title: isSuccess
                      ? AppLabels.accessCourse.tr
                      : AppLabels.tryAgain.tr,
                  onPressed: onAction,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
