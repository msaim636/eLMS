import 'package:elms/common/models/review_model.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/rating_bar_widget.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';

class RatingsWidget extends StatelessWidget {
  final String ratingTitle;
  final ReviewModel reviewData;
  final bool showCard;

  const RatingsWidget({
    super.key,
    required this.reviewData,
    this.showCard = true,
    required this.ratingTitle,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: const .symmetric(vertical: 8, horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _buildLayout(context);
        },
      ),
    );

    return showCard ? CustomCard(child: content) : content;
  }

  Widget _buildLayout(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Row(
                  mainAxisSize: .min,
                  spacing: 6,
                  children: [
                    CustomText(
                      reviewData.averageRating.ratingLabel,
                      style: TextStyle(
                        fontSize: context.font.xxxLarge,
                      ).copyWith(color: context.color.onSurface),
                    ),

                    CustomImage(
                      AppIcons.starFilled,
                      width: 14,
                      height: 14,
                      color: context.color.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                CustomText(
                  '${reviewData.totalReviews} $ratingTitle',
                  style: TextStyle(
                    fontSize: context.font.small,
                    color: context.color.onSurface,
                  ),
                  textAlign: .center,
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 100,
            color: context.color.textSecondary.withValues(alpha: 0.14),
            margin: const .symmetric(horizontal: 12),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: .center,
              spacing: 8,
              children: [
                _buildRatingBar(
                  context,
                  5,
                  reviewData.ratingDistribution.fiveStarsPercentage,
                ),
                _buildRatingBar(
                  context,
                  4,
                  reviewData.ratingDistribution.fourStarsPercentage,
                ),
                _buildRatingBar(
                  context,
                  3,
                  reviewData.ratingDistribution.threeStarsPercentage,
                ),
                _buildRatingBar(
                  context,
                  2,
                  reviewData.ratingDistribution.twoStarsPercentage,
                ),
                _buildRatingBar(
                  context,
                  1,
                  reviewData.ratingDistribution.oneStarPercentage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(BuildContext context, int starCount, num percentage) {
    return Row(
      children: [
        // Progress bar
        Expanded(
          flex: 3,
          child: Container(
            height: 11,
            margin: const EdgeInsetsDirectional.only(end: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: starCount <= 2
                    ? context.color.textSecondary
                    : context.color.textSecondary,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1.5),
              child: Row(
                children: [
                  // Filled portion based on percentage
                  if (percentage > 0)
                    Expanded(
                      flex: percentage.toInt(),
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(color: context.color.warning),
                      ),
                    ),
                  // Remaining unfilled portion
                  if (percentage < 100)
                    Expanded(
                      flex: 100 - percentage.toInt(),
                      child: Container(),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Stars and percentage - fixed width section
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Rating.bar(
              filledStarCount: starCount,

              starSize: 10,
              starSpacing: 2,
            ),
            SizedBox(
              width: 32,
              child: CustomText(
                '$percentage%',
                style: TextStyle(
                  fontSize: context.font.xxSmall,
                  fontWeight: FontWeight.w500,
                  color: context.color.textSecondary,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
