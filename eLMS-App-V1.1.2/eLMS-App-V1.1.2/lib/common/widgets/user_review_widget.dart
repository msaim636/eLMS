import 'package:elms/common/models/user_review_model.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/tappable_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserReviewWidget extends StatelessWidget {
  final UserReviewModel review;
  final bool showCard;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const UserReviewWidget({
    super.key,
    required this.review,
    this.showCard = true,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: padding ?? const .all(8),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          // User info and rating row
          Row(
            children: [
              // User avatar
              _buildUserAvatar(context),
              const SizedBox(width: 16),
              // User name and review date
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    CustomText(
                      review.user.name,
                      style: TextStyle(
                        fontSize: context.font.small,
                        fontWeight: .w600,
                        color: context.color.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      review.createdAt,
                      style: TextStyle(
                        fontSize: context.font.xSmall,
                        color: context.color.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Rating pill
              Container(
                padding: const .symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.color.warning,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: .min,
                  children: [
                    CustomImage(
                      AppIcons.starFilled,
                      width: 13,
                      height: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    CustomText(
                      review.rating.ratingLabel,
                      style: TextStyle(
                        fontSize: context.font.small,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Review text
          CustomText(
            review.review,
            style: TextStyle(
              fontSize: context.font.small,
              color: context.color.textSecondary,
            ),
          ),
        ],
      ),
    );

    // Wrap with card if needed
    if (showCard) {
      return CustomCard(
        child: GestureDetector(onTap: onTap, child: content),
      );
    }

    return GestureDetector(onTap: onTap, child: content);
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: .circle,
        border: Border.all(color: context.color.onSurface, width: 0.83),
      ),
      padding: const .all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: TappableImage(review.user.avatar, fit: BoxFit.cover),
      ),
    );
  }
}

/// A widget to display a list of reviews
class ReviewsListWidget extends StatelessWidget {
  final List<UserReviewModel> reviews;
  final int maxReviews;
  final bool showViewAll;
  final VoidCallback? onViewAllTap;
  final EdgeInsetsGeometry? reviewPadding;

  const ReviewsListWidget({
    super.key,
    required this.reviews,
    this.maxReviews = 3,
    this.showViewAll = true,
    this.onViewAllTap,
    this.reviewPadding,
  });

  @override
  Widget build(BuildContext context) {
    // Determine how many reviews to show
    final displayedReviews = reviews.length > maxReviews && maxReviews > 0
        ? reviews.sublist(0, maxReviews)
        : reviews;

    return Column(
      crossAxisAlignment: .start,
      children: [
        // Reviews list
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: displayedReviews.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return UserReviewWidget(
              review: displayedReviews[index],
              padding: reviewPadding,
            );
          },
        ),

        // View all button if needed
        if (showViewAll && reviews.length > maxReviews)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 16),
            child: GestureDetector(
              onTap: onViewAllTap,
              child: Row(
                mainAxisAlignment: .center,
                children: [
                  CustomText(
                    AppLabels.viewAllReviews.tr,
                    style: TextStyle(
                      fontSize: context.font.small,
                      fontWeight: .w500,
                      color: context.color.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CustomImage(
                    AppIcons.right,
                    width: 16,
                    height: 16,
                    color: context.color.primary,
                    fit: .none,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
