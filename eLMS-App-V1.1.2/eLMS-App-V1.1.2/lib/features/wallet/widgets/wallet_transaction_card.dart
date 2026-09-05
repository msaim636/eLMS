import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_dialog_box.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/transaction/widgets/transaction_info_tile.dart';
import 'package:elms/features/wallet/models/wallet_transaction_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletTransactionCard extends StatefulWidget {
  final WalletTransactionModel transaction;

  const WalletTransactionCard({super.key, required this.transaction});

  @override
  State<WalletTransactionCard> createState() => _WalletTransactionCardState();
}

class _WalletTransactionCardState extends State<WalletTransactionCard> {
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const .all(10),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 10,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  '${AppLabels.transactionId.tr}: ${widget.transaction.orderNumber ?? widget.transaction.transactionId}',
                  style: TextStyle(
                    fontSize: context.font.medium,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  ellipsis: true,
                ),
              ),
              _buildStatusChip(context),
            ],
          ),
          const Divider(height: 0),
          TransactionInfoTile(
            title: AppLabels.date.tr,
            value: widget.transaction.transactionDate?.toFormattedDate ?? '',
          ),
          TransactionInfoTile(
            title: AppLabels.type.tr,
            value: widget.transaction.transactionTypeLabel ?? '',
          ),
          const Divider(height: 0),
          _buildAmountRow(context),
        ],
      ),
    );
  }

  Widget _buildAmountRow(BuildContext context) {
    final bool isCredit = widget.transaction.type == 'credit';
    final String amountText = isCredit
        ? '+${(widget.transaction.amount ?? 0).toString().currency}'
        : '-${(widget.transaction.amount ?? 0).toString().currency}';
    final Color amountColor = isCredit
        ? context.color.success
        : context.color.error;

    return SizedBox(
      width: double.maxFinite,
      child: Row(
        spacing: 8,
        mainAxisAlignment: .spaceBetween,
        children: [
          Row(
            spacing: 8,
            children: [
              CustomText(
                AppLabels.amount.tr,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: .w500),
              ),
              CustomText(
                amountText,
                style: TextStyle(
                  fontSize: context.font.medium,
                  fontWeight: .bold,
                  color: amountColor,
                ),
              ),
            ],
          ),

          if (widget.transaction.paymentDetails != null)
            Flexible(
              child: GestureDetector(
                onTap: _onTapViewDetails,
                child: Container(
                  padding: const .symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.color.outline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      Icon(
                        Icons.remove_red_eye_outlined,
                        size: 16,
                        color: context.color.onSurface,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: CustomText(
                          AppLabels.viewDetails.tr,
                          style: TextStyle(fontSize: context.font.xSmall),
                          ellipsis: true,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onTapViewDetails() {
    final paymentDetails = widget.transaction.paymentDetails;
    if (paymentDetails == null) return;

    final bool isCredit = widget.transaction.type == 'credit';
    final String amountText = isCredit
        ? '+ ${(widget.transaction.amount ?? 0).toString().currency}'
        : '- ${(widget.transaction.amount ?? 0).toString().currency}';
    final Color amountColor = isCredit
        ? context.color.success
        : context.color.error;

    UiUtils.showDialog(
      context,

      child: CustomDialogBox(
        title: AppLabels.bankDetails.tr,
        subtitle: AppLabels.verifyWithdrawalDetails.tr,

        subtitleStyle: TextStyle(fontSize: context.font.small),
        content: CustomCard(
          padding: const .all(16),
          child: Column(
            crossAxisAlignment: .start,
            spacing: 16,
            mainAxisSize: .min,
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  CustomText(
                    AppLabels.amount.tr,
                    style: TextStyle(
                      fontSize: context.font.medium,
                      fontWeight: .w400,
                      color: context.color.textSecondary,
                    ),
                  ),
                  CustomText(
                    amountText,
                    style: TextStyle(
                      fontSize: context.font.xxLarge,
                      fontWeight: .bold,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
              const Divider(height: 0),
              _buildDetailRow(
                context,
                label: AppLabels.accountName.tr,
                value: paymentDetails.accountHolderName ?? '-',
              ),
              const Divider(height: 0),
              _buildDetailRow(
                context,
                label: AppLabels.accountNumber.tr,
                value: paymentDetails.accountNumber ?? '-',
              ),
              const Divider(height: 0),
              _buildDetailRow(
                context,
                label: AppLabels.otherDetails.tr,
                value: paymentDetails.otherDetails ?? '-',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        CustomText(
          label,
          style: TextStyle(
            fontSize: context.font.medium,
            fontWeight: .w400,
            color: context.color.textSecondary,
          ),
        ),
        Flexible(
          child: CustomText(
            value,
            style: TextStyle(
              fontSize: context.font.medium,
              fontWeight: .w600,
              color: context.color.onSurface,
            ),
            textAlign: .end,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final Color statusColor = _getStatusColor();
    final status = widget.transaction.status ?? '';

    return CustomCard(
      color: statusColor.withValues(alpha: 0.1),
      borderRadius: 4,
      borderColor: Colors.transparent,
      padding: const .symmetric(vertical: 4, horizontal: 8),
      child: CustomText(
        status.capitalizeFirst ?? status,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(color: statusColor, fontWeight: .w500),
      ),
    );
  }

  Color _getStatusColor() {
    switch ((widget.transaction.status ?? '').toLowerCase()) {
      case 'approved':
      case 'success':
      case 'completed':
        return context.color.success;
      case 'pending':
        return context.color.warning;
      case 'rejected':
      case 'failed':
        return context.color.error;
      default:
        return context.color.onSurface;
    }
  }
}
