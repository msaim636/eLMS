import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Utility class to check if user is logged in as guest and prompt login when needed
class GuestChecker {
  static final ValueNotifier<bool?> _isGuest = ValueNotifier(
    LocalStorage.token == null,
  );

  /// Update guest status
  static void set(String from, {required bool isGuest}) {
    _isGuest.value = isGuest;
  }

  /// Check if user is guest and execute callback if not guest, otherwise show login prompt
  static void check({required Function() onNotGuest}) {
    if (_isGuest.value == true) {
      _showLoginBottomSheet(Get.context!);
    } else {
      onNotGuest.call();
    }
  }

  /// Get current guest status
  static bool get value {
    return _isGuest.value ?? false;
  }

  /// Listen to guest status changes
  static ValueNotifier<bool?> listen() {
    return _isGuest;
  }

  /// Widget builder that updates UI based on guest status
  static Widget updateUI({required Function(bool? isGuest) onChangeStatus}) {
    return ValueListenableBuilder<bool?>(
      valueListenable: _isGuest,
      builder: (context, value, child) {
        return onChangeStatus.call(value);
      },
    );
  }

  /// Show bottom sheet prompting user to login
  static void _showLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.color.surface,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(10),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 30,
            right: 30,
            top: 30,
            bottom: 30 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              CustomText(
                AppLabels.loginIsRequired.tr,
                style: TextStyle(
                  fontSize: context.font.medium,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              CustomText(
                AppLabels.tapOnLogin.tr,
                style: TextStyle(fontSize: context.font.small),
                fontSize: 14,
                color: context.color.textSecondary,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  elevation: 0,
                  color: context.color.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const .symmetric(vertical: 12),
                  onPressed: () {
                    Get.back();
                    Get.toNamed(
                      AppRoutes.loginScreen,
                      arguments: {'popToCurrent': true},
                    );
                  },
                  child: CustomText(
                    AppLabels.loginNow.tr,
                    style: TextStyle(
                      fontSize: context.font.small,
                      fontWeight: FontWeight.w500,
                    ),
                    color: context.color.onPrimary,
                    fontWeight: .w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
