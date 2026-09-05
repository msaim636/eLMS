import 'package:flutter/material.dart';

extension WidgetX on Widget {
  Widget get center => Center(child: this);
  Widget padding([EdgeInsets padding = const .all(8)]) =>
      Padding(padding: padding, child: this);
  Widget get visible => this;
  Widget get hidden => const SizedBox.shrink();
  Widget onTap(VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: this);
}
