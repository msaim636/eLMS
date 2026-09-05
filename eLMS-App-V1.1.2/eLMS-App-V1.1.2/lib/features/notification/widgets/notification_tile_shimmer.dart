import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:flutter/material.dart';

class NotificationTileShimmer extends StatelessWidget {
  const NotificationTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomCard(
      padding: EdgeInsets.all(10),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomShimmer(height: 14, borderRadius: 4),
                SizedBox(height: 6),
                CustomShimmer(height: 12, borderRadius: 4),
                SizedBox(height: 4),
                CustomShimmer(height: 12, borderRadius: 4),
                SizedBox(height: 4),
                CustomShimmer(height: 12, width: 140, borderRadius: 4),
                Divider(height: 16),
                CustomShimmer(height: 10, width: 80, borderRadius: 4),
              ],
            ),
          ),
          CustomShimmer(width: 90, height: 90, borderRadius: 4),
        ],
      ),
    );
  }
}
