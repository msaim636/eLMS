import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:flutter/material.dart';

class CategoryShimmer extends StatelessWidget implements IShimmer {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomCard(
      width: 160,
      padding: .all(8),
      child: Row(
        spacing: 12,
        children: [
          CustomShimmer(width: 48, height: 48),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .spaceEvenly,
              children: [
                CustomShimmer(height: 10, width: 70, borderRadius: 4),
                CustomShimmer(height: 10, width: 50, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
