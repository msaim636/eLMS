import 'package:elms/utils/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  ///Light mode colors
  static const Color primaryColor = Color(
    0xff5A5BB5,
  ); // This would be main primary theme color
  static const Color secondaryColor = Color(
    0xffffffff,
  ); //This would be card background color and fields background color
  static const Color backgroundColor = Color(0xffF2F5F7);
  static const Color borderColor = Color(0xffD8E0E6);
  static const Color errorColor = Color(0xffDB3D26);

  ///Dark mode colors
  static const Color darkPrimaryColor = Color.fromARGB(255, 114, 115, 211);
  static const Color darkSecondaryColor = Color.fromRGBO(120, 120, 120, 1);
  static const Color darkBackgroundColor = Color(0xff101010);
  static const Color darkBorderColor = Color.fromARGB(255, 52, 53, 54);
  static const Color darkErrorColor = Color(0xffDB3D26);

  ///Custom constant colors
  static const Color infoColor = Color(0xff0186D8);
  static const Color warningColor = Color(0xffE29512);
  static const Color darkColor = Color(0xff000000);
  static const Color successColor = Color(0xff34A853);
}

extension ThemeExtension on ColorScheme {
  Color get info => AppColors.infoColor;
  Color get warning => AppColors.warningColor;
  Color get success => AppColors.successColor;
  Color get darkColor => brightness == Brightness.dark
      ? AppColors.darkColor.getAdaptiveTextColor()
      : AppColors.darkColor;

  // Custom Typography Colors
  Color get textPrimary => onSurface;
  Color get textSecondary => onSurfaceVariant.withValues(alpha: 0.5);
}
