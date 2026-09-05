import 'package:elms/common/enums.dart';
import 'package:elms/common/models/message_model.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/core/login/guest_checker.dart';
import 'package:elms/features/course/cubits/create_discussion_cubit.dart';
import 'package:elms/features/course/cubits/fetch_discussion_cubit.dart';
import 'package:elms/features/help_support/cubits/fetch_question_details_cubit.dart';
import 'package:elms/features/help_support/cubits/reply_question_cubit.dart';
import 'package:elms/features/help_support/models/help_desk_reply_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class MessageBottomBar extends StatefulWidget {
  final DiscussionDestination destination;
  final int id;
  final int? parentDiscussionId;
  const MessageBottomBar({
    super.key,
    required this.id,
    required this.destination,
    this.parentDiscussionId,
  });

  @override
  State<MessageBottomBar> createState() => _MessageBottomBarState();
}

class _MessageBottomBarState extends State<MessageBottomBar> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<bool> _isAlignedEnd = ValueNotifier(false);

  int textFieldMaxLines = 6;

  @override
  void initState() {
    super.initState();
    const calculationStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
    _controller.addListener(() {
      final calculated = calculateTextLines(
        text: _controller.text,
        style: calculationStyle,
        maxWidth: context.screenWidth * 0.71,
      );
      if (calculated >= 4) {
        _isAlignedEnd.value = true;
      } else {
        _isAlignedEnd.value = false;
      }
    });
  }

  @override
  void deactivate() {
    // Close the IME connection before this widget (and its text field) is
    // removed from the tree (e.g. navigating back with the keyboard open),
    // otherwise the EditableText is unmounted mid IME edit and throws an
    // "unfinished batch edits" assertion.
    FocusManager.instance.primaryFocus?.unfocus();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _isLoading.dispose();
    _isAlignedEnd.dispose();

    super.dispose();
  }

  int calculateTextLines({
    required String text,
    required TextStyle style,
    required double maxWidth,
  }) {
    final textSpan = TextSpan(text: text, style: style);

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: maxWidth);

    final lineCount = textPainter.computeLineMetrics().length;

    return lineCount;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CreateDiscussionCubit()),
        BlocProvider(create: (context) => ReplyQuestionCubit()),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocListener(
            listeners: [
              BlocListener<CreateDiscussionCubit, CreateDiscussionState>(
                listener: (context, state) {
                  if (state is CreateDiscussionInProgress) {
                    _isLoading.value = true;
                  } else if (state is CreateDiscussionSuccess) {
                    _isLoading.value = false;
                    // If it's a reply to a parent discussion, insert it into that discussion's replies
                    if (widget.parentDiscussionId != null) {
                      // Convert DiscussionModel to Message for nested reply
                      final Message reply = Message(
                        id: state.discussion.id,
                        content: state.discussion.content,
                        senderId: state.discussion.senderId,
                        receiverId: state.discussion.receiverId,
                        timestamp: state.discussion.timestamp,
                        type: 'reply',
                        userName: state.discussion.userName,
                        userSubtitle: state.discussion.userSubtitle,
                        profile: state.discussion.profile,
                        timesAgo: state.discussion.timesAgo,
                      );
                      context.read<FetchDiscussionCubit>().insertReply(
                        reply,
                        widget.parentDiscussionId.toString(),
                      );
                    } else {
                      // Top-level discussion
                      context.read<FetchDiscussionCubit>().insert(
                        state.discussion,
                      );
                    }
                    _controller.clear();
                  } else if (state is CreateDiscussionFail) {
                    if (state.error case final ApiException error) {
                      UiUtils.showSnackBar(error.message ?? '', isError: true);
                    } else {
                      UiUtils.showSnackBar(
                        UiUtils.friendlyErrorMessage(state.error),
                        isError: true,
                      );
                    }
                    _isLoading.value = false;
                  }
                },
              ),
              BlocListener<ReplyQuestionCubit, ReplyQuestionState>(
                listener: (context, state) {
                  if (state is ReplyQuestionInProgress) {
                    _isLoading.value = true;
                  } else if (state is ReplyQuestionSuccess) {
                    _isLoading.value = false;
                    // Convert Message to HelpDeskReplyModel and insert
                    final Message reply = state.reply;
                    final HelpDeskReplyModel helpDeskReply = HelpDeskReplyModel(
                      id: int.tryParse(reply.id) ?? 0,
                      reply: reply.content,
                      createdAt: reply.timestamp,
                      timeAgo: reply.timesAgo,
                      author: ReplyAuthor(
                        id: int.tryParse(reply.senderId) ?? 0,
                        name: reply.userName,
                        avatar: reply.profile.isNotEmpty ? reply.profile : null,
                      ),
                    );
                    context.read<FetchQuestionDetailsCubit>().insertReply(
                      helpDeskReply,
                    );
                    _controller.clear();
                  } else if (state is ReplyQuestionFail) {
                    if (state.error case final ApiException error) {
                      UiUtils.showSnackBar(error.message ?? '', isError: true);
                    } else {
                      UiUtils.showSnackBar(
                        UiUtils.friendlyErrorMessage(state.error),
                        isError: true,
                      );
                    }

                    _isLoading.value = false;
                  }
                },
              ),
            ],
            child: Container(
              padding: const .symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        controller: _controller,
                        hintText: AppLabels.typeMessage.tr,
                        isMultiline: true,
                        minLines: 1,
                        maxLines: textFieldMaxLines,
                        requiredErrorMessage: AppLabels.fieldRequired.tr,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isAlignedEnd,
                      builder: (context, isAlignedEnd, child) {
                        return AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          alignment: isAlignedEnd
                              ? Alignment.bottomCenter
                              : Alignment.center,
                          child: child,
                        );
                      },
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isLoading,
                        builder: (context, isLoading, child) {
                          return CustomButton(
                            width: 40,
                            customTitle: isLoading
                                ? const SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : CustomImage(AppIcons.sendMessage),
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_controller.text.isNotEmpty) {
                                      if (widget.destination ==
                                          DiscussionDestination.course) {
                                        context
                                            .read<CreateDiscussionCubit>()
                                            .create(
                                              text: _controller.text,
                                              courseId: widget.id,
                                              parentDiscussionId:
                                                  widget.parentDiscussionId,
                                            );
                                      } else {
                                        GuestChecker.check(
                                          onNotGuest: () {
                                            context
                                                .read<ReplyQuestionCubit>()
                                                .reply(
                                                  id: widget.id,
                                                  reply: _controller.text,
                                                );
                                          },
                                        );
                                      }
                                    }
                                  },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
