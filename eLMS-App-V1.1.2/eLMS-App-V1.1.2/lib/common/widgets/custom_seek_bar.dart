import 'package:elms/common/enums.dart';
import 'package:elms/utils/extensions/color_extension.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class CustomSeekBar extends StatelessWidget {
  final double thickness; // width for vertical, height for horizontal
  final double seekBarProgress; // how much is filled
  final double fullLength; // total length of bar
  final List<Color>? colors;
  final SeekBarOrientation orientation;

  const CustomSeekBar({
    super.key,
    required this.thickness,
    required this.seekBarProgress,
    required this.fullLength,
    this.colors,
    this.orientation = SeekBarOrientation.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final isHorizontal = orientation == SeekBarOrientation.horizontal;

    return SizedBox(
      width: isHorizontal ? fullLength : thickness,
      height: isHorizontal ? thickness : fullLength,
      child: Stack(
        clipBehavior: .antiAlias,
        children: [
          Container(
            width: isHorizontal ? fullLength : thickness,
            height: isHorizontal ? thickness : fullLength,
            clipBehavior: .antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: isHorizontal ? .centerLeft : .topCenter,
                end: isHorizontal ? .centerRight : .bottomCenter,
                colors:
                    colors ??
                    [context.color.primary, context.color.primary.darken(1)],
              ),
            ),
          ),
          Align(
            alignment: isHorizontal ? .centerRight : .bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              width: isHorizontal ? seekBarProgress : thickness,
              height: isHorizontal ? thickness : seekBarProgress,
              clipBehavior: .antiAlias,
              decoration: BoxDecoration(
                color: context.color.primary.brighten(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
