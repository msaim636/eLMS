import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:flutter/material.dart';

class WishlistCardShimmer extends StatelessWidget {
  const WishlistCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomCard(
      borderRadius: 6,
      height: 177,
      border: 0,
      padding: EdgeInsets.all(8),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    spacing: 4,
                    children: [
                      CustomShimmer(height: 12, width: 80, borderRadius: 4),
                      CustomShimmer(height: 14, borderRadius: 4),
                      CustomShimmer(height: 14, width: 120, borderRadius: 4),
                      SizedBox(height: 4),
                      CustomShimmer(height: 14, width: 60, borderRadius: 4),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 6,
                    children: [
                      Expanded(child: CustomShimmer(borderRadius: 4)),
                      CustomShimmer(height: 36, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Divider(height: 8),
          Spacer(),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CustomShimmer(height: 12, width: 120, borderRadius: 4),
          ),
        ],
      ),
    );
  }
}
