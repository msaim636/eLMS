import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:flutter/material.dart';

class TransactionCardShimmer extends StatelessWidget {
  const TransactionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomCard(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            children: [
              Expanded(child: CustomShimmer(height: 14, borderRadius: 4)),
              SizedBox(width: 12),
              CustomShimmer(height: 24, width: 60, borderRadius: 4),
            ],
          ),
          Divider(height: 0),
          _InfoTileShimmer(),
          _InfoTileShimmer(),
          _InfoTileShimmer(),
          Divider(height: 0),
          Row(
            children: [
              CustomShimmer(height: 14, width: 60, borderRadius: 4),
              SizedBox(width: 8),
              CustomShimmer(height: 14, width: 50, borderRadius: 4),
              Spacer(),
              CustomShimmer(height: 24, width: 80, borderRadius: 4),
              SizedBox(width: 8),
              CustomShimmer(height: 24, width: 70, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTileShimmer extends StatelessWidget {
  const _InfoTileShimmer();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomShimmer(height: 12, width: 100, borderRadius: 4),
        SizedBox(height: 4),
        CustomShimmer(height: 12, width: 160, borderRadius: 4),
      ],
    );
  }
}
