import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/common/widgets/video_banner_container.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:elms/utils/utils.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/models/instructor_model.dart';

class InstructorCard extends StatelessWidget {
  final InstructorCardStyle style;
  final Widget Function(BuildContext context, InstructorCardStyle style)
  builder;

  const InstructorCard._({required this.style, required this.builder});

  factory InstructorCard.small({
    Key? key,
    required InstructorModel instructor,
    VoidCallback? onTap,
  }) {
    return InstructorCard._(
      style: InstructorCardStyle.small,
      builder: (context, style) => _buildSmallCard(
        context: context,
        instructor: instructor,
        onTap: onTap,
      ),
    );
  }

  factory InstructorCard.detailed({
    Key? key,
    required InstructorModel instructor,
    VoidCallback? onTap,
  }) {
    return InstructorCard._(
      style: InstructorCardStyle.detailed,
      builder: (context, style) => _buildDetailedCard(
        context: context,
        instructor: instructor,
        onTap: onTap,
      ),
    );
  }

  static Widget _buildSmallCard({
    required BuildContext context,
    required InstructorModel instructor,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      borderColor: Colors.transparent,
      width: 162,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const .symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .spaceEvenly,
            children: [
              _buildProfileImage(context, instructor.profile),

              _buildInstructorInfo(
                context: context,
                name: "${instructor.displayName}\n",
                specialization: instructor.qualification ?? '',
                isSmall: true,
                rating: instructor.averageRating.toDouble(),
                reviewsCount: instructor.reviewCount,
              ),

              // Divider
              _buildDivider(context),

              // Student Count
              _buildStatRow(
                context,
                AppIcons.playIcon,
                Utils.pluralize(
                  instructor.activeCoursesCount,
                  singular: AppLabels.course,
                  plural: AppLabels.courses,
                ),
              ),

              // Courses Count
              _buildStatRow(
                context,
                AppIcons.teacher,
                '${instructor.studentEnrolledCount} ${AppLabels.enrolled.tr}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDetailedCard({
    required BuildContext context,
    required InstructorModel instructor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          // Image banner
          _buildBanner(context, instructor),

          Padding(
            padding: const .all(10),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                // Header section with image and basic info
                Row(
                  children: [
                    _buildRectangularImage(context, instructor.profile),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInstructorInfo(
                        context: context,
                        name: instructor.displayName,
                        specialization: instructor.qualification ?? '',
                        isSmall: false,
                      ),
                    ),
                  ],
                ),

                // Description
                if (instructor.aboutMe != null) ...[
                  const SizedBox(height: 8),
                  CustomText(
                    instructor.aboutMe!.stripHtmlTags,
                    maxLines: 4,
                    ellipsis: true,
                    style: TextStyle(
                      color: context.color.textSecondary,
                      fontSize: context.font.small,
                    ),
                  ),
                ],

                // Divider
                const SizedBox(height: 8),
                _buildDivider(context, thickness: 1),
                const SizedBox(height: 8),

                // Stats with rating and courses count
                _buildDetailedStats(
                  context: context,
                  rating: instructor.averageRating.toDouble(),
                  reviewsCount: instructor.reviewCount,
                  coursesCount: instructor.activeCoursesCount,
                ),

                // Read More button
                if (onTap != null) ...[
                  const SizedBox(height: 8),
                  _buildReadMoreButton(context, onTap),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildBanner(BuildContext context, InstructorModel instructor) {
    if (instructor.previewVideo == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const .fromLTRB(10, 10, 10, 0),
      child: SizedBox(
        height: 230,
        child: VideoBannerContainer(
          url: instructor.previewVideo!,
          extractFromVideo: true,
        ),
      ),
    );
  }

  static Widget _buildProfileImage(BuildContext context, String? imageUrl) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        shape: .circle,
        color: context.color.primary.withValues(alpha: 0.2),
        border: Border.all(color: context.color.outline, width: 0.6),
      ),
      child: CustomImage.circular(
        imageUrl: (imageUrl == null || imageUrl.isEmpty)
            ? AppIcons.profilePlaceholder
            : imageUrl,
        width: 66,
        height: 66,
      ),
    );
  }

  static Widget _buildRectangularImage(BuildContext context, String? imageUrl) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.color.outline.withValues(alpha: 0.78),
        ),
        color: context.color.outline.withValues(alpha: 0.39),
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl, fit: .cover),
            )
          : Icon(Icons.person_outline, size: 24, color: context.color.primary),
    );
  }

  static Widget _buildInstructorInfo({
    required BuildContext context,
    required String name,
    required String specialization,
    required bool isSmall,

    double? rating,
    int? reviewsCount,
  }) {
    return Column(
      crossAxisAlignment: isSmall ? .center : .start,
      children: [
        CustomText(
          name,
          fontWeight: isSmall ? .w500 : .w600,
          textAlign: isSmall ? .center : .start,
          maxLines: 2,
          ellipsis: true,
          style: isSmall
              ? Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontWeight: .w500)
              : Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontWeight: .w600),
        ),
        const SizedBox(height: 4),
        CustomText(
          specialization,
          fontSize: isSmall ? 14 : 12,
          color: context.color.textSecondary,
          textAlign: isSmall ? .center : .start,
          maxLines: 1,
          ellipsis: true,
          style: isSmall
              ? Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(fontWeight: .w500)
              : Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(fontWeight: .w600),
        ),

        if (rating != null && reviewsCount != null)
          Row(
            mainAxisAlignment: .center,
            children: [
              CustomImage(AppIcons.star, color: context.color.warning),
              const SizedBox(width: 4),
              CustomText(rating.ratingLabel),
              const SizedBox(width: 2),
              CustomText(
                "(${_formatNumber(reviewsCount)} ${reviewsCount == 1 ? AppLabels.review.tr : AppLabels.reviews.tr})",
              ),
            ],
          ),
      ],
    );
  }

  static Widget _buildDivider(BuildContext context, {double thickness = 0}) {
    return Divider(
      color: context.color.outline,
      height: 1,
      thickness: thickness,
    );
  }

  static Widget _buildStatRow(BuildContext context, String image, String text) {
    return Row(
      mainAxisSize: .min,
      children: [
        CustomImage(image, color: context.color.primary),
        const SizedBox(width: 4),
        CustomText(text, fontSize: context.font.small, fontWeight: .w400),
      ],
    );
  }

  static Widget _buildDetailedStats({
    required BuildContext context,
    double? rating,
    int? reviewsCount,
    required int coursesCount,
  }) {
    return Padding(
      padding: const .symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          if (rating != null) ...[
            Row(
              children: [
                CustomImage(
                  AppIcons.star,
                  width: 16,
                  height: 16,
                  color: context.color.onSurface,
                ),
                const SizedBox(width: 6),
                CustomText(
                  rating.ratingLabel,
                  style: TextStyle(
                    fontSize: context.font.xSmall,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (reviewsCount != null) ...[
                  const SizedBox(width: 2),
                  CustomText(
                    '(',
                    style: TextStyle(fontSize: context.font.xSmall),
                  ),
                  CustomText(
                    _formatNumber(reviewsCount),
                    style: TextStyle(
                      fontSize: context.font.xSmall,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CustomText(
                    ' ${reviewsCount == 1 ? AppLabels.review.tr : AppLabels.reviews.tr})',
                    style: TextStyle(fontSize: context.font.xSmall),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              CustomImage(
                AppIcons.playIcon,
                width: 16,
                height: 16,
                color: context.color.onSurface,
              ),
              const SizedBox(width: 6),
              CustomText(
                '$coursesCount',
                style: TextStyle(
                  fontSize: context.font.xSmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              CustomText(
                AppLabels.coursesAvailable.tr,
                style: TextStyle(fontSize: context.font.xSmall),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildReadMoreButton(BuildContext context, VoidCallback onTap) {
    return CustomButton(
      onPressed: onTap,
      width: double.infinity,
      height: 35,
      backgroundColor: context.color.onSurface,
      customTitle: CustomText(
        AppLabels.readMore.tr,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(fontWeight: .w600),
        color: context.color.surface,
      ),
    );
  }

  static String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderColor: Colors.transparent,
      child: builder(context, style),
    );
  }
}

class InstructorCardShimmer extends StatelessWidget {
  const InstructorCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: .start,
      children: [
        // Banner shimmer
        Padding(
          padding: .fromLTRB(10, 10, 10, 0),
          child: CustomShimmer(
            height: 230,
            width: double.infinity,
            borderRadius: 8,
          ),
        ),

        Padding(
          padding: .all(10),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              // Header section with image and basic info
              Row(
                children: [
                  // Rectangular image shimmer
                  CustomShimmer(width: 48, height: 48, borderRadius: 8),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        // Name shimmer
                        CustomShimmer(
                          height: 16,
                          width: double.infinity,
                          borderRadius: 4,
                        ),
                        SizedBox(height: 4),
                        // Specialization shimmer
                        CustomShimmer(height: 14, width: 150, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),

              // Description shimmer
              SizedBox(height: 8),
              CustomShimmer(
                height: 14,
                width: double.infinity,
                borderRadius: 4,
              ),
              SizedBox(height: 4),
              CustomShimmer(
                height: 14,
                width: double.infinity,
                borderRadius: 4,
              ),
              SizedBox(height: 4),
              CustomShimmer(height: 14, width: 200, borderRadius: 4),

              // Divider
              SizedBox(height: 8),
              CustomShimmer(height: 1, width: double.infinity, borderRadius: 0),
              SizedBox(height: 8),

              // Stats shimmer
              Padding(
                padding: .symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    // Rating row
                    Row(
                      children: [
                        CustomShimmer(width: 16, height: 16, borderRadius: 4),
                        SizedBox(width: 6),
                        CustomShimmer(height: 14, width: 100, borderRadius: 4),
                      ],
                    ),
                    SizedBox(height: 12),
                    // Courses row
                    Row(
                      children: [
                        CustomShimmer(width: 16, height: 16, borderRadius: 4),
                        SizedBox(width: 6),
                        CustomShimmer(height: 14, width: 120, borderRadius: 4),
                      ],
                    ),
                  ],
                ),
              ),

              // Read More button shimmer
              SizedBox(height: 8),
              CustomShimmer(
                width: double.infinity,
                height: 35,
                borderRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
