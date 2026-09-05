import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/services/iap_manager.dart';
import 'package:elms/features/iap/models/iap_product_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class AddMoneyCard extends StatelessWidget {
  final IapProductModel product;
  final IapStoreProduct storeProduct;
  const AddMoneyCard({
    super.key,
    required this.product,
    required this.storeProduct,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        IapManager.instance.buyProduct(product.productId!);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Container(height: 34, color: context.color.primary),

            Expanded(
              child: Container(
                color: context.color.primary.withValues(alpha: 0.04),

                child: Column(
                  children: [
                    _buildTextDivider(
                      context,
                      text: 'You Pay',
                      padding: const .symmetric(vertical: 6),
                    ),
                    CustomText(
                      storeProduct.price,
                      fontWeight: .w500,
                      fontSize: context.font.xLarge,
                    ),
                    Expanded(
                      child: CustomCard(
                        color: context.color.surface,
                        margin: const .all(8),

                        width: double.maxFinite,
                        child: Column(
                          children: [
                            _buildTextDivider(
                              context,
                              text: 'You Get',
                              padding: const .only(bottom: 6, top: 2),
                            ),
                            CustomText(
                              product.creditValue.toString(),
                              fontWeight: .w500,
                              color: context.color.primary,
                              fontSize: context.font.xLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextDivider(
    BuildContext context, {
    required String text,
    EdgeInsets? padding,
  }) {
    return Padding(
      padding: padding ?? .zero,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    context.color.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CustomText(
              text,
              style: TextStyle(
                color: context.color.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: context.font.xxSmall,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.color.primary.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
