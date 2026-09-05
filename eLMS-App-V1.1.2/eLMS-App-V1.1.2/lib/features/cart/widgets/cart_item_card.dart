import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_inkwell.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/cart/models/cart_item_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartItemCard extends StatelessWidget {
  final CartItemDisplayModel cartItem;
  final VoidCallback? onRemove;
  final VoidCallback? onMoveToWishlist;

  const CartItemCard({
    super.key,
    required this.cartItem,
    this.onRemove,
    this.onMoveToWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderColor: context.color.outline,
      padding: const .all(10),
      child: Column(
        spacing: 8,
        children: [
          _buildCourseInfo(context),
          Divider(height: 1, color: context.color.outline),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildCourseInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: .start,
      spacing: 8,
      children: [
        // Course Image
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: CustomImage(
            cartItem.imageUrl,
            width: 87,
            height: 87,
            fit: .cover,
          ),
        ),

        // Course Details
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              // Rating
              _buildRatings(context),
              const SizedBox(height: 7),
              _buildCourseTitleAndInstructor(context),
              // Price
              _buildPriceSection(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatings(BuildContext context) {
    return Row(
      children: [
        CustomImage(AppIcons.cartStar, width: 16, height: 16),
        const SizedBox(width: 2),
        CustomText(
          '${cartItem.rating.ratingLabel} (${cartItem.reviewCount})',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: context.color.onSurface),
        ),
      ],
    );
  }

  Widget _buildCourseTitleAndInstructor(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          cartItem.courseTitle,
          style: TextStyle(
            fontSize: context.font.medium,
            fontWeight: .w400,
            color: context.color.onSurface,
            height: 1.1,
          ),
          maxLines: 2,
          ellipsis: true,
        ),
        CustomText(
          cartItem.instructorName,
          style: TextStyle(
            fontSize: context.font.xSmall,
            color: context.color.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Row(
      spacing: 2,
      children: [
        CustomText(
          cartItem.discountedPrice.toStringAsFixed(2).currency,
          style: TextStyle(
            fontSize: context.font.medium,
            fontWeight: .w600,
            color: context.color.onSurface,
          ),
        ),
        if (cartItem.originalPrice > cartItem.discountedPrice)
          CustomText(
            cartItem.originalPrice.toStringAsFixed(2).currency,
            style: TextStyle(
              fontSize: context.font.small,
              decoration: TextDecoration.lineThrough,
              decorationThickness: 2,
              decorationColor: Colors.grey,
              color: context.color.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 8),
      child: Row(
        children: [
          // Remove Button
          Expanded(
            child: CustomInkWell(
              color: context.color.surface,
              onTap: onRemove,
              child: Row(
                mainAxisAlignment: .center,
                children: [
                  CustomImage(
                    AppIcons.deleteOutlined,
                    width: 24,
                    height: 24,
                    color: context.color.primary,
                  ),
                  const SizedBox(width: 6),
                  CustomText(
                    AppLabels.remove.tr,
                    style: TextStyle(
                      fontSize: context.font.small,
                      color: context.color.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Divider
          Container(height: 16, width: 1, color: context.color.outline),

          // Move to Wishlist Button
          Expanded(
            child: CustomInkWell(
              color: context.color.surface,
              onTap: onMoveToWishlist,
              child: Row(
                mainAxisAlignment: .center,
                children: [
                  CustomImage(
                    AppIcons.wishlistIcon,
                    width: 16,
                    height: 16,
                    color: context.color.primary,
                  ),
                  const SizedBox(width: 6),
                  CustomText(
                    AppLabels.moveToWishlist.tr,
                    style: TextStyle(
                      fontSize: context.font.small,
                      color: context.color.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
