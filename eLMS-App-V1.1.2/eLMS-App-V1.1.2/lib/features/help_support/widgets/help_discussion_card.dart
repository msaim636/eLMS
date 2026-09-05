import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/help_support/models/discussion_question_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum HelpDiscussionCardType { normal, thread }

class HelpDiscussionCard extends StatefulWidget {
  final HelpDiscussionCardType type;
  final DiscussionQuestionModel? question;

  const HelpDiscussionCard({
    super.key,
    this.type = HelpDiscussionCardType.normal,
    this.question,
  });

  @override
  State<HelpDiscussionCard> createState() => _HelpDiscussionCardState();
}

class _HelpDiscussionCardState extends State<HelpDiscussionCard> {
  late Color? color = widget.type == HelpDiscussionCardType.thread
      ? context.color.primary.withValues(alpha: 0.4)
      : null;
  @override
  Widget build(BuildContext context) {
    // Return empty widget if question is not provided
    if (widget.question == null) {
      return const SizedBox.shrink();
    }

    final TextStyle bodySmall = TextStyle(fontSize: context.font.xSmall);
    final TextStyle bodyMedium = TextStyle(fontSize: context.font.small);

    // Extract data from question
    final question = widget.question!;
    final questionTitle = question.title;
    final questionDescription = question.description;
    final authorName = question.author.name;
    final authorAvatar = question.author.avatar;
    final timeAgo = question.timeAgo;
    final repliesCount = question.repliesCount;
    final viewsCount = question.viewsCount;

    return CustomCard(
      padding: const .all(8),
      color: color?.withValues(alpha: 0.1),
      borderColor: color,
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          _buildHeader(
            context,
            bodySmall,
            bodyMedium,
            authorName: authorName,
            authorAvatar: authorAvatar,
            timeAgo: timeAgo,
            questionTitle: questionTitle,
          ),
          const SizedBox(height: 10),
          CustomText(
            questionDescription,
            style: bodySmall.copyWith(fontWeight: .w400),
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          if (widget.type == HelpDiscussionCardType.thread) ...{
            _buildDivider(),
          },
          Row(
            spacing: 8,
            children: [
              if (widget.type == HelpDiscussionCardType.normal) ...{
                _buildEngagementStats(
                  context,
                  icon: AppIcons.document,
                  title: Utils.pluralize(
                    repliesCount,
                    singular: AppLabels.answer,
                    plural: AppLabels.answers,
                  ),
                ),
              } else ...{
                _buildEngagementStats(
                  context,
                  icon: AppIcons.redu,
                  title: Utils.pluralize(
                    repliesCount,
                    singular: AppLabels.reply,
                    plural: AppLabels.replies,
                  ),
                ),
              },
              _buildEngagementStats(
                context,
                icon: AppIcons.eye,
                title: Utils.pluralize(
                  viewsCount,
                  singular: AppLabels.view,
                  plural: AppLabels.views,
                ),
              ),
            ],
          ),
          if (widget.type == HelpDiscussionCardType.normal) ...[
            const SizedBox(height: 10),
            _buildDivider(),
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: CustomButton(
                height: 30,
                padding: const .symmetric(horizontal: 40),
                title: AppLabels.answer.tr,
                backgroundColor: context.color.darkColor,
                onPressed: () {
                  Get.toNamed(
                    AppRoutes.discussionThreadScreen,
                    arguments: question,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: color);
  }

  /// Builds the top row with profile image, title, name, and post time.
  Widget _buildHeader(
    BuildContext context,
    TextStyle bodySmall,
    TextStyle bodyMedium, {
    required String authorName,
    required String? authorAvatar,
    required String timeAgo,
    required String questionTitle,
  }) {
    return Row(
      crossAxisAlignment: .start,
      children: [
        Expanded(
          child: Row(
            spacing: 8,
            children: [
              _buildProfilePicture(authorAvatar),
              _buildTitleAndName(
                bodyMedium,
                title: questionTitle,
                name: authorName,
              ),
            ],
          ),
        ),
        Padding(
          padding: const .only(top: 4),
          child: CustomText(
            timeAgo,
            style: bodySmall.copyWith(
              fontWeight: .w400,
              color: context.color.darkColor.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  /// Displays the question title and user name.
  Widget _buildTitleAndName(
    TextStyle style, {
    required String title,
    required String name,
  }) {
    return Flexible(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            title,
            style: style.copyWith(fontWeight: .w500),
            maxLines: 1,
            ellipsis: true,
          ),
          CustomText(
            name,
            fontWeight: .w400,
            fontSize: context.font.small,
            maxLines: 1,
            color: context.color.textPrimary.withValues(alpha: 0.8),
            ellipsis: true,
          ),
        ],
      ),
    );
  }

  /// Reusable UI component for displaying an icon with a text label.
  Widget _buildEngagementStats(
    BuildContext context, {
    required String icon,
    required String title,
  }) {
    return Row(
      spacing: 6,
      children: [
        CustomImage(
          icon,
          width: 20,
          height: 20,
          color: context.color.onSurface,
        ),
        CustomText(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(fontWeight: .w400),
        ),
      ],
    );
  }

  /// Displays a circular profile picture.
  Widget _buildProfilePicture(String? imageUrl) {
    return Container(
      padding: const .all(2),
      decoration: BoxDecoration(shape: .circle, border: Border.all()),
      child: CustomImage.circular(
        imageUrl:
            imageUrl ??
            'https://via.assets.so/img.jpg?w=45&h=45&tc=white&bg=grey',
        width: 45,
        height: 45,
      ),
    );
  }
}
