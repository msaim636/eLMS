import 'package:elms/features/cart/models/cart_response_model.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_inkwell.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/cart/cubit/cart_cubit.dart';
import 'package:elms/features/wishlist/cubit/wishlist_action_cubit.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CartCourseCard extends StatefulWidget {
  final CartCourseModel course;
  final VoidCallback? onRemoveFromCart;

  const CartCourseCard({
    super.key,
    required this.course,
    this.onRemoveFromCart,
  });

  @override
  State<CartCourseCard> createState() => _CartCourseCardState();
}

class _CartCourseCardState extends State<CartCourseCard> {
  late bool _isWishlisted;

  @override
  void initState() {
    super.initState();
    _isWishlisted = widget.course.isWishlisted;
  }

  @override
  void didUpdateWidget(CartCourseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.course.isWishlisted != widget.course.isWishlisted) {
      _isWishlisted = widget.course.isWishlisted;
    }
  }

  void _onToggleWishlist(BuildContext context) {
    context.read<WishlistActionCubit>().toggleWishlist(
      courseId: widget.course.id,
      currentWishlistState: _isWishlisted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WishlistActionCubit, WishlistActionState>(
      listener: (context, state) {
        if (state is WishlistActionSuccess &&
            state.courseId == widget.course.id) {
          setState(() {
            _isWishlisted = state.isWishlisted;
          });
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.color.success,
            ),
          );
        } else if (state is WishlistActionError &&
            state.courseId == widget.course.id) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: context.color.error,
            ),
          );
        }
      },
      child: CustomCard(
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
            widget.course.thumbnail,
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
              // Rating (static - not available in API)
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
          '${widget.course.averageRating.ratingLabel} (${widget.course.ratings})',
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
          widget.course.title,
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
          widget.course.instructor,
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
        if (widget.course.effectivePrice == 0) ...[
          CustomText(
            'free'.tr,
            style: TextStyle(
              fontSize: context.font.medium,
              fontWeight: .w600,
              color: context.color.success,
            ),
          ),
        ] else ...[
          CustomText(
            widget.course.effectivePrice.toStringAsFixed(2).currency,
            style: TextStyle(
              fontSize: context.font.medium,
              fontWeight: .w600,
              color: context.color.onSurface,
            ),
          ),
        ],
        if (widget.course.subtotal > 0 &&
            widget.course.subtotal != widget.course.originalPrice)
          CustomText(
            widget.course.originalPrice.toStringAsFixed(2).currency,
            style: TextStyle(
              fontSize: context.font.small,
              decoration: TextDecoration.lineThrough,
              decorationThickness: 2,
              decorationColor: Colors.grey,
              fontWeight: .w400,
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
          Expanded(child: _buildRemoveButton(context)),
          // Divider
          Container(height: 16, width: 1, color: context.color.outline),
          // Wishlist Toggle Button
          Expanded(child: _buildWishlistToggleButton(context)),
        ],
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final bool isLoading =
            state is UpdateCartInProgress && state.id == widget.course.id;

        return CustomInkWell(
          color: context.color.surface,
          onTap: isLoading ? null : widget.onRemoveFromCart,
          child: Row(
            mainAxisAlignment: .center,
            children: [
              isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : CustomImage(
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
        );
      },
    );
  }

  Widget _buildWishlistToggleButton(BuildContext context) {
    return BlocBuilder<WishlistActionCubit, WishlistActionState>(
      builder: (context, state) {
        final isLoading =
            state is WishlistActionInProgress &&
            state.courseId == widget.course.id;

        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: CustomInkWell(
            color: context.color.surface,

            onTap: isLoading ? null : () => _onToggleWishlist(context),
            child: Row(
              mainAxisAlignment: .center,
              children: [
                isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : CustomImage(
                        _isWishlisted
                            ? AppIcons.wishlist
                            : AppIcons.wishlistIcon,
                        width: 16,
                        height: 16,
                        color: context.color.primary,
                      ),
                const SizedBox(width: 6),
                Expanded(
                  child: CustomText(
                    _isWishlisted
                        ? AppLabels.removeFromWishlist.tr
                        : AppLabels.addToWishlist.tr,
                    style: TextStyle(
                      fontSize: context.font.small,
                      color: context.color.onSurface,
                    ),
                    maxLines: 1,
                    ellipsis: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
