import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InstructorStatsWidget extends StatelessWidget {
  final int studentsCount;
  final int coursesCount;
  final int reviewsCount;
  final double rating;

  const InstructorStatsWidget({
    super.key,
    required this.studentsCount,
    required this.coursesCount,
    required this.reviewsCount,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Students count
        Expanded(
          child: _buildStatItem(
            context,
            title: studentsCount.toString(),
            subtitle: studentsCount == 1
                ? AppLabels.student.tr
                : AppLabels.students.tr,
          ),
        ),

        _buildVerticalDivider(context),

        // Courses count
        Expanded(
          child: _buildStatItem(
            context,
            title: AppLabels.courses.formatCountRounded(coursesCount),
            subtitle: coursesCount == 1
                ? AppLabels.course.tr
                : AppLabels.courses.tr,
          ),
        ),

        _buildVerticalDivider(context),

        // Reviews count with star icon
        Expanded(
          child: _buildRatingItem(
            context,
            rating: rating,
            reviewsCount: reviewsCount,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        CustomText(title, fontSize: context.font.xLarge, fontWeight: .w600),
        const SizedBox(height: 4),
        CustomText(
          subtitle,
          fontSize: context.font.medium,
          fontWeight: .w400,
          color: context.color.textSecondary,
        ),
      ],
    );
  }

  Widget _buildRatingItem(
    BuildContext context, {
    required double rating,
    required int reviewsCount,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: .center,
          children: [
            CustomImage(
              AppIcons.starFilled,
              width: 16,
              height: 16,
              color: context.color.warning,
            ),
            const SizedBox(width: 4),
            CustomText(
              rating.ratingLabel,
              style: TextStyle(fontSize: context.font.xxLarge),
            ),
          ],
        ),
        const SizedBox(height: 4),
        CustomText(
          reviewsCount == 1 ? AppLabels.review.tr : AppLabels.reviews.tr,
          style: TextStyle(fontSize: context.font.small),
          color: context.color.textSecondary,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: context.color.outline,
      margin: const .symmetric(horizontal: 8),
    );
  }
}
