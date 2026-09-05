import 'package:elms/common/models/message_model.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/pattern_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/course/cubits/fetch_discussion_cubit.dart';
import 'package:elms/features/course/features/discussion/screens/thread_screen.dart';
import 'package:elms/features/course/features/discussion/widgets/message_card.dart';
import 'package:elms/features/course/features/discussion/widgets/user_profile_tile.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

enum ReplyVisibility { visible, hidden }

class DiscussionCard extends StatelessWidget {
  final DiscussionModel discussion;
  final ReplyVisibility replyVisibility;
  const DiscussionCard({
    super.key,
    required this.discussion,
    this.replyVisibility = ReplyVisibility.visible,
  });

  @override
  Widget build(BuildContext context) {
    final Color? borderColor = replyVisibility == ReplyVisibility.hidden
        ? context.color.primary.withValues(alpha: 0.7)
        : null;
    return CustomCard(
      padding: const .all(8),
      color: replyVisibility == ReplyVisibility.hidden
          ? context.color.primary.withValues(alpha: 0.1)
          : null,
      borderColor: borderColor,
      child: Column(
        children: [
          UserProfileTile(message: discussion),
          Divider(color: borderColor),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 52),
            child: Column(
              crossAxisAlignment: .start,
              spacing: 9,
              children: [
                PatternText(
                  text: discussion.content,
                  baseStyle: TextStyle(
                    fontSize: context.font.small,
                    fontWeight: .w400,
                  ),
                  readMore: true,
                  readMoreMaxLines: 5,
                ),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    if (replyVisibility == ReplyVisibility.visible)
                      _buildReplyButton(context)
                    else
                      const Spacer(),
                    _buildTime(context),
                  ],
                ),
                if (discussion.replies.isNotEmpty &&
                    replyVisibility == ReplyVisibility.visible) ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 15),
                    child: Column(
                      crossAxisAlignment: .start,
                      spacing: 6,
                      children: [
                        if (discussion.replies.length > 1)
                          GestureDetector(
                            onTap: () => _navigateToThread(context),
                            child: CustomText(
                              AppLabels.viewAllReplies.translateWithTemplate({
                                'count': discussion.replies.length.toString(),
                              }),
                              style: TextStyle(fontSize: context.font.small),
                              color: context.color.primary,
                              fontWeight: .w500,
                            ),
                          ),
                        MessageCard(message: discussion.replies.last),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTime(BuildContext context) {
    return CustomText(
      discussion.timesAgo,
      style: TextStyle(
        fontSize: context.font.xSmall,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildReplyButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToThread(context),
      child: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImage(AppIcons.messages),
          CustomText(
            AppLabels.reply.tr,
            style: TextStyle(fontSize: context.font.small),
            color: context.color.primary,
          ),
        ],
      ),
    );
  }

  void _navigateToThread(BuildContext context) {
    // Try to use the nested navigator first (for course content overlay)
    final nestedNavigator = Get.nestedKey(1)?.currentState;
    final cubit = context.read<FetchDiscussionCubit>();
    if (nestedNavigator != null) {
      // Pass the cubit along with the discussion for nested navigation
      nestedNavigator.pushNamed(
        CourseContentRoute.discussionThread,
        arguments: ThreadScreenArguments(discussion: discussion, cubit: cubit),
      );
    } else {
      // Fallback to regular navigation
      Get.toNamed(
        AppRoutes.threadScreen,
        arguments: ThreadScreenArguments(discussion: discussion, cubit: cubit),
      );
    }
  }
}
