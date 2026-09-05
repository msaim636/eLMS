import 'package:flutter/material.dart';

///
WidgetBounds? getWidgetBounds(GlobalKey key) {
  final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null || !renderBox.hasSize) return null;
  return WidgetBounds(
    offset: renderBox.localToGlobal(Offset.zero),
    size: renderBox.size,
  );
}

class WidgetBounds {
  final Offset offset;
  final Size size;

  const WidgetBounds({required this.offset, required this.size});

  double get left => offset.dx;
  double get top => offset.dy;
  double get right => offset.dx + size.width;
  double get bottom => offset.dy + size.height;
  Offset get center =>
      Offset(offset.dx + size.width / 2, offset.dy + size.height / 2);

  @override
  String toString() => 'WidgetBounds(offset: $offset, size: $size)';
}
