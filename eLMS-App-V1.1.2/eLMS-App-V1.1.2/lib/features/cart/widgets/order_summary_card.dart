import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/cart/models/cart_response_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderSummaryCard extends StatelessWidget {
  final CartSummary summary;

  const OrderSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderRadius: 4,
      padding: const .all(12),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          // Title
          CustomText(
            AppLabels.orderSummary.tr,
            style: TextStyle(
              fontSize: context.font.medium,
              fontWeight: .w500,
              color: context.color.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Column(
            spacing: 10,
            children: [
              _buildRow(
                context,
                label: AppLabels.coursePriceMrp.tr,
                value: "${summary.displayPrice}".currency,
              ),
              _buildRow(
                context,
                label: AppLabels.courseDiscountLabel.tr,
                value: "${summary.discount}".currency,
                deduct: true,
              ),
              const Divider(height: 1),
              _buildRow(
                context,
                label: AppLabels.subtotalAfterOffer.tr,
                value: "${summary.subtotal}".currency,
                isHighlighted: true,
                valueColor: context.color.textPrimary,
              ),
              if (summary.appliedCouponCode != null)
                _buildRow(
                  context,
                  label: AppLabels.couponDiscountWithCode.translateWithTemplate(
                    {'code': summary.appliedCouponCode ?? ''},
                  ),
                  value: "${summary.couponDiscount}".currency,
                  deduct: true,
                ),
              const Divider(height: 1),
              _buildRow(
                context,
                label: AppLabels.taxableAmount.tr,
                value: "${summary.subtotal - (summary.couponDiscount ?? 0)}"
                    .currency,
              ),
              _buildRow(
                context,
                label: AppLabels.taxWithPercentage.translateWithTemplate({
                  'percentage': '${summary.taxPercentage}',
                }),
                value: "${summary.totalTaxAmount}".currency,
              ),
              const Divider(height: 1),
              _buildRow(
                context,
                label: AppLabels.totalPay.tr,
                value: "${summary.finalTotal}".currency,
                isHighlighted: true,
                valueColor: context.color.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isHighlighted = false,
    Color? valueColor,
    bool deduct = false,
  }) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        CustomText(
          label,
          style: TextStyle(
            fontSize: context.font.small,
            fontWeight: isHighlighted ? .w500 : .w400,
            color: isHighlighted
                ? context.color.onSurface
                : context.color.textSecondary,
          ),
        ),
        CustomText(
          (deduct ? "-" : "") + value,
          style: TextStyle(
            fontSize: context.font.small,
            fontWeight: isHighlighted ? .w500 : .w400,
            color: isHighlighted
                ? valueColor ?? context.color.onSurface
                : context.color.primary,
          ),
        ),
      ],
    );
  }
}
