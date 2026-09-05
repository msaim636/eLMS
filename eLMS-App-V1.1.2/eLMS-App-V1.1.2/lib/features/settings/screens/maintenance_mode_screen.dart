import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MaintenanceModeScreen extends StatelessWidget {
  const MaintenanceModeScreen({super.key});

  static Widget route() => const MaintenanceModeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const .all(24.0),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Icon(
                  Icons.construction_rounded,
                  size: 120,
                  color: context.color.primary,
                ),
                const SizedBox(height: 32),
                CustomText(
                  AppLabels.maintenanceModeTitle.tr,
                  style: TextStyle(fontSize: context.font.xxxLarge),
                  textAlign: .center,
                  fontWeight: .bold,
                  color: context.color.onSurface,
                ),
                const SizedBox(height: 16),
                CustomText(
                  AppLabels.maintenanceModeMessage.tr,
                  style: TextStyle(fontSize: context.font.medium),
                  textAlign: .center,
                  color: context.color.textSecondary,
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const .symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.color.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomText(
                    AppLabels.maintenanceModeThankYou.tr,
                    style: TextStyle(fontSize: context.font.small),
                    textAlign: .center,
                    color: context.color.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
