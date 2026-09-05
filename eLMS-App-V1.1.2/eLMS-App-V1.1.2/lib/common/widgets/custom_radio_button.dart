import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class CustomRadioButton extends StatefulWidget {
  final bool isSelected;
  final bool freeze;
  const CustomRadioButton({
    super.key,
    this.isSelected = false,
    this.freeze = false,
  });

  @override
  State<CustomRadioButton> createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioButton> {
  late bool isSelected = widget.isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.freeze) {
          return;
        }
        isSelected = !isSelected;
        setState(() {});
      },
      child: CustomCard(
        borderRadius: 100,
        borderColor: context.color.onSurface,
        color: isSelected ? context.color.primary : null,
        padding: const .all(4),
        child: isSelected
            ? Center(
                child: CustomImage(
                  AppIcons.check,
                  width: 17,
                  height: 17,
                  color: context.color.onPrimary,
                ),
              )
            : const SizedBox(width: 17, height: 17),
      ),
    );
  }
}
