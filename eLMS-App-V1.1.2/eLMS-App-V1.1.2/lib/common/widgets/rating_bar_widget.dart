import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';

class Rating extends StatelessWidget {
  final WidgetBuilder builder;
  const Rating({super.key, required this.builder});
  factory Rating.bar({
    required int filledStarCount,
    int starCount = 5,
    double starSize = 16,
    double starSpacing = 5,
    RatingStarStyle starStyle = RatingStarStyle.outlined,
    bool showRatingCount = false,
    bool showRatingPercentage = false,
  }) {
    int getPercentage() {
      return ((filledStarCount / starCount) * 100).round();
    }

    return Rating(
      builder: (context) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: starSpacing,
        children: [
          ...List.generate(starCount, (index) {
            final bool isFilled = index < filledStarCount;

            // Determine which icon to use based on style
            final String icon;
            final Color iconColor;

            if (starStyle == RatingStarStyle.filled) {
              // Filled style: use filled icon with different colors
              icon = AppIcons.starFilled;
              iconColor = isFilled
                  ? context.color.warning
                  : context.color.outline;
            } else {
              icon = isFilled ? AppIcons.starFilled : AppIcons.star;
              iconColor = isFilled
                  ? context.color.warning
                  : context.color.outline;
            }

            return CustomImage(
              icon,
              height: starSize,
              width: starSize,
              color: iconColor,
            );
          }),
          if (showRatingCount)
            CustomText(
              '(${filledStarCount.toDouble()})',
              style: Theme.of(context).textTheme.bodyMedium!,
            ),
          if (showRatingPercentage)
            CustomText(
              '${getPercentage()}%',
              style: TextStyle(
                fontSize: context.font.xxSmall,
                fontWeight: FontWeight.w500,
                color: context.color.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
  factory Rating.number({
    required num rating,
    required int ratingCount,
    String Function(int count)? divider,
    Color? ratingCountColor,
    bool showCount = true,
  }) {
    return Rating(
      builder: (context) {
        final String ratingCountString =
            divider?.call(ratingCount) ?? '($ratingCount)';
        return Row(
          spacing: 5,
          children: [
            CustomImage(
              AppIcons.starFilled,
              color: context.color.warning,
              width: 16,
              height: 16,
            ),
            CustomText(
              rating.ratingLabel,
              style: TextStyle(fontSize: context.font.xSmall),
            ),
            if (showCount)
              CustomText(
                ratingCountString,
                style: TextStyle(
                  fontSize: context.font.small,
                  color: ratingCountColor ?? context.color.textSecondary,
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}
