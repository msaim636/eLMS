import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class QuizOption extends StatefulWidget {
  final int index;
  final String option;
  final bool isSelected;
  final Function(bool isSelected, int index) onSelectionChange;

  const QuizOption({
    super.key,
    required this.index,
    required this.option,
    this.isSelected = false,
    required this.onSelectionChange,
  });

  @override
  State<QuizOption> createState() => _QuizOptionState();
}

class _QuizOptionState extends State<QuizOption> {
  late bool isSelected;
  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(QuizOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      isSelected = widget.isSelected;
    }
  }

  String indexToLetter(int index) {
    String result = '';
    index++; // Make it 1-based

    while (index > 0) {
      index--; // Convert to 0-based for letter calculation
      result = String.fromCharCode(65 + (index % 26)) + result;
      index ~/= 26;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isSelected = !isSelected;
        widget.onSelectionChange.call(isSelected, widget.index);
        setState(() {});
      },
      child: CustomCard(
        padding: const .all(16),
        color: isSelected ? context.color.primary.withValues(alpha: 0.1) : null,
        borderColor: isSelected ? context.color.primary : null,
        child: Row(
          spacing: 16,
          children: [
            CustomCard(
              width: 32,
              height: 32,
              alignment: .center,
              color: isSelected ? context.color.primary : null,
              borderColor: isSelected ? null : context.color.darkColor,
              child: CustomText(
                indexToLetter(widget.index),
                style: TextStyle(
                  fontSize: context.font.small,
                  fontWeight: .w500,
                  color: isSelected ? context.color.onPrimary : null,
                ),
              ),
            ),
            Expanded(
              child: CustomText(
                widget.option,
                style: TextStyle(
                  fontSize: context.font.medium,
                  fontWeight: .w500,
                  color: isSelected ? context.color.primary : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
