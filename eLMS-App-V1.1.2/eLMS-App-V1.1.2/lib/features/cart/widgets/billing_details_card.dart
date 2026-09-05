import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BillingDetailsCard extends StatelessWidget {
  final String? companyName;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? taxId;
  final VoidCallback? onEdit;

  const BillingDetailsCard({
    super.key,
    this.companyName,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.taxId,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderRadius: 4,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  AppLabels.billingDetails.tr,
                  style: TextStyle(
                    fontSize: context.font.medium,
                    fontWeight: FontWeight.w500,
                    color: context.color.onSurface,
                  ),
                ),
              ),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.color.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          AppLabels.edit.tr,
                          style: TextStyle(
                            fontSize: context.font.small,
                            fontWeight: FontWeight.w500,
                            color: context.color.surface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        CustomImage(
                          AppIcons.edit2,
                          width: 18,
                          height: 18,
                          color: context.color.surface,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: context.color.outline),
          const SizedBox(height: 12),
          if (companyName != null)
            _buildInfoRow(context, AppLabels.companyName.tr, companyName!),
          if (address != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(context, '${AppLabels.address.tr}:', address!),
          ],
          if (city != null || state != null || zipCode != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              AppLabels.cityStateZip.tr,
              _buildCityStateZip(),
            ),
          ],
          if (country != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(context, '${AppLabels.country.tr}:', country!),
          ],
          if (taxId != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(context, '${AppLabels.taxId.tr}:', taxId!),
          ],
        ],
      ),
    );
  }

  String _buildCityStateZip() {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    return parts.join(', ');
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label,
          style: TextStyle(
            fontSize: context.font.xSmall,
            color: context.color.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        CustomText(
          value,
          style: TextStyle(
            fontSize: context.font.small,
            fontWeight: FontWeight.w500,
            color: context.color.onSurface,
          ),
        ),
      ],
    );
  }
}
