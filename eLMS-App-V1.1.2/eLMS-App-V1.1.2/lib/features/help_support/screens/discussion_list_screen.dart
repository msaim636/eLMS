import 'dart:async';

import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/login/guest_checker.dart';
import 'package:elms/features/help_support/cubits/ask_question_cubit.dart';
import 'package:elms/features/help_support/cubits/check_group_approval_cubit.dart';
import 'package:elms/features/help_support/cubits/fetch_questions_cubit.dart';
import 'package:elms/features/help_support/cubits/request_private_group_cubit.dart';
import 'package:elms/features/help_support/models/discussion_list_arguments.dart';
import 'package:elms/features/help_support/models/discussion_topic.dart';
import 'package:elms/features/help_support/repositories/help_desk_repository.dart';
import 'package:elms/features/help_support/widgets/ask_question_dialog.dart';
import 'package:elms/features/help_support/widgets/help_discussion_card.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class DiscussionListScreen extends StatefulWidget {
  const DiscussionListScreen({super.key});

  static Widget route() {
    final arguments = Get.arguments as DiscussionListArguments;
    final isPrivate = arguments.privacy == GroupPrivacy.private;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              FetchQuestionsCubit(HelpDeskRepository())
                ..fetch(groupId: arguments.groupId),
        ),
        BlocProvider(
          create: (context) => RequestPrivateGroupCubit(HelpDeskRepository()),
        ),
        BlocProvider(
          create: (context) => AskQuestionCubit(HelpDeskRepository()),
        ),
        BlocProvider(
          create: (context) {
            final CheckGroupApprovalCubit cubit = CheckGroupApprovalCubit(
              HelpDeskRepository(),
            );
            // Only check approval for private groups
            if (isPrivate) {
              cubit.checkApproval(groupSlug: arguments.groupSlug);
            }
            return cubit;
          },
        ),
      ],
      child: const DiscussionListScreen(),
    );
  }

  @override
  State<DiscussionListScreen> createState() => _DiscussionListScreenState();
}

