import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:flutter/material.dart';

class CartCourseCardShimmer extends StatelessWidget {
  const CartCourseCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomCard(
      padding: EdgeInsets.all(10),
      child: Column(
        spacing: 8,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              CustomShimmer(width: 87, height: 87, borderRadius: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmer(height: 12, width: 80, borderRadius: 4),
                    SizedBox(height: 7),
                    CustomShimmer(height: 14, borderRadius: 4),
                    SizedBox(height: 4),
                    CustomShimmer(height: 12, width: 120, borderRadius: 4),
                    SizedBox(height: 6),
                    CustomShimmer(height: 14, width: 70, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: CustomShimmer(height: 14, width: 80, borderRadius: 4),
                ),
              ),
              SizedBox(width: 1, height: 16),
              Expanded(
                child: Center(
                  child: CustomShimmer(height: 14, width: 110, borderRadius: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
