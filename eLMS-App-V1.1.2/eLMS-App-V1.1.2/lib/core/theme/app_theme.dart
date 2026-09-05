import 'package:elms/core/constants/app_colors.dart';
import 'package:elms/utils/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class AppTheme {
  ThemeData theme;
  AppTheme(this.theme);
  bool isDarkMode = false;
  static const String fontFamily = 'Geist';

  factory AppTheme.light(BuildContext context) {
    return AppTheme(
      ThemeData(
        fontFamily: fontFamily,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        colorScheme: const ColorScheme.light().copyWith(
          primary: AppColors.primaryColor,
          surface: AppColors.secondaryColor,
          outline: AppColors.borderColor,
          error: AppColors.errorColor,
          onError: AppColors.secondaryColor,
        ),
        dividerTheme: const DividerThemeData(color: AppColors.borderColor),
      ),
    )..isDarkMode = false;
  }

  factory AppTheme.dark(BuildContext context) {
    return AppTheme(
      ThemeData(
        fontFamily: fontFamily,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.darkBackgroundColor,
        dividerTheme: const DividerThemeData(color: AppColors.darkBorderColor),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: AppColors.darkPrimaryColor,
          surface: AppColors.darkBackgroundColor.brighten(0.06),
          outline: AppColors.darkBorderColor,
          error: AppColors.darkErrorColor,
          onError: AppColors.secondaryColor,
        ),
      ),
    )..isDarkMode = true;
  }
}
