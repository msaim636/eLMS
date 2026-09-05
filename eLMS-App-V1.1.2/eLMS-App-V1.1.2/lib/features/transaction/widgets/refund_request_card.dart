import 'package:elms/common/enums.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/features/transaction/models/my_refund_model.dart';
import 'package:elms/features/transaction/widgets/transaction_info_tile.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class RefundRequestCard extends StatelessWidget {
  final MyRefundModel refund;
  const RefundRequestCard({super.key, required this.refund});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const .all(8),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            spacing: 12,
            children: [
              CustomImage(
                refund.course.thumbnail,
                width: 45,
                height: 45,
                fit: .cover,
                radius: 4,
              ),
              Column(
                crossAxisAlignment: .start,
                children: [
                  CustomText(
                    refund.course.title,
                    style: TextStyle(
                      fontSize: context.font.small,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${AppLabels.by.tr} ',
                          style: TextStyle(
                            fontSize: context.font.xSmall,
                            color: context.color.textSecondary,
                          ),
                        ),
                        TextSpan(
                          text: refund.course.creatorName,
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
            ],
          ),

          const Divider(),
          if (refund.adminNotes != null &&
              refund.status == RefundStatus.rejected) ...{
            TransactionInfoTile(
              title: AppLabels.rejectionReason.tr,
              value: refund.adminNotes!,
            ),
            const Divider(),
          },
          if (refund.userMediaUrl != null) ...{
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(refund.userMediaUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: TransactionInfoTile(
                title: AppLabels.attachedMedia.tr,
                value: refund.userMediaUrl!.split('/').last,
              ),
            ),

            const Divider(),
          },
          Row(
            children: [
              CustomText(
                AppLabels.amount.tr,
                style: TextStyle(
                  fontSize: context.font.small,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              CustomText(
                refund.refundAmount.toString().currency,
                style: TextStyle(
                  fontSize: context.font.medium,
                  color: context.color.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildStatusChip(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    return CustomCard(
      color: refund.status.color.withValues(alpha: 0.1),
      borderRadius: 4,
      borderColor: Colors.transparent,
      padding: const .symmetric(vertical: 4, horizontal: 8),
      child: CustomText(
        refund.status.name.capitalize.toString(),
        style: TextStyle(
          fontSize: context.font.small,
          color: refund.status.color,
          fontWeight: .w500,
        ),
      ),
    );
  }
}
