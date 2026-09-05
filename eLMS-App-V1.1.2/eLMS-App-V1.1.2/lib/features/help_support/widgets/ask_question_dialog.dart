import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_dialog_box.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/help_support/cubits/ask_question_cubit.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class AskQuestionDialog extends StatefulWidget {
  final int groupId;
  final String topicName;

  const AskQuestionDialog({
    super.key,
    required this.groupId,
    required this.topicName,
  });

  @override
  State<AskQuestionDialog> createState() => _AskQuestionDialogState();
}

class _AskQuestionDialogState extends State<AskQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onTapPublish() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AskQuestionCubit>().askQuestion(
        groupId: widget.groupId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );
    }
  }

  void _onTapCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AskQuestionCubit, AskQuestionState>(
      listener: (context, state) {
        if (state is AskQuestionSuccess) {
          Navigator.of(context).pop(true);
          UiUtils.showSnackBar(
            state.response['message'] ?? AppLabels.questionPosted.tr,
          );
        } else if (state is AskQuestionFail) {
          UiUtils.showSnackBar(UiUtils.friendlyErrorMessage(state.error), isError: true);
        }
      },
      builder: (context, state) {
        final isLoading = state is AskQuestionInProgress;

        return CustomDialogBox(
          title: AppLabels.askQuestion.tr,
          actions: [
            DialogButton(
              title: AppLabels.cancel.tr,
              style: DialogButtonStyle.outlined,
              color: context.color.primary,
              onTap: isLoading ? null : _onTapCancel,
            ),
            DialogButton(
              title: AppLabels.publish.tr,
              style: DialogButtonStyle.primary,
              onTap: isLoading ? null : _onTapPublish,
            ),
          ],
          content: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: .start,
              spacing: 16,
              mainAxisSize: .min,
              children: [
                CustomText(
                  widget.topicName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: .w500),
                ),
                CustomTextFormField(
                  controller: _titleController,
                  isRequired: true,
                  title: AppLabels.title.tr,
                  hintText: AppLabels.askQuestionTitleHint.tr,
                  fillColor: context.color.outline.withValues(alpha: .17),
                  enabled: !isLoading,
                  requiredErrorMessage: AppLabels.questionTitleRequired.tr,
                ),
                CustomTextFormField(
                  controller: _descriptionController,
                  isRequired: true,
                  title: AppLabels.description.tr,
                  minLines: 3,
                  isMultiline: true,
                  hintText: AppLabels.askQuestionDescriptionHint.tr,
                  fillColor: context.color.outline.withValues(alpha: .17),
                  enabled: !isLoading,
                  requiredErrorMessage: AppLabels.descriptionRequired.tr,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
