import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_dialog_box.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteAssignmentDialog extends StatelessWidget {
  final String fileName;
  const DeleteAssignmentDialog({super.key, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return CustomDialogBox(
      // title: AppLabels.deleteAssignmentConfirmation.tr,
      content: CustomText(
        '${AppLabels.deleteAccountPermanent.tr}\n"$fileName"?',
        style: TextStyle(fontSize: context.font.medium),
        textAlign: .center,
      ),
      showHeader: false,
      actions: [
        DialogButton(
          title: AppLabels.yes.tr,
          style: DialogButtonStyle.primary,
          color: context.color.error,
          onTap: () {},
        ),
        DialogButton(
          title: AppLabels.cancel.tr,
          style: DialogButtonStyle.outlined,
          onTap: () {},
        ),
      ],
    );
  }
}
