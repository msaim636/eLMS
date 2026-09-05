import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/transaction/models/transaction_history_model.dart';
import 'package:elms/features/transaction/widgets/refund_request_dialog.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurchaseDetailsBottomSheet extends StatelessWidget {
  final List<TransactionCourseModel> courses;

  const PurchaseDetailsBottomSheet({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(16.0),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            AppLabels.viewDetails.tr,
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 15),

          ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final course = courses[index];
              return _buildCourseCard(context, course);
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 14);
            },
            itemCount: courses.length,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, TransactionCourseModel course) {
    return CustomCard(
      padding: const .all(8),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              CustomImage(
                course.image,
                width: 45,
                height: 45,
                fit: .cover,
                radius: 4,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    CustomText(
                      course.title,
                      style: TextStyle(
                        fontSize: context.font.small,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${AppLabels.by.tr} ',
                            style: TextStyle(fontSize: context.font.xSmall),
                          ),
                          TextSpan(
                            text: course.creatorName,
                            style: TextStyle(
                              fontSize: context.font.xSmall,
                              color: context.color.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CustomText(
                course.finalPrice.toString().currency,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Container(
            height: 1,
            margin: const .symmetric(vertical: 14),
            color: context.color.outline,
          ),
          Row(
            children: [
              if (course.refundRequestStatus != RefundStatus.approved) ...[
                _buildStatusBadge(context, course),
                const SizedBox(width: 14),
              ],
              const Spacer(),
              if (course.refundRequestStatus == RefundStatus.approved)
                const Spacer(),
              _buildRefundRequestBadge(context, course),
            ],
          ),
          if (course.refundRequestStatus == RefundStatus.rejected &&
              course.refundRequestStatus != RefundStatus.none) ...[
            Container(
              height: 1,
              margin: const .symmetric(vertical: 14),
              color: context.color.outline,
            ),

            _buildRejectionNote(context, course),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    TransactionCourseModel course,
  ) {
    final Color backgroundColor;
    final Color textColor;
    final String label;

    if (course.refundRequestStatus == RefundStatus.pending) {
      backgroundColor = const Color(0xFFE29512).withValues(alpha: 0.1);
      textColor = const Color(0xFFE29512);
      label = AppLabels.pending.tr;
    } else if (course.refundRequestStatus == RefundStatus.rejected) {
      backgroundColor = const Color(0xFFDB3D26).withValues(alpha: 0.1);
      textColor = const Color(0xFFDB3D26);
      label = AppLabels.rejected.tr;
    } else {
      return const SizedBox.shrink();
    }

    return CustomCard(
      color: backgroundColor,
      borderColor: Colors.transparent,
      borderRadius: 4,
      padding: const .symmetric(vertical: 4, horizontal: 8),
      child: CustomText(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(color: textColor),
      ),
    );
  }

  Widget _buildRefundRequestBadge(
    BuildContext context,
    TransactionCourseModel course,
  ) {
    final bool isEnabled = course.canRequestRefund;
    final Color backgroundColor = isEnabled
        ? context.color.onSurface
        : context.color.textSecondary.withValues(alpha: 0.3);

    return GestureDetector(
      onTap: isEnabled
          ? () async {
              final result = await UiUtils.showDialog(
                context,
                child: RefundRequestDialog.create(course: course),
              );
              if (result == true && context.mounted) {
                // Refresh the purchase screen
                Navigator.pop(context, true);
              }
            }
          : null,
      child: CustomCard(
        color: backgroundColor,
        borderColor: Colors.transparent,
        borderRadius: 4,
        padding: const .symmetric(vertical: 4, horizontal: 8),
        child: CustomText(
          AppLabels.refundRequest.tr,
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: context.color.surface),
        ),
      ),
    );
  }

  Widget _buildRejectionNote(
    BuildContext context,
    TransactionCourseModel course,
  ) {
    if (course.refundAdminNotes == null) return const SizedBox.shrink();

    return CustomCard(
      color: const Color(0xFFDB3D26).withValues(alpha: 0.1),
      borderColor: Colors.transparent,
      padding: const .all(8),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Container(
            padding: const .all(8),
            child: CustomImage(AppIcons.infoFilled),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                CustomText(
                  AppLabels.rejectionNote.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                CustomText(
                  course.refundAdminNotes!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
