import 'package:elms/common/enums.dart';
import 'package:elms/common/models/user_review_model.dart';
import 'package:elms/common/widgets/animated_showmore_container.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/rating_bar_widget.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

class CurrentUserReview extends StatelessWidget {
  final MyReviewModel myReview;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CurrentUserReview({
    super.key,
    required this.myReview,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const .all(16),
      child: Column(
        spacing: 16,
        crossAxisAlignment: .start,
        children: [
          _buildHeader(context),
          _buildContent(context),
          _buildActionBar(context),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: CustomButton(
            title: AppLabels.editReview.tr,
            height: 36,
            textSize: 12,
            onPressed: onEdit,
            backgroundColor: context.color.textPrimary,
          ),
        ),
        Expanded(
          child: CustomButton(
            title: AppLabels.delete.tr,
            height: 36,
            textSize: 12,
            type: CustomButtonType.outlined,
            onPressed: onDelete,
            textColor: context.color.error,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            CustomText(
              AppLabels.myReview.tr,
              style: TextStyle(
                fontSize: context.font.small,
                fontWeight: FontWeight.w500,
              ),
            ),
            Rating.bar(
              filledStarCount: myReview.rating.toInt(),

              starStyle: RatingStarStyle.filled,
              showRatingCount: true,
            ),
          ],
        ),
        CustomText(
          myReview.createdAt,
          style: TextStyle(
            fontSize: context.font.xSmall,
            color: context.color.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return AnimatedShowMore(
      content: myReview.review,
      maxLines: 6,
      textStyle: Theme.of(
        context,
      ).textTheme.bodySmall!.copyWith(fontWeight: .w400),
    );
  }
}
