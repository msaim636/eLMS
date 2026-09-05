import 'package:elms/common/models/review_model.dart';
import 'package:elms/common/models/user_review_model.dart';
import 'package:elms/common/widgets/ratings_widget.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/user_review_widget.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewsWidget extends StatelessWidget {
  final String? sectionTitle;
  final String? reviewsTitle;
  final ReviewModel reviewData;
  final List<UserReviewModel> userReviews;
  final int maxReviews;
  final VoidCallback? onViewAllReviewsTap;

  const ReviewsWidget({
    super.key,
    required this.reviewData,
    required this.userReviews,
    this.maxReviews = 3,
    this.onViewAllReviewsTap,
    this.sectionTitle,
    this.reviewsTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        if (sectionTitle != null) ...{
          CustomText(
            sectionTitle!,
            style: TextStyle(
              fontSize: context.font.medium,
              fontWeight: FontWeight.w500,
            ),
            fontWeight: .w500,
            color: context.color.onSurface,
          ),
          const SizedBox(height: 12),
        },

        RatingsWidget(
          reviewData: reviewData,
          ratingTitle: reviewData.totalReviews <= 1
              ? AppLabels.courseReview.tr
              : AppLabels.courseReviews.tr,
        ),
        // User reviews list
        if (userReviews.isNotEmpty) ...[
          if (reviewsTitle != null) ...{
            const SizedBox(height: 16),
            CustomText(
              reviewsTitle!,
              style: TextStyle(
                fontSize: context.font.medium,
                fontWeight: FontWeight.w500,
              ),
              fontWeight: .w500,
              color: context.color.onSurface,
            ),
          },
          const SizedBox(height: 12),
          ReviewsListWidget(
            reviews: userReviews,
            maxReviews: maxReviews,
            onViewAllTap: onViewAllReviewsTap,
          ),
        ],
      ],
    );
  }
}
