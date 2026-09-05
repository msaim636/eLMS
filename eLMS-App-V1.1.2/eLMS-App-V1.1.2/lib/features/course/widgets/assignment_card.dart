import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/animated_showmore_container.dart';
import 'package:elms/common/widgets/custom_expandable_tile.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/course/cubit/assignment_cubit.dart';
import 'package:elms/features/course/models/assignment_model.dart';
import 'package:elms/features/course/models/assignment_submission_model.dart';
import 'package:elms/features/course/widgets/edit_assignment_dialog.dart';
import 'package:elms/features/course/widgets/upload_assignment_dialog.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/file_download_helper.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final int chapterId;
  final int index;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.chapterId,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return CustomExpandableTile(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      borderColor: Colors.transparent,
      dividerColor: Colors.transparent,
      isIconTop: true,
      customTitle: _buildTitleSection(context),
      content: _buildContentSection(context),
      onToggle: () {},
      customIcon: CustomImage(
        AppIcons.pointDown,
        color: context.color.onSurface,
        width: 20,
        height: 20,
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Row(
      crossAxisAlignment: .start,
      children: [
        _buildIndexBadge(context),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              CustomText(
                assignment.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontWeight: .w500),
              ),
              CustomText(
                '${assignment.points} ${AppLabels.points.tr}',
                style: TextStyle(
                  fontSize: context.font.xSmall,
                  color: context.color.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndexBadge(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: context.color.onSurface,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: .center,
      child: CustomText(
        (index + 1).toString().padLeft(2, '0'),
        style: TextStyle(
          fontSize: context.font.small,
          color: context.color.surface,
          fontWeight: .w400,
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Column(
      spacing: 16,
      crossAxisAlignment: .start,
      children: [
        _buildDescription(context),
        if (assignment.media != null) _buildDownloadButton(context),
        _buildMyAssignmentsSection(context),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return AnimatedShowMore(
      content: assignment.description,
      maxLines: 2,
      textStyle: TextStyle(color: context.color.textSecondary, fontSize: 12),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTapDownloadFile(assignment.mediaUrl),
      child: Container(
        width: double.infinity,
        padding: const .all(12),
        decoration: BoxDecoration(
          border: Border.all(color: context.color.outline),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.color.info,
                borderRadius: BorderRadius.circular(6),
              ),
              child: CustomImage(
                AppIcons.documentDownload,
                color: context.color.onPrimary,
                fit: .none,
                width: 25,
                height: 25,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomText(
                (assignment.media ?? "").split('/').last,
                style: TextStyle(fontSize: context.font.small),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyAssignmentsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.color.outline.withValues(alpha: 0.1)),
      ),
      padding: const .all(8),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _buildSectionHeader(context),
          const Divider(),
          if (assignment.submissions.isEmpty)
            _buildNoAssignmentsSubmitted(context)
          else
            ..._buildSubmissionsList(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Container(
      padding: const .symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.color.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: CustomText(
        AppLabels.myAssignments.tr,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(fontWeight: .w500),
      ),
    );
  }

  List<Widget> _buildSubmissionsList(BuildContext context) {
    return assignment.submissions.map((submission) {
      return _buildSubmittedAssignment(context, submission);
    }).toList();
  }

  Widget _buildSubmittedAssignment(
    BuildContext context,
    AssignmentSubmissionModel submission,
  ) {
    final bool showControls = submission.status == SubmissionStatus.submitted;
    final bool showResubmitButton =
        submission.canResubmit &&
        submission.status == SubmissionStatus.rejected;
    // Use warning color for submitted status (shows as "In Review")
    final Color statusColor = submission.status == SubmissionStatus.submitted
        ? Theme.of(context).colorScheme.warning
        : submission.status.getColor(context);
    final bool isError =
        submission.status == SubmissionStatus.rejected ||
        submission.status == SubmissionStatus.suspended;

    return Column(
      children: [
        _buildSubmissionHeader(
          context,
          submission: submission,
          statusColor: statusColor,
          showControls: showControls,
        ),
        const SizedBox(height: 16),
        if (showResubmitButton) ...[
          _buildResubmitButton(context),
          const SizedBox(height: 6),
        ],
        if (submission.status == SubmissionStatus.accepted ||
            submission.status == SubmissionStatus.rejected ||
            submission.status == SubmissionStatus.suspended)
          _buildSubmissionFeedback(
            context,
            submission: submission,
            statusColor: statusColor,
            isError: isError,
          ),
      ],
    );
  }

  Widget _buildSubmissionHeader(
    BuildContext context, {
    required AssignmentSubmissionModel submission,
    required Color statusColor,
    required bool showControls,
  }) {
    // Show "In Review" for both submitted and inReview statuses
    // since submitted assignments are waiting for teacher review
    final String statusLabel =
        (submission.status == SubmissionStatus.submitted ||
            submission.status == SubmissionStatus.inReview)
        ? AppLabels.assignmentStatusInReview.tr
        : submission.statusLabel;

    return Container(
      width: double.maxFinite,
      padding: const .symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              spacing: 8,
              children: [
                Flexible(
                  flex: showControls ? 1 : 2,
                  child: CustomText(
                    submission.fileName ?? '',
                    style: TextStyle(fontSize: context.font.small),
                  ),
                ),
                Expanded(child: _buildStatusBadge(statusLabel, statusColor)),
              ],
            ),
          ),
          if (showControls) _buildEditButton(context, submission),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color statusColor) {
    return CustomText(
      '·  $status',
      maxLines: 1,
      style: TextStyle(fontSize: 14, color: statusColor, fontWeight: .w400),
    );
  }

  Widget _buildEditButton(
    BuildContext context,
    AssignmentSubmissionModel submission,
  ) {
    return GestureDetector(
      onTap: () => _onTapEditSubmission(context, submission),
      child: CustomImage(
        AppIcons.edit2,
        color: context.color.onSurface,
        width: 20,
        height: 20,
      ),
    );
  }

  Widget _buildResubmitButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const .symmetric(horizontal: 8),
      child: MaterialButton(
        onPressed: () => _onTapResubmit(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: context.color.onSurface),
        ),
        child: CustomText(
          AppLabels.resubmit.tr,
          style: TextStyle(fontSize: context.font.small),
        ),
      ),
    );
  }

  Widget _buildSubmissionFeedback(
    BuildContext context, {
    required AssignmentSubmissionModel submission,
    required Color statusColor,
    required bool isError,
  }) {
    final Color backgroundColor = isError
        ? context.color.error
        : context.color.info;
    final String message = submission.status == SubmissionStatus.submitted
        ? AppLabels.assignmentSubmittedMessage.tr
        : submission.feedback ?? '';

    if (message.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const .all(8),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: backgroundColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const .all(8),
            child: CustomImage(
              isError ? AppIcons.closeCircle : AppIcons.check,
              color: isError ? statusColor : context.color.info,
              width: 20,
              height: 20,
            ),
          ),

          const SizedBox(width: 4),
          Expanded(
            child: CustomText(
              message,
              style: TextStyle(fontSize: context.font.small),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAssignmentsSubmitted(BuildContext context) {
    return Container(
      padding: const .symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          CustomText(
            AppLabels.noAssignmentsSubmittedYet.tr,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: .w500),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const .symmetric(horizontal: 12),
            child: CustomText(
              AppLabels.assignmentsEmptyStateDescription.tr,
              style: TextStyle(
                fontSize: context.font.xSmall,
                color: context.color.textSecondary,
              ),
              textAlign: .center,
            ),
          ),
          const SizedBox(height: 16),
          _buildAddAssignmentButton(context),
        ],
      ),
    );
  }

  Widget _buildAddAssignmentButton(BuildContext context) {
    return MaterialButton(
      onPressed: () => _onTapAddAssignment(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: context.color.textSecondary),
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          CustomImage(
            AppIcons.addCircle,
            color: context.color.onSurface,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          CustomText(
            AppLabels.addAssignment.tr,
            style: TextStyle(
              fontSize: context.font.small,
              fontWeight: .w400,
              color: context.color.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _onTapDownloadFile(String? fileUrl) async {
    if (fileUrl == null || fileUrl.isEmpty) {
      UiUtils.showSnackBar('File URL not available', isError: true);
      return;
    }

    await FileDownloadHelper.downloadOrOpenFile(fileUrl);
  }

  void _onTapEditSubmission(
    BuildContext context,
    AssignmentSubmissionModel submission,
  ) {
    UiUtils.showDialog(
      context,
      child: BlocProvider.value(
        value: context.read<AssignmentCubit>(),
        child: EditAssignmentDialog(
          submissionId: submission.id,
          courseId: assignment.courseId,
          chapterId: chapterId,
          existingComment: submission.comment,
          existingFileName: submission.fileName ?? '',
          allowedFileTypes: assignment.allowedFileTypes,
        ),
      ),
    );
  }

  void _onTapResubmit(BuildContext context) {
    UiUtils.showDialog(
      context,
      child: BlocProvider.value(
        value: context.read<AssignmentCubit>(),
        child: UploadAssignmentDialog(
          assignmentId: assignment.id,
          chapterId: chapterId,
          courseId: assignment.courseId,
          allowedFileTypes: assignment.allowedFileTypes,
        ),
      ),
    );
  }

  void _onTapAddAssignment(BuildContext context) {
    UiUtils.showDialog(
      context,
      child: BlocProvider.value(
        value: context.read<AssignmentCubit>(),
        child: UploadAssignmentDialog(
          assignmentId: assignment.id,
          chapterId: chapterId,
          courseId: assignment.courseId,
          allowedFileTypes: assignment.allowedFileTypes,
        ),
      ),
    );
  }
}
