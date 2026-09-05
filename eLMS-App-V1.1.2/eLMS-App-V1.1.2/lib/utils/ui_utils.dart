import 'dart:io';

import 'package:elms/common/widgets/custom_bottom_sheet.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UiUtils {
  UiUtils._();

  /// Converts any error to a user-friendly message.
  /// In release mode, non-[CustomException] errors return a generic message.
  static String friendlyErrorMessage(Object error) {
    if (error is String) return error;
    if (error is CustomException) return error.toString();
    if (kDebugMode) return error.toString();
    return AppLabels.somethingWentWrong.tr;
  }

  ///
  static WidgetBounds? getWidgetBounds(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    return WidgetBounds(
      offset: renderBox.localToGlobal(Offset.zero),
      size: renderBox.size,
    );
  }

  static void showSnackBar(String text, {bool isError = false, int? duration, TextButton? mainButton}) {
    int countedDuration = 0;
    if (duration == null) {
      const double wordsPerSecond = 4.0;
      final int wordCount = text.split(' ').length;
      countedDuration = (wordCount / wordsPerSecond).ceil();
    }

    // Defer to post-frame to avoid GetX snackbar _animation
    // LateInitializationError when called during a build phase.
    void showIt() {
      Get.showSnackbar(
        GetSnackBar(
          message: text,
          mainButton: mainButton,
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: Duration(seconds: duration ?? countedDuration.clamp(2, 10)),
          animationDuration: const Duration(milliseconds: 500),
          snackPosition: SnackPosition.TOP,
          snackStyle: SnackStyle.GROUNDED,
        ),
      );
    }

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showIt());
    } else {
      showIt();
    }
  }

  ///

  ///
  static Future showDialog(
    BuildContext context, {
    required Widget child,
    int? millisecondTransitionDuration,
    bool? dismissible,
  }) async {
    //we dont active dialog if the dialog is active already
    return await showGeneralDialog(
      context: context,
      barrierDismissible: dismissible ?? true,
      barrierLabel: 'dialog-barrier',

      barrierColor: context.color.textSecondary,
      transitionDuration: Duration(
        milliseconds: millisecondTransitionDuration ?? 200,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(scale: animation, child: child);
      },
      pageBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return child;
          },
    );
  }

  ///
  static Future<T?> showCustomBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool enableDrag = true,
    bool isDismissible = true,
  }) async {
    return showModalBottomSheet<T>(
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: context.color.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      context: context,
      builder: (context) {
        //using backdropFilter to blur the background screen
        //while bottomSheet is open
        return CustomBottomSheet(child: child);
      },
    );
  }

  static void showImagePickerSheet(Function(File image) onSelected) async {
    Expanded option(String name, IconData icon, ImageSource source) {
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final XFile? xFile = await ImagePicker().pickImage(source: source);
            if (xFile != null) {
              onSelected(File(xFile.path));
            }
            Get.back();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon), Text(name)],
          ),
        ),
      );
    }

    await showCustomBottomSheet(
      Get.context!,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            option('Camera', Icons.camera_alt_outlined, ImageSource.camera),
            option('Gallery', Icons.perm_media_outlined, ImageSource.gallery),
          ],
        ),
      ),
    );
  }

  ///
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
