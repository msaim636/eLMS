import 'package:elms/common/widgets/animated_showmore_container.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CourseOverviewWidget extends StatelessWidget {
  final String level;
  final String category;
  final num currentPrice;
  final num? originalPrice;
  final String title;
  final Map<String, String> courseDetails;
  final String overview;
  final List<String> learningPoints;
  final List<String> requirements;
  final bool isFree;

  final EdgeInsetsGeometry padding;
  final bool isLoading;

  const CourseOverviewWidget({
    super.key,
    required this.level,
    required this.category,
    required this.currentPrice,
    required this.title,
    required this.courseDetails,
    required this.overview,
    required this.learningPoints,
    required this.requirements,
    this.originalPrice,
    this.isFree = false,
    this.padding = const .all(12),
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: .start,
        spacing: 16,
        children: [
          _buildLevelIndicator(context),
          _buildPrice(context),
          CustomText(
            title,
            style: TextStyle(
              fontSize: context.font.medium,
              fontWeight: .w500,
              color: context.color.onSurface,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (final MapEntry<String, String> entry
                        in courseDetails.entries.take(3))
                      Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 10),
                        child: _buildInfoItem(
                          context: context,
                          icon: _getIconKeyForDetail(entry.key),
                          text: entry.value,
                          isLoading: isLoading,
                          shimmerLabel: _getShimmerLabelForDetail(entry.key),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    for (final entry in courseDetails.entries.skip(3).take(3))
                      Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 10),
                        child: _buildInfoItem(
                          context: context,
                          icon: _getIconKeyForDetail(entry.key),
                          text: entry.value,
                          isLoading: isLoading,
                          shimmerLabel: _getShimmerLabelForDetail(entry.key),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Divider
          // _buildCustomDivider(context),
          AnimatedShowMore(
            content: overview,
            textStyle: TextStyle(
              fontSize: 14,
              color: context.color.textSecondary,
              height: 1.5,
            ),
          ),
          _buildCustomDivider(context),

          if (learningPoints.isNotEmpty) ...{
            CustomText(
              AppLabels.whatYouWillLearn.tr,
              style: TextStyle(
                fontSize: context.font.medium,
                fontWeight: .w500,
                color: context.color.onSurface,
              ),
            ),
            AnimatedShowMore<List>(
              content: List.generate(learningPoints.length, (i) {
                return _buildBulletPoint(context, learningPoints[i]);
              }),
            ),
            _buildCustomDivider(context),
          },

          if (requirements.isNotEmpty) ...{
            // Divider
            CustomText(
              AppLabels.requirements.tr,
              style: TextStyle(
                fontSize: context.font.medium,
                fontWeight: .w500,
                color: context.color.onSurface,
              ),
            ),

            AnimatedShowMore(
              content: List.generate(requirements.length, (i) {
                return _buildBulletPoint(context, requirements[i]);
              }),
            ),

            _buildCustomDivider(context),
          },
        ],
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    return Row(
      children: [
        CustomText(
          isFree
              ? AppLabels.free.tr
              : ((currentPrice == 0 ? originalPrice : currentPrice)!
                    .toStringAsFixed(2)
                    .currency),
          style: TextStyle(
            fontSize: context.font.xxLarge,
            fontWeight: .w600,
            color: isFree ? context.color.primary : context.color.onSurface,
          ),
        ),
        if (!isFree &&
            originalPrice != null &&
            originalPrice! > currentPrice &&
            currentPrice != 0) ...[
          const SizedBox(width: 10),
          CustomText(
            originalPrice!.toStringAsFixed(2).currency,
            style: TextStyle(
              fontSize: context.font.small,
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

  Widget _buildLevelIndicator(BuildContext context) {
    return Container(
      padding: const .symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.color.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomText(
        category,
        style: Theme.of(
          context,
        ).textTheme.labelLarge!.copyWith(color: context.color.primary),
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required String icon,
    required String text,
    FontWeight? fontWeight,
    bool isLoading = false,
    String shimmerLabel = '',
  }) {
    return Row(
      children: [
        CustomImage(
          _getIconForType(icon),
          width: 16,
          height: 16,
          color: context.color.onSurface,
        ),
        const SizedBox(width: 6),
        if (isLoading) ...[
          const CustomShimmer(height: 12, width: 30),
          const SizedBox(width: 4),
          CustomText(
            shimmerLabel,
            style: TextStyle(
              fontSize: context.font.small,
              fontWeight: fontWeight ?? .w400,
              color: context.color.textSecondary,
            ),
          ),
        ] else
          Expanded(
            child: CustomText(
              text,
              style: TextStyle(
                fontSize: context.font.small,
                fontWeight: fontWeight ?? .w400,
                color: context.color.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  String _getShimmerLabelForDetail(String key) {
    return switch (key.toLowerCase()) {
      'duration' => AppLabels.courseDuration.tr,
      'chapters' => AppLabels.chapters.tr,
      'lectures' => 'Lectures',
      'rating' => AppLabels.rating.tr,
      'language' => AppLabels.language.tr,
      _ => '',
    };
  }

  String _getIconKeyForDetail(String detailKey) {
    switch (detailKey.toLowerCase()) {
      case 'duration':
        return 'clock';
      case 'chapters':
        return 'chapter';
      case 'lectures':
        return 'video';
      case 'rating':
        return 'star';
      case 'language':
        return 'language';
      case 'access':
        return 'medal';
      default:
        return detailKey;
    }
  }

  String _getIconForType(String icon) {
    switch (icon) {
      case 'book':
        return AppIcons.book;
      case 'clock':
        return AppIcons.clockFilled;
      case 'video':
        return AppIcons.video;
      case 'star':
        return AppIcons.star;
      case 'language':
        return AppIcons.language;
      case 'chapter':
        return AppIcons.chapterFilled;
      case 'medal':
        return AppIcons.medal;
      default:
        return '';
    }
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: .start,
      children: [
        CustomImage(
          AppIcons.check,
          width: 20,
          height: 20,
          color: context.color.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomText(
            text,
            style: TextStyle(
              fontSize: context.font.small,
              color: context.color.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomDivider(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 1,
      color: context.color.outline,
    );
  }
}
