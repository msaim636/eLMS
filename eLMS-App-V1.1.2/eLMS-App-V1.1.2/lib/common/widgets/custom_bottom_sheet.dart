import 'dart:ui';

import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final Widget child;
  const CustomBottomSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
      child: Container(
        width: double.maxFinite,
        margin: .only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: .min,
          children: [
            const CustomBottomSheetDragHandlerContainer(),
            Flexible(child: child),
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
  }
}

class CustomBottomSheetDragHandlerContainer extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  const CustomBottomSheetDragHandlerContainer({
    super.key,
    this.padding = const .symmetric(horizontal: 16, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: CustomCard(
        color: context.color.textSecondary,
        borderRadius: 10,
        border: 0,
        width: 32,
        height: 5,
        child: const SizedBox(),
      ),
    );
  }
}
