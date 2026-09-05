import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CouponCard extends StatelessWidget {
  final String couponCode;
  final String message;
  final String expiryDate;
  final VoidCallback? onCopy;
  final VoidCallback? onRedeem;
  final String? appliedCouponName;
  final bool isLoading;

  const CouponCard({
    super.key,
    required this.couponCode,
    required this.expiryDate,
    this.onCopy,
    this.onRedeem,
    required this.message,
    this.appliedCouponName,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      clipBehavior: .antiAlias,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.color.outline,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          _buildCouponContainer(context),
          Align(
            alignment: const Alignment(-1.1, 0),
            child: _buildCouponCuts(context),
          ),
          Align(
            alignment: const Alignment(1.1, 0),
            child: _buildCouponCuts(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCuts(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: .circle,
      ),
    );
  }

  Widget _buildCouponContainer(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: context.color.darkColor,
            height: double.maxFinite,
            alignment: .center,
            child: RotatedBox(
              quarterTurns: 3,
              child: CustomText(
                AppLabels.coupon.tr.toUpperCase(),
                style: TextStyle(
                  fontSize: context.font.medium,
                  color: context.color.onPrimary,
                  fontWeight: .w500,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const .symmetric(horizontal: 22, vertical: 10),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                CustomText(
                  AppLabels.welcomeToSavings.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: .w500),
                ),
                CustomText(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(fontWeight: .w400),
                ),
                _buildCouponCode(context),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    if (expiryDate.isNotEmpty)
                      Column(
                        crossAxisAlignment: .start,
                        children: [
                          CustomText(
                            AppLabels.expiresOn.tr,
                            style: TextStyle(fontSize: context.font.small)
                                .copyWith(
                                  fontWeight: .w400,
                                  color: context.color.textSecondary,
                                ),
                          ),
                          CustomText(
                            expiryDate,
                            style: TextStyle(fontSize: context.font.small),
                          ),
                        ],
                      ),
                    const Spacer(),
                    isLoading
                        ? SizedBox(
                            height: 36,
                            width: 80,
                            child: Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.color.darkColor,
                                ),
                              ),
                            ),
                          )
                        : CustomButton(
                            height: null,
                            title: AppLabels.redeem.tr,
                            onPressed: onRedeem,
                            backgroundColor: context.color.darkColor,
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCouponCode(BuildContext context) {
    return CustomCard(
      height: 32,
      borderRadius: 4,
      padding: const .symmetric(horizontal: 12),
      margin: const .symmetric(vertical: 12),
      child: Row(
        children: [
          CustomText(
            couponCode.isNotEmpty ? couponCode : '',
            style: TextStyle(
              fontSize: context.font.small,
              fontWeight: .w500,
              color: context.color.textSecondary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onCopy,
            child: CustomImage(AppIcons.copy, color: context.color.textPrimary),
          ),
        ],
      ),
    );
  }
}
