import 'package:elms/common/enums.dart';
import 'package:elms/common/models/message_model.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/course/features/discussion/widgets/message_bottombar.dart';
import 'package:elms/features/course/features/discussion/widgets/message_card.dart';
import 'package:elms/features/help_support/cubits/fetch_question_details_cubit.dart';
import 'package:elms/features/help_support/models/discussion_question_model.dart';
import 'package:elms/features/help_support/widgets/help_discussion_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class DiscussionThreadScreen extends StatefulWidget {
  final DiscussionQuestionModel? question;

  const DiscussionThreadScreen({super.key, this.question});

  static Widget route() {
    final question = Get.arguments as DiscussionQuestionModel?;
    return BlocProvider(
      create: (context) => FetchQuestionDetailsCubit(),
      child: DiscussionThreadScreen(question: question),
    );
  }

  @override
  State<DiscussionThreadScreen> createState() => _DiscussionThreadScreenState();
}

class _DiscussionThreadScreenState extends State<DiscussionThreadScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      context.read<FetchQuestionDetailsCubit>().fetch(
        questionId: widget.question!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLabels.discussionThread.tr,
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const .all(16),
              child: Column(
                spacing: 16,
                children: [
                  _buildQuestionCard(context),
                  _buildRepliesSection(context),
                ],
              ),
            ),
          ),
          MessageBottomBar(
            destination: DiscussionDestination.helpDesk,
            id: widget.question?.id ?? 0,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    return BlocBuilder<FetchQuestionDetailsCubit, FetchQuestionDetailsState>(
      builder: (context, state) {
        // Create a copy of the question with updated reply count
        if (state is FetchQuestionDetailsSuccess && widget.question != null) {
          final updatedQuestion = DiscussionQuestionModel(
            id: widget.question!.id,
            slug: widget.question!.slug,
            title: widget.question!.title,
            description: widget.question!.description,
            isPrivate: widget.question!.isPrivate,
            author: widget.question!.author,
            createdAt: widget.question!.createdAt,
            createdAtFormatted: widget.question!.createdAtFormatted,
            timeAgo: widget.question!.timeAgo,
            updatedAt: widget.question!.updatedAt,
            group: widget.question!.group,
            repliesCount: state.repliesCount,
            viewsCount: widget.question!.viewsCount,
          );
          return HelpDiscussionCard(
            type: HelpDiscussionCardType.thread,
            question: updatedQuestion,
          );
        }

        return HelpDiscussionCard(
          type: HelpDiscussionCardType.thread,
          question: widget.question,
        );
      },
    );
  }

  Widget _buildRepliesSection(BuildContext context) {
    return BlocBuilder<FetchQuestionDetailsCubit, FetchQuestionDetailsState>(
      builder: (context, state) {
        if (state is FetchQuestionDetailsInProgress) {
          return const CustomShimmer();
        }

        if (state is FetchQuestionDetailsSuccess) {
          return Column(
            spacing: 16,
            children: [
              _buildHeader(context, state.repliesCount),
              ListView.separated(
                itemCount: state.data.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final reply = state.data[index];
                  return MessageCard(
                    useCard: true,
                    message: Message(
                      id: reply.id.toString(),
                      content: reply.reply,
                      senderId: reply.author.id.toString(),
                      receiverId: '',
                      timestamp: reply.createdAt,
                      type: 'reply',
                      userName: reply.author.name,
                      userSubtitle: AppLabels.student.tr,
                      profile: reply.author.avatar ?? '',
                      timesAgo: reply.timeAgo,
                    ),
                  );
                },
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        CustomText(
          AppLabels.repliesCount.tr,
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(fontWeight: .w500),
        ),
        CustomText(
          '($count)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(fontWeight: .w500),
        ),
      ],
    );
  }
}
