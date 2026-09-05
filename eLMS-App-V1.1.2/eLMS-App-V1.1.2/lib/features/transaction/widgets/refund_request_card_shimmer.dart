import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:flutter/material.dart';

class RefundRequestCardShimmer extends StatelessWidget {
  const RefundRequestCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomCard(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 12,
            children: [
              CustomShimmer(width: 45, height: 45, borderRadius: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    CustomShimmer(height: 12, borderRadius: 4),
                    CustomShimmer(height: 12, width: 100, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          Divider(),
          Row(
            children: [
              CustomShimmer(height: 14, width: 60, borderRadius: 4),
              SizedBox(width: 8),
              CustomShimmer(height: 14, width: 50, borderRadius: 4),
              Spacer(),
              CustomShimmer(height: 24, width: 70, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}
