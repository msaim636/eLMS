import 'package:flutter/material.dart';

extension ColorExt on Color {
  Color brighten(double value) {
    final double red = (r + value).clamp(0.0, 1.0);
    final double green = (g + value).clamp(0.0, 1.0);
    final double blue = (b + value).clamp(0.0, 1.0);

    return Color.fromARGB(
      255,
      (red * 255).toInt(),
      (green * 255).toInt(),
      (blue * 255).toInt(),
    );
  }

  Color darken(double value) {
    final double red = (r - value).clamp(0.0, 1.0);
    final double green = (g - value).clamp(0.0, 1.0);
    final double blue = (b - value).clamp(0.0, 1.0);

    return Color.fromARGB(
      255,
      (red * 255).toInt(),
      (green * 255).toInt(),
      (blue * 255).toInt(),
    );
  }

  Color getAdaptiveTextColor() {
    return computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
