import 'dart:io';

import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dialog to show app update prompts (force or optional)
class AppUpdateDialog extends StatelessWidget {
  const AppUpdateDialog({
    super.key,
    required this.isForceUpdate,
    required this.currentVersion,
    required this.newVersion,
    required this.playstoreUrl,
    required this.appstoreUrl,
  });

  /// If true, user cannot dismiss the dialog
  final bool isForceUpdate;

  /// Current app version
  final String currentVersion;

  /// New version available
  final String newVersion;

  /// Play Store URL for Android
  final String? playstoreUrl;

  /// App Store URL for iOS
  final String? appstoreUrl;

  /// Show the update dialog
  static Future<void> show({
    required BuildContext context,
    required bool isForceUpdate,
    required String currentVersion,
    required String newVersion,
    required String? playstoreUrl,
    required String? appstoreUrl,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      barrierColor: Colors.black87,
      builder: (context) => PopScope(
        canPop: !isForceUpdate,
        child: AppUpdateDialog(
          isForceUpdate: isForceUpdate,
          currentVersion: currentVersion,
          newVersion: newVersion,
          playstoreUrl: playstoreUrl,
          appstoreUrl: appstoreUrl,
        ),
      ),
    );
  }

  /// Check if update is needed and show appropriate dialog
  static Future<bool> checkAndShowUpdateDialog({
    required BuildContext context,
    required String? serverVersion,
    required String currentVersion,
    required bool isForceUpdate,
    required String? playstoreUrl,
    required String? appstoreUrl,
  }) async {
    if (serverVersion == null || serverVersion.isEmpty) {
      return false;
    }

    final needsUpdate = _compareVersions(currentVersion, serverVersion) < 0;

    if (needsUpdate) {
      await show(
        context: context,
        isForceUpdate: isForceUpdate,
        currentVersion: currentVersion,
        newVersion: serverVersion,
        playstoreUrl: playstoreUrl,
        appstoreUrl: appstoreUrl,
      );
      return true;
    }

    return false;
  }

  /// Compare two version strings
  /// Returns: -1 if v1 < v2, 0 if equal, 1 if v1 > v2
  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength = parts1.length > parts2.length
        ? parts1.length
        : parts2.length;

    for (int i = 0; i < maxLength; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;

      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }

    return 0;
  }

  Future<void> _onUpdatePressed() async {
    final String? url = Platform.isIOS ? appstoreUrl : playstoreUrl;

    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.color.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(context),
            const SizedBox(height: 20),
            _buildTitle(context),
            const SizedBox(height: 12),
            _buildDescription(context),
            const SizedBox(height: 8),
            _buildVersionInfo(context),
            const SizedBox(height: 24),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: isForceUpdate
            ? context.color.error.withValues(alpha: 0.1)
            : context.color.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isForceUpdate ? Icons.system_update : Icons.update,
        size: 36,
        color: isForceUpdate ? context.color.error : context.color.primary,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final title = isForceUpdate
        ? AppLabels.forceUpdateTitle.tr
        : AppLabels.optionalUpdateTitle.tr;

    return CustomText(
      title,
      textAlign: TextAlign.center,
      style: Theme.of(
        context,
      ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final description = isForceUpdate
        ? AppLabels.forceUpdateDescription.tr
        : AppLabels.optionalUpdateDescription.tr;

    return CustomText(
      description,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: context.font.small,
        color: context.color.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.color.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildVersionColumn(
            context,
            label: AppLabels.currentVersionLabel.tr,
            version: currentVersion,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 1,
            height: 32,
            color: context.color.outline.withValues(alpha: 0.3),
          ),
          _buildVersionColumn(
            context,
            label: AppLabels.newVersionLabel.tr,
            version: newVersion,
            isNew: true,
          ),
        ],
      ),
    );
  }

  Widget _buildVersionColumn(
    BuildContext context, {
    required String label,
    required String version,
    bool isNew = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          label,
          style: TextStyle(
            fontSize: context.font.xxSmall,
            fontWeight: FontWeight.w500,
            color: context.color.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        CustomText(
          'v$version',
          style: TextStyle(
            fontSize: context.font.medium,
            fontWeight: FontWeight.bold,
            color: isNew ? context.color.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            title: AppLabels.updateNow.tr,
            onPressed: _onUpdatePressed,
            height: 48,
            radius: 8,
          ),
        ),
        if (!isForceUpdate) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLabels.maybeLater.tr,
                style: TextStyle(
                  fontSize: context.font.medium,
                  fontWeight: FontWeight.w500,
                  color: context.color.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
