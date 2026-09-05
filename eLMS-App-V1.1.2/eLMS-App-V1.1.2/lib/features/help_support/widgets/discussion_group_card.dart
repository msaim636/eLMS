import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/help_support/models/discussion_group.dart';
import 'package:elms/features/help_support/models/discussion_list_arguments.dart';
import 'package:elms/features/help_support/models/discussion_topic.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elms/common/enums.dart';

enum DiscussionCardVariant { vertical, horizontal }

class DiscussionGroupCardShimmer extends StatelessWidget {
  final DiscussionCardVariant variant;

  const DiscussionGroupCardShimmer({
    super.key,
    this.variant = DiscussionCardVariant.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return variant == DiscussionCardVariant.vertical
        ? _buildVerticalShimmer(context)
        : _buildHorizontalShimmer(context);
  }

  Widget _buildVerticalShimmer(BuildContext context) {
    return SizedBox(
      width: 218,
      child: CustomCard(
        borderColor: context.color.outline,
        padding: const .all(16),
        child: const Column(
          spacing: 8,
          children: [
            // Icon shimmer
            CustomShimmer(width: 50, height: 50, borderRadius: 5.5),

            // Title shimmer
            CustomShimmer(height: 16, borderRadius: 4),

            // Description shimmer (3 lines)
            CustomShimmer(height: 12, borderRadius: 4),
            CustomShimmer(height: 12, borderRadius: 4),
            CustomShimmer(height: 12, width: 100, borderRadius: 4),

            Spacer(),

            // Button shimmer
            CustomShimmer(height: 40, borderRadius: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalShimmer(BuildContext context) {
    return CustomCard(
      borderColor: context.color.outline,
      padding: const .symmetric(horizontal: 12, vertical: 9),
      width: context.screenWidth,
      child: Column(
        spacing: 12,
        children: [
          Row(
            children: [
              // Icon shimmer
              const CustomShimmer(width: 50, height: 50, borderRadius: 5.5),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  spacing: 4,
                  children: [
                    // Title shimmer
                    CustomShimmer(
                      height: 16,
                      width: context.screenWidth * 0.5,
                      borderRadius: 4,
                    ),

                    // Description shimmer (2 lines)
                    const CustomShimmer(height: 12, borderRadius: 4),
                    CustomShimmer(
                      height: 12,
                      width: context.screenWidth * 0.4,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CustomShimmer(height: 36, width: 120, borderRadius: 4),
          ),
        ],
      ),
    );
  }
}

class DiscussionGroupCard extends StatelessWidget {
  final HelpDeskDiscussionGroupModel discussionGroup;
  final DiscussionCardVariant variant;

  const DiscussionGroupCard({
    super.key,
    this.variant = DiscussionCardVariant.vertical,
    required this.discussionGroup,
  });

  void _onTap() {
    // Navigate to discussion list screen with group details
    final arguments = DiscussionListArguments(
      groupId: discussionGroup.id,
      groupSlug: discussionGroup.slug,
      privacy: discussionGroup.isPrivateGroup
          ? GroupPrivacy.private
          : GroupPrivacy.public,
      groupName: discussionGroup.name,
    );

    Get.toNamed(AppRoutes.discussionListScreen, arguments: arguments);
  }

  @override
  Widget build(BuildContext context) {
    return variant == DiscussionCardVariant.vertical
        ? _buildVerticalCard(context)
        : _buildHorizontalCard(context);
  }

  Widget _buildVerticalCard(BuildContext context) {
    return SizedBox(
      width: 218,
      child: CustomCard(
        borderColor: context.color.outline,
        padding: const .symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            // Icon container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: context.color.surface,
                borderRadius: BorderRadius.circular(5.5),
                border: Border.all(color: context.color.outline, width: 0.7),
              ),
              padding: const .all(8.3),
              child: discussionGroup.image != null
                  ? CustomImage(discussionGroup.image!, width: 24, height: 24)
                  : Container(color: context.color.surface),
            ),
            const SizedBox(height: 8),
            // Title
            CustomText(
              discussionGroup.name,
              style: const TextStyle(fontWeight: .w500, fontSize: 14),
              maxLines: 1,
              ellipsis: true,
              textAlign: .center,
            ),

            // Description
            CustomText(
              discussionGroup.description,
              style: TextStyle(
                fontSize: 12,
                color: context.color.textSecondary,
              ),
              textAlign: .center,
              maxLines: 3,
            ),

            const Spacer(),

            // Button
            CustomButton(
              onPressed: _onTap,
              borderColor: context.color.onSurface,
              type: CustomButtonType.outlined,
              textColor: context.color.onSurface,
              height: 40,
              customTitle: CustomText(
                AppLabels.letsDiscuss.tr,
                style: const TextStyle(fontWeight: .w400, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context) {
    return CustomCard(
      borderColor: context.color.outline,
      padding: const .symmetric(horizontal: 12, vertical: 9),
      width: context.screenWidth,
      child: Column(
        spacing: 12,
        children: [
          Row(
            children: [
              // Icon container
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: context.color.surface,
                  borderRadius: BorderRadius.circular(5.5),
                  border: Border.all(color: context.color.outline, width: 0.7),
                ),
                padding: const .all(8.3),
                child: discussionGroup.image != null
                    ? CustomImage(discussionGroup.image!, width: 24, height: 24)
                    : Container(color: context.color.surface),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    // Title
                    CustomText(
                      discussionGroup.name,
                      style: const TextStyle(fontWeight: .w500, fontSize: 14),
                      maxLines: 1,
                      ellipsis: true,
                    ),
                    const SizedBox(height: 4),

                    // Description
                    CustomText(
                      discussionGroup.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.color.textSecondary,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CustomButton(
              onPressed: _onTap,
              borderColor: context.color.onSurface,
              type: CustomButtonType.outlined,
              textColor: context.color.onSurface,
              height: 36,
              customTitle: CustomText(
                AppLabels.letsDiscuss.tr,
                style: const TextStyle(fontWeight: .w400, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
