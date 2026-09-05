import 'package:elms/common/cubits/theme_cubit.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ThemeBottomSheet extends StatelessWidget {
  const ThemeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final bool isDark = state is DarkTheme;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              CustomText(
                AppLabels.theme.tr,
                style: TextStyle(
                  fontSize: context.font.medium,
                  fontWeight: .w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                spacing: 12,
                children: [
                  _ThemeOption(
                    label: AppLabels.lightMode.tr,
                    icon: AppIcons.theme,
                    isSelected: !isDark,
                    onTap: () {
                      context.read<ThemeCubit>().changeTheme(LightTheme());
                      Navigator.pop(context);
                    },
                  ),
                  _ThemeOption(
                    label: AppLabels.dark.tr,
                    icon: AppIcons.theme,
                    isSelected: isDark,
                    onTap: () {
                      context.read<ThemeCubit>().changeTheme(DarkTheme());
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: CustomCard(
          border: isSelected ? 1.5 : 1,
          borderColor: isSelected
              ? context.color.primary
              : context.color.outline,
          color: isSelected
              ? context.color.primary.withValues(alpha: 0.08)
              : context.color.surface,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: .min,
            spacing: 10,
            children: [
              CustomImage(
                icon,
                width: 28,
                height: 28,
                color: isSelected
                    ? context.color.primary
                    : context.color.textSecondary,
              ),
              CustomText(
                label,
                style: TextStyle(
                  fontSize: context.font.small,
                  fontWeight: isSelected ? .w600 : .w400,
                  color: isSelected
                      ? context.color.primary
                      : context.color.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
