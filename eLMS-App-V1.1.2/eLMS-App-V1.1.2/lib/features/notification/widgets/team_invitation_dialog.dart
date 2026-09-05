import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_dialog_box.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/notification/cubits/team_invitation_cubit.dart';
import 'package:elms/features/notification/models/notification_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class TeamInvitationDialog extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onDone;

  const TeamInvitationDialog({
    super.key,
    required this.notification,
    this.onDone,
  });

  static void show(
    BuildContext context,
    NotificationModel notification, {
    VoidCallback? onDone,
  }) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => TeamInvitationCubit(),
        child: TeamInvitationDialog(notification: notification, onDone: onDone),
      ),
    ).then((_) => onDone?.call());
  }

  String? _getInvitationToken() {
    final token = notification.teamMembers?.invitationToken;
    if (token != null && token.isNotEmpty) return token;
    // Fallback: use typeId as token if available
    final typeId = notification.typeId;
    if (typeId != 0) return typeId.toString();
    return null;
  }

  void _onTapAccept(BuildContext context) {
    final invitationToken = _getInvitationToken();
    if (invitationToken == null) {
      UiUtils.showSnackBar(AppLabels.somethingWentWrong.tr, isError: true);
      return;
    }

    context.read<TeamInvitationCubit>().handleInvitation(
      action: 'accept',
      invitationToken: invitationToken,
    );
  }

  void _onTapDecline(BuildContext context) {
    final invitationToken = _getInvitationToken();
    if (invitationToken == null) {
      UiUtils.showSnackBar(AppLabels.somethingWentWrong.tr, isError: true);
      return;
    }

    context.read<TeamInvitationCubit>().handleInvitation(
      action: 'reject',
      invitationToken: invitationToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamInvitationCubit, TeamInvitationState>(
      listener: (context, state) {
        if (state is TeamInvitationSuccess) {
          Navigator.pop(context);
          final message = state.action == 'accept'
              ? AppLabels.invitationAccepted.tr
              : AppLabels.invitationDeclined.tr;
          UiUtils.showSnackBar(message);
        } else if (state is TeamInvitationFail) {
          Navigator.pop(context);
          UiUtils.showSnackBar(UiUtils.friendlyErrorMessage(state.error), isError: true);
        }
      },
      builder: (context, state) {
        final bool isLoading = state is TeamInvitationInProgress;
        final String teamName = notification.instructorDetails?.name ?? 'Team';

        return CustomDialogBox(
          title: AppLabels.teamInvitation.tr,
          content: Column(
            mainAxisSize: .min,
            children: [
              CustomText(
                AppLabels.teamInvitationMessage.tr.replaceAll(
                  '{{teamName}}',
                  teamName,
                ),
                style: TextStyle(
                  fontSize: context.font.small,
                  color: context.color.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            DialogButton(
              title: AppLabels.decline.tr,
              onTap: isLoading ? null : () => _onTapDecline(context),
              color: context.color.error,
              style: DialogButtonStyle.outlined,
            ),
            DialogButton(
              title: AppLabels.accept.tr,
              onTap: isLoading ? null : () => _onTapAccept(context),
              color: context.color.primary,
              style: DialogButtonStyle.primary,
            ),
          ],
        );
      },
    );
  }
}
