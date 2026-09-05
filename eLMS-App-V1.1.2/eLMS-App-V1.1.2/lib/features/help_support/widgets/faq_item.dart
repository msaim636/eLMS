import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_expandable_tile.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class FaqItemShimmer extends StatelessWidget {
  const FaqItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderColor: context.color.outline,
      padding: const .all(10),
      child: const Column(
        crossAxisAlignment: .start,
        spacing: 8,
        children: [
          // Question shimmer
          CustomShimmer(height: 16, borderRadius: 4),
          CustomShimmer(height: 16, width: 200, borderRadius: 4),
          SizedBox(height: 4),
          // Answer shimmer (collapsed state)
          CustomShimmer(height: 12, width: 100, borderRadius: 4),
        ],
      ),
    );
  }
}

class FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool initialExpanded;

  const FaqItem({
    super.key,
    required this.question,
    required this.answer,
    this.initialExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomExpandableTile(
      isExpanded: initialExpanded,
      onToggle: () {},
      backgroundColor: context.color.surface,
      borderColor: context.color.outline,
      padding: const .all(10),
      title: question,
      content: Padding(
        padding: const .only(top: 8.0),
        child: CustomText(
          answer,
          style: TextStyle(fontSize: 12, color: context.color.onSurface),
        ),
      ),
    );
  }
}
