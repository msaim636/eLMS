import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class DiscussionSubtopicsList extends StatelessWidget {
  final List<String> subtopics;
  final bool isHorizontal;
  final Function(String)? onSubtopicTap;

  const DiscussionSubtopicsList({
    super.key,
    required this.subtopics,
    this.isHorizontal = false,
    this.onSubtopicTap,
  });

  @override
  Widget build(BuildContext context) {
    if (subtopics.isEmpty) return const SizedBox.shrink();
    if (isHorizontal) {
      return SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: .horizontal,
          itemCount: subtopics.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return _buildSubtopicChip(context, subtopics[index]);
          },
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: subtopics
          .map((subtopic) => _buildSubtopicChip(context, subtopic))
          .toList(),
    );
  }

  Widget _buildSubtopicChip(BuildContext context, String subtopic) {
    return GestureDetector(
      onTap: () => onSubtopicTap?.call(subtopic),
      child: Container(
        padding: const .symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: context.color.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.color.outline, width: 0.7),
        ),
        child: CustomText(
          subtopic,
          style: TextStyle(fontSize: 12, color: context.color.onSurface),
        ),
      ),
    );
  }
}
