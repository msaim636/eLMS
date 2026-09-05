import 'dart:async';
import 'package:elms/utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomPopScope extends StatelessWidget {
  final Widget child;
  final bool preventOverlay;
  final FutureOr<bool> Function()? shouldPop;

  const CustomPopScope({
    super.key,
    required this.child,
    this.preventOverlay = false,
    this.shouldPop,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (preventOverlay && LoadingOverlay.isOverlayOpen) {
          return;
        }
        // Check if we should pop (e.g., user confirmation)
        final bool allowPop = await (shouldPop?.call() ?? Future.value(true));
        if (allowPop) {
          Get.back(result: result);
        }
      },
      child: child,
    );
  }
}
