import 'package:elms/common/enums.dart';
import 'package:elms/common/models/message_model.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/course/cubits/fetch_discussion_cubit.dart';
import 'package:elms/features/course/features/discussion/widgets/discussion_card.dart';
import 'package:elms/features/course/features/discussion/widgets/message_bottombar.dart';
import 'package:elms/features/course/features/discussion/widgets/message_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:elms/utils/extensions/context_extension.dart';

/// Arguments for ThreadScreen when navigating via nested navigator
class ThreadScreenArguments {
  final DiscussionModel discussion;
  final FetchDiscussionCubit cubit;

  ThreadScreenArguments({required this.discussion, required this.cubit});
}

class ThreadScreen extends StatefulWidget {
  final DiscussionModel discussion;
  final FetchDiscussionCubit? cubit;

  static Widget route([RouteSettings? settings]) {
    // Try settings.arguments first (for nested navigator), fallback to Get.arguments
    final args = settings?.arguments ?? Get.arguments;

    // Handle ThreadScreenArguments (from nested navigator with cubit)
    if (args is ThreadScreenArguments) {
      return BlocProvider.value(
        value: args.cubit,
        child: ThreadScreen(discussion: args.discussion, cubit: args.cubit),
      );
    }

    // Handle DiscussionModel directly (legacy navigation)
    final discussion = args as DiscussionModel;
    return ThreadScreen(discussion: discussion);
  }

  const ThreadScreen({super.key, required this.discussion, this.cubit});
  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocBuilder<FetchDiscussionCubit, FetchDiscussionState>(
        builder: (context, state) {
          // Get the current discussion from state or use widget.discussion as fallback
          DiscussionModel currentDiscussion = widget.discussion;
          if (state is FetchDiscussionSuccess) {
            currentDiscussion = state.data.firstWhere(
              (d) => d.id == widget.discussion.id,
              orElse: () => widget.discussion,
            );
          }

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title: CustomText(
                        AppLabels.discussion.tr,
                        style: TextStyle(fontSize: context.font.xxLarge),
                      ),
                      floating: true,
                      snap: true,
                    ),
                    SliverPadding(
                      padding: const .all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          DiscussionCard(
                            discussion: currentDiscussion,
                            replyVisibility: ReplyVisibility.hidden,
                          ),
                          const SizedBox(height: 16),
                          _buildRepliesCountRow(currentDiscussion),
                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),
                    SliverPadding(
                      padding: const .symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: .only(
                              bottom:
                                  index < currentDiscussion.replies.length - 1
                                  ? 8
                                  : 16,
                            ),
                            child: MessageCard(
                              message: currentDiscussion.replies[index],
                              useCard: true,
                            ),
                          );
                        }, childCount: currentDiscussion.replies.length),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: MessageBottomBar(
                  id: int.parse(widget.discussion.receiverId),
                  destination: DiscussionDestination.course,
                  parentDiscussionId: int.parse(widget.discussion.id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRepliesCountRow(DiscussionModel discussion) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        CustomText(
          AppLabels.repliesCount.tr,
          style: TextStyle(
            fontSize: context.font.medium,
            fontWeight: FontWeight.w500,
          ),
          fontWeight: .w600,
        ),
        CustomText(
          discussion.replies.length.toString(),
          style: TextStyle(
            fontSize: context.font.medium,
            fontWeight: FontWeight.w500,
          ),
          fontWeight: .w600,
        ),
      ],
    );
  }
}
