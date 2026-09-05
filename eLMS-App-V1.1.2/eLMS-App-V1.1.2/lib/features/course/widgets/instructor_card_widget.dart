import 'package:elms/common/models/instructor_model.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/tappable_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:elms/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InstructorCardWidget extends StatelessWidget {
  final InstructorModel instructor;
  final bool showHeader;
  final EdgeInsetsGeometry padding;

  const InstructorCardWidget({
    super.key,
    required this.instructor,
    this.showHeader = true,
    this.padding = const .all(8),
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: .start,
        spacing: 10,
        children: [
          // Header (optional)
          if (showHeader) ...[
            CustomText(
              AppLabels.instructor.tr,
              style: TextStyle(
                fontSize: context.font.large,
                fontWeight: .w500,
                color: context.color.onSurface,
              ),
            ),
          ],
          // Instructor profile row
          Row(
            children: [
              // Profile image
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: instructor.profile.isNotEmpty
                      ? TappableImage(instructor.profile, fit: BoxFit.cover)
                      : CustomImage(
                          AppIcons.profilePlaceholder,
                          fit: .cover,
                          color: context.color.textSecondary,
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Instructor info
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    // Rating row
                    Row(
                      children: [
                        CustomImage(
                          AppIcons.starFilled,
                          width: 16,
                          height: 16,
                          color: context.color.warning,
                        ),
                        const SizedBox(width: 4),
                        CustomText(
                          instructor.averageRating.ratingLabel,
                          style: TextStyle(
                            fontSize: context.font.small,
                          ).copyWith(color: context.color.textSecondary),
                        ),
                        const SizedBox(width: 4),
                        CustomText(
                          '(${Utils.pluralize(instructor.reviewCount, singular: AppLabels.review, plural: AppLabels.reviews)})',
                          style: TextStyle(
                            fontSize: context.font.small,
                          ).copyWith(color: context.color.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Instructor name
                    CustomText(
                      instructor.displayName,
                      style: TextStyle(
                        fontSize: context.font.medium,
                        fontWeight: .w500,
                        color: context.color.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Instructor specialization / team members
                    CustomText(
                      instructor.isTeam
                          ? instructor.teamMemberNames
                          : (instructor.qualification ?? ''),
                      style: TextStyle(
                        fontSize: context.font.small,
                        color: context.color.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Instructor description
          if (instructor.aboutMe != null) ...[
            CustomText(
              instructor.aboutMe!.stripHtmlTags,
              maxLines: 4,
              ellipsis: true,
              style: TextStyle(fontSize: 16, color: context.color.onSurface),
            ),
          ],
          // Qualifications
          if (instructor.qualification != null &&
              instructor.qualification!.isNotEmpty) ...[
            _buildQualificationsSection(context),
          ],
          // Skills
          if (instructor.skills != null && instructor.skills!.isNotEmpty) ...[
            _buildSkillsSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildQualificationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        CustomText(
          AppLabels.qualifications.tr,
          fontWeight: FontWeight.w600,
          fontSize: context.font.medium,
        ),
        CustomText(
          instructor.qualification!.stripHtmlTags,
          style: TextStyle(
            fontSize: context.font.small,
            color: context.color.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    final skills = instructor.skills!
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        CustomText(
          AppLabels.mySkills.tr,
          fontWeight: FontWeight.w600,
          fontSize: context.font.medium,
        ),
        ...skills.map(
          (skill) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                '• ',
                style: TextStyle(
                  fontSize: context.font.small,
                  color: context.color.onSurface,
                ),
              ),
              Expanded(
                child: CustomText(
                  skill,
                  style: TextStyle(
                    fontSize: context.font.small,
                    color: context.color.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
