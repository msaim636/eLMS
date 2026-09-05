import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/rating_bar_widget.dart';
import 'package:elms/common/widgets/restricted_widget.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/login/guest_checker.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/cart/cubit/cart_cubit.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class WishlistCard extends StatelessWidget {
  final CourseModel wishlistItem;
  final VoidCallback? onRemoveFromWishlist;

  const WishlistCard({
    super.key,
    required this.wishlistItem,
    this.onRemoveFromWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _onTapCard(context);
      },
      child: CustomCard(
        borderRadius: 6,
        height: 177,
        border: 0,
        padding: const .all(8),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _buildDetailsContainer(context),
            Divider(height: 1, color: context.color.outline),
            Expanded(
              child: Align(
                alignment: .centerRight,
                child: _buildRemoveFromWishlistButton(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapCard(BuildContext context) {
    // Navigate using slug since wishlist API returns incorrect id
    if (wishlistItem.isEnrolled) {
      // Guard: if wallet is negative (iOS refund), block access to purchased course.
      final balance = context.read<AuthenticationCubit>().totalBalance ?? 0;
      if (balance < 0) {
        NegativeWalletCourseAccessDialog.show(context);
        return;
      }

      Get.toNamed(
        AppRoutes.courseContentScreen,
        arguments: CourseContentScreenArguments(
          course: wishlistItem,
          // slug: wishlistItem.slug,
        ),
      );
    } else {
      Get.toNamed(
        AppRoutes.courseDetailsScreen,
        arguments: CourseDetailsScreenArguments(
          course: wishlistItem,
          // slug: wishlistItem.slug,
        ),
      );
    }
  }

  Widget _buildDetailsContainer(BuildContext context) {
    return Padding(
      padding: const .only(bottom: 8),
      child: SizedBox(
        height: 120,
        child: Row(
          crossAxisAlignment: .stretch,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: .start,
                mainAxisAlignment: .spaceEvenly,
                spacing: 4,
                children: [
                  _buildRatings(context),
                  _buildCourseTitle(context),
                  _buildInstructor(context),
                  const SizedBox(height: 4),
                  _buildPrice(context),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: .stretch,
                spacing: 6,
                children: [
                  Expanded(
                    child: CustomImage(
                      wishlistItem.image,
                      radius: 4,
                      fit: .cover,
                    ),
                  ),
                  if (!wishlistItem.isFree && !wishlistItem.isEnrolled)
                    _buildAddToCartButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatings(BuildContext context) {
    return Rating.number(
      rating: wishlistItem.averageRating.toDouble(),
      ratingCount: wishlistItem.ratings,
    );
  }

  Widget _buildCourseTitle(BuildContext context) {
    return CustomText(
      wishlistItem.title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall!.copyWith(fontWeight: .w600),
      maxLines: 2,
      ellipsis: true,
    );
  }

  Widget _buildInstructor(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'By ',
        children: [
          TextSpan(
            text: wishlistItem.authorName,
            style: TextStyle(
              color: context.color.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
        style: TextStyle(
          fontSize: context.font.xSmall,
          color: context.color.textSecondary,
        ),
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    return Row(
      spacing: 6,
      children: [
        if (wishlistItem.isEnrolled) ...[
          CustomText(
            AppLabels.enrolled.tr,
            style: TextStyle(
              fontSize: context.font.medium,
              fontWeight: .w600,
              color: Colors.green,
            ),
          ),
        ] else if (wishlistItem.isFree) ...[
          CustomText(
            AppLabels.free.tr,
            style: TextStyle(
              fontSize: context.font.medium,
              fontWeight: .w600,
              color: context.color.primary,
            ),
          ),
        ] else ...[
          CustomText(
            wishlistItem.finalPrice.toString().currency,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(fontWeight: .w600),
          ),
          if (wishlistItem.hasDiscount)
            CustomText(
              wishlistItem.price.toString().currency,
              style: TextStyle(
                fontSize: 12,
                color: context.color.textSecondary,
                decoration: TextDecoration.lineThrough,
                decorationThickness: 2,
                decorationColor: Colors.grey,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final bool isAddedInCart = context.read<CartCubit>().isAddedInCart(
          wishlistItem.id,
        );
        final bool isLoading =
            state is UpdateCartInProgress && state.id == wishlistItem.id;

        return CustomButton(
          title: isAddedInCart
              ? AppLabels.removeFromCart.tr
              : AppLabels.addToCart.tr,
          onPressed: isLoading ? null : () => _onCartToggle(context),
          height: 36,
          textSize: 16,
          padding: const .symmetric(horizontal: 2),
        );
      },
    );
  }

  void _onCartToggle(BuildContext context) {
    GuestChecker.check(
      onNotGuest: () {
        context.read<CartCubit>().toggleCart(wishlistItem.id);
      },
    );
  }

  Widget _buildRemoveFromWishlistButton(BuildContext context) {
    return GestureDetector(
      onTap: onRemoveFromWishlist,
      child: CustomText(
        AppLabels.removeFromWishlist.tr,
        style: TextStyle(
          fontSize: context.font.xSmall,
          color: context.color.error,
          fontWeight: .w500,
        ),
      ),
    );
  }
}
