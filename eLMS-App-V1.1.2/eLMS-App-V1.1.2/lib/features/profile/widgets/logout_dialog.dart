import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_dialog_box.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticatedAsGuest) {
          Get.offAllNamed(AppRoutes.loginScreen);
        }
      },
      child: CustomDialogBox(
        title: AppLabels.logoutAccount.tr,
        actions: [
          DialogButton(
            title: AppLabels.no.tr,
            style: DialogButtonStyle.primary,
            onTap: () {
              Get.back();
            },
          ),
          DialogButton(
            title: AppLabels.confirmDialog.tr,
            style: DialogButtonStyle.outlined,
            onTap: () {
              context.read<AuthenticationCubit>().signOut();
            },
            color: context.color.primary,
          ),
        ],
        content: Column(
          mainAxisSize: .min,
          children: [
            CustomImage(AppIcons.logoutIcon),
            Padding(
              padding: const .symmetric(vertical: 20),
              child: CustomText(
                AppLabels.logoutConfirmation.tr,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(fontWeight: .w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
