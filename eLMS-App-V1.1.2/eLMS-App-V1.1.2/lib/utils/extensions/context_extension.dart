import 'package:flutter/material.dart';
import 'package:elms/core/theme/app_fonts.dart';

// Export AppColors so that ColorScheme extension methods (like textSecondary) are available
export 'package:elms/core/constants/app_colors.dart';

extension CustomContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  ColorScheme get color => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  AppFontSizes get font => AppFontSizes();
}
