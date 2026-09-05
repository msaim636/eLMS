import 'dart:io';

import 'package:elms/core/notification/notification_manager.dart';
import 'package:elms/common/widgets/app_update_dialog.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/debug/debug_error_tester.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/localization/language_cubit.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/settings/cubit/app_settings_cubit.dart';
import 'package:elms/features/settings/cubit/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static Widget route() => const SplashScreen();

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Fetch app settings
    context.read<AppSettingsCubit>().fetchAppSettings();

    // Fetch language list
    context.read<LanguageCubit>().fetchLanguages();
    // Initialize debug button after first frame (if enabled)
    if (AppConstant.kEnableDebugErrorTester) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DebugErrorTester.showButton(context);
      });
    }
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      // Check if maintenance mode is enabled
      final settingsState = context.read<AppSettingsCubit>().state;
      if (settingsState is SettingsSuccess) {
        final maintenanceMode = settingsState.settings.maintainceMode;
        if (maintenanceMode == '1') {
          await Get.offAllNamed(AppRoutes.maintenanceModeScreen);
          await NotificationManager.handleInitialMessage();
          return;
        }

        // Check for app updates
        final bool needsUpdate = await _checkForUpdates(settingsState);
        // If force update is required the dialog is non-dismissible — just
        // wait; do NOT return here or the splash will freeze forever.
        if (needsUpdate && settingsState.settings.forceUpdate == '1') {
          return;
        }
      }

      if (!mounted) return;
      await context
          .read<AuthenticationCubit>()
          .waitAuthCheckProcessComplete
          .timeout(const Duration(seconds: 10), onTimeout: () {});
      if (!mounted) return;

      final AuthenticationState authState = context
          .read<AuthenticationCubit>()
          .state;

      if (authState is UnAuthenticated && authState.isFirstTime) {
        await Get.offAllNamed(AppRoutes.onBoardingScreen);
      } else if (authState is UnAuthenticated) {
        await Get.offAllNamed(AppRoutes.loginScreen);
      } else if (authState is Authenticated ||
          authState is AuthenticatedAsGuest) {
        await Get.offAllNamed(AppRoutes.mainActivity);
      } else {
        // Fallback for error states
        await Get.offAllNamed(AppRoutes.loginScreen);
      }

      // Handle any notification the app was cold-started from, now that the
      // navigator is ready and the correct screen has been pushed.
      await NotificationManager.handleInitialMessage();
    });
  }

  /// Check for app updates and show dialog if needed
  Future<bool> _checkForUpdates(SettingsSuccess settingsState) async {
    final settings = settingsState.settings;

    // Get current app version from package info
    final packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;

    // Get server version based on platform
    final String? serverVersion = Platform.isIOS
        ? settings.iosVersion
        : settings.androidVersion;

    // Check if update is needed
    final bool isForceUpdate = settings.forceUpdate == '1';

    if (!mounted) return false;

    final bool updateShown = await AppUpdateDialog.checkAndShowUpdateDialog(
      context: context,
      serverVersion: serverVersion,
      currentVersion: currentVersion,
      isForceUpdate: isForceUpdate,
      playstoreUrl: settings.playstoreUrl,
      appstoreUrl: settings.appstoreUrl,
    );

    return updateShown && isForceUpdate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primary,
      body: Center(
        child: Directionality(
          textDirection: .ltr,
          child: CustomImage(AppIcons.appLogo),
        ),
      ),
    );
  }
}
