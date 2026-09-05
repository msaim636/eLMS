import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:flutter/material.dart';

class ReviewShimmer extends StatelessWidget {
  final bool showCard;
  final EdgeInsetsGeometry? padding;

  const ReviewShimmer({super.key, this.showCard = true, this.padding});

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: padding ?? const .all(8),
      child: const Column(
        crossAxisAlignment: .start,
        children: [
          // User info and rating row
          Row(
            children: [
              // User avatar shimmer
              CustomShimmer(width: 48, height: 48, borderRadius: 24),
              SizedBox(width: 16),
              // User name and review date shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    CustomShimmer(width: 120, height: 16, borderRadius: 4),
                    SizedBox(height: 6),
                    CustomShimmer(width: 80, height: 12, borderRadius: 4),
                  ],
                ),
              ),
              // Rating pill shimmer
              CustomShimmer(width: 50, height: 28, borderRadius: 14),
            ],
          ),
          SizedBox(height: 16),
          // Review text shimmer
          CustomShimmer(width: double.infinity, height: 14, borderRadius: 4),
          SizedBox(height: 8),
          CustomShimmer(width: double.infinity, height: 14, borderRadius: 4),
          SizedBox(height: 8),
          CustomShimmer(width: 200, height: 14, borderRadius: 4),
        ],
      ),
    );

    if (showCard) {
      return CustomCard(child: content);
    }

    return content;
  }
}

class ReviewsListShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? reviewPadding;

  const ReviewsListShimmer({super.key, this.itemCount = 3, this.reviewPadding});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return ReviewShimmer(padding: reviewPadding);
      },
    );
  }
}