class _DiscussionListScreenState extends State<DiscussionListScreen>
    with Pagination<DiscussionListScreen, FetchQuestionsCubit> {
  late DiscussionListArguments arguments;
  late bool isPrivate;

  @override
  void initState() {
    super.initState();
    arguments = Get.arguments as DiscussionListArguments;
    isPrivate = arguments.privacy == GroupPrivacy.private;
  }

  void _onTapRequestAccess() {
    context.read<RequestPrivateGroupCubit>().requestAccess(
      groupId: arguments.groupId,
    );
  }

  Future<void> _onTapAskQuestion() async {
    GuestChecker.check(
      onNotGuest: () async {
        final result = await UiUtils.showDialog(
          context,
          child: BlocProvider.value(
            value: context.read<AskQuestionCubit>(),
            child: AskQuestionDialog(
              groupId: arguments.groupId,
              topicName: arguments.groupName ?? '',
            ),
          ),
        );

        if (result == true && mounted) {
          unawaited(
            context.read<FetchQuestionsCubit>().fetch(
              groupId: arguments.groupId,
            ),
          );
          context.read<AskQuestionCubit>().reset();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLabels.discussion.tr,
        showBackButton: true,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: isPrivate ? _buildPrivateGroupBody() : _buildPublicGroupBody(),
    );
  }

  Widget? _buildBottomNavigationBar() {
    if (!isPrivate) {
      return BottomAppBar(
        padding: const EdgeInsets.all(8),
        height: kBottomNavigationBarHeight,
        child: CustomButton(
          customTitle: Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomImage(AppIcons.addSquare),
              CustomText(
                AppLabels.askQuestion.tr,
                style: TextStyle(
                  fontSize: context.font.small,
                  fontWeight: FontWeight.w500,
                  color: context.color.onPrimary,
                ),
              ),
            ],
          ),
          backgroundColor: context.color.darkColor,
          onPressed: _onTapAskQuestion,
        ),
      );
    }

    // For private groups, show bottom bar only if user is approved
    return BlocBuilder<CheckGroupApprovalCubit, CheckGroupApprovalState>(
      builder: (context, state) {
        if (state is CheckGroupApprovalSuccess &&
            state.data.isApproved &&
            state.data.canPostQuestions) {
          return BottomAppBar(
            padding: const EdgeInsets.all(8),
            height: kBottomNavigationBarHeight,
            child: CustomButton(
              customTitle: Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomImage(AppIcons.addSquare),
                  CustomText(
                    AppLabels.askQuestion.tr,
                    style: TextStyle(
                      fontSize: context.font.small,
                      fontWeight: FontWeight.w500,
                      color: context.color.onPrimary,
                    ),
                  ),
                ],
              ),
              backgroundColor: context.color.darkColor,
              onPressed: _onTapAskQuestion,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPrivateGroupBody() {
    return BlocConsumer<CheckGroupApprovalCubit, CheckGroupApprovalState>(
      listener: (context, state) {
        // Listen for errors
        if (state is CheckGroupApprovalError) {
          UiUtils.showSnackBar(UiUtils.friendlyErrorMessage(state.error), isError: true);
        }
      },
      builder: (context, approvalState) {
        if (approvalState is CheckGroupApprovalProgress) {
          return _buildLoadingState();
        } else if (approvalState is CheckGroupApprovalSuccess) {
          final status = approvalState.data;

          // User is approved and can post questions - show questions list
          if (status.isApproved && status.canPostQuestions) {
            return _buildPublicGroupBody();
          }

          // User has pending request
          if (status.hasPendingRequest) {
            return _buildPendingRequestCard();
          }

          // User's request was rejected
          if (status.wasRejected) {
            return _buildRejectedRequestCard();
          }

          // User can send a new request
          return BlocConsumer<
            RequestPrivateGroupCubit,
            RequestPrivateGroupState
          >(
            listener: (context, state) {
              if (state is RequestPrivateGroupSuccess) {
                UiUtils.showSnackBar(
                  state.data['message'] ?? AppLabels.requestSent.tr,
                );
                // Refresh approval status after sending request
                context.read<CheckGroupApprovalCubit>().refresh(
                  groupSlug: arguments.groupSlug,
                );
              } else if (state is RequestPrivateGroupError) {
                UiUtils.showSnackBar(UiUtils.friendlyErrorMessage(state.error), isError: true);
              }
            },
            builder: (context, state) {
              return _buildPrivateTopicCard(state);
            },
          );
        } else if (approvalState is CheckGroupApprovalError) {
          return _buildApprovalErrorState(approvalState);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPublicGroupBody() {
    return BlocBuilder<FetchQuestionsCubit, FetchQuestionsState>(
      builder: (context, state) {
        if (state is FetchQuestionsProgress) {
          return _buildLoadingState();
        } else if (state is FetchQuestionsSuccess) {
          return _buildSuccessState(state);
        } else if (state is FetchQuestionsError) {
          return _buildErrorState(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPendingRequestCard() {
    return Center(
      child: CustomCard(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              size: 48,
              color: context.color.primary,
            ),
            const SizedBox(height: 16),
            CustomText(
              AppLabels.requestPending.tr,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              AppLabels.requestPendingDescription.tr,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedRequestCard() {
    return Center(
      child: CustomCard(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined, size: 48, color: context.color.error),
            const SizedBox(height: 16),
            CustomText(
              AppLabels.requestRejected.tr,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              AppLabels.requestRejectedDescription.tr,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalErrorState(CheckGroupApprovalError state) {
    return CustomErrorWidget.fromErrorState(
      errorState: state,
      onRetry: () {
        context.read<CheckGroupApprovalCubit>().checkApproval(
          groupSlug: arguments.groupSlug,
        );
      },
    );
  }

  Widget _buildPrivateTopicCard(RequestPrivateGroupState state) {
    final bool isLoading = state is RequestPrivateGroupProgress;
    final bool isSuccess = state is RequestPrivateGroupSuccess;

    return Center(
      child: CustomCard(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              AppLabels.privateGroup.tr,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              AppLabels.sendRequestToJoin.tr,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomButton(
              height: 40,
              title: isSuccess
                  ? AppLabels.requestSent.tr
                  : AppLabels.sendRequest.tr,
              onPressed: isLoading || isSuccess ? null : _onTapRequestAccess,
              customTitle: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCountsShimmer(),
          const Divider(height: 1),
          ListView.separated(
            itemCount: 5,
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return const SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              return const CustomShimmer(height: 100);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(FetchQuestionsSuccess state) {
    if (state.data.isEmpty) {
      return Center(
        child: CustomText(
          AppLabels.noQuestionsFound.tr,
          style: TextStyle(fontSize: context.font.medium),
        ),
      );
    }

    // Extract totals from API response if available
    final totalQuestions = state.total;
    final totalReplies = state.data.fold<int>(
      0,
      (sum, question) => sum + question.repliesCount,
    );

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          _buildCounts(
            totalQuestions: totalQuestions,
            totalReplies: totalReplies,
          ),
          const Divider(height: 1),
          ListView.separated(
            itemCount: state.data.length + (state.isLoadingMore ? 1 : 0),
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return const SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              if (index == state.data.length && state.isLoadingMore) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final question = state.data[index];
              return HelpDiscussionCard(question: question);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(FetchQuestionsError state) {
    return CustomErrorWidget.fromErrorState(
      errorState: state,
      onRetry: () {
        context.read<FetchQuestionsCubit>().fetch(groupId: arguments.groupId);
      },
    );
  }

  Widget _buildCountsShimmer() {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        spacing: 20,
        children: [
          CustomShimmer(width: 150, height: 24),
          CustomShimmer(width: 150, height: 24),
        ],
      ),
    );
  }

  Widget _buildCounts({
    required int totalQuestions,
    required int totalReplies,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        spacing: 20,
        children: [
          _buildCount(
            icon: AppIcons.questionMessage,
            count: totalQuestions,
            title: AppLabels.questions.tr,
          ),
          _buildCount(
            icon: AppIcons.redu,
            count: totalReplies,
            title: AppLabels.repliesCount.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildCount({
    required String icon,
    required int count,
    required String title,
  }) {
    return Row(
      children: [
        CustomImage(
          icon,
          width: 24,
          height: 24,
          color: context.color.onSurface,
        ),
        const SizedBox(width: 2),
        CustomText(
          count.toString(),
          fontSize: context.font.small,
          fontWeight: .w600,
        ),
        const SizedBox(width: 4),
        CustomText(title, fontSize: context.font.small, fontWeight: .w400),
      ],
    );
  }
}
