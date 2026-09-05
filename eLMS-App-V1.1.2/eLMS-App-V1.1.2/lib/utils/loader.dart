import 'dart:async';

import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingOverlay {
  static Completer _completer = Completer();
  static bool isOverlayOpen = false;
  static Completer get completer {
    if (_completer.isCompleted) {
      _completer = Completer();
      return _completer;
    } else {
      return _completer;
    }
  }

  static FutureOr<T> execute<T>(
    Future<T> Function() task, {
    bool disabled = false,
  }) async {
    try {
      if (disabled) {
        return await task();
      }

      return await Get.showOverlay(
        asyncFunction: () async {
          try {
            isOverlayOpen = true;
            final taskResult = await task();
            isOverlayOpen = false;
            return taskResult;
          } catch (e) {
            isOverlayOpen = false;
            if (e is CustomException) {
              rethrow;
            }
            throw ApiException(message: e.toString());
          }
        },
        loadingWidget: const Center(child: CircularProgressIndicator()),
        opacity: AppConstant.kLoaderBackgroundOpacity,
      );
    } catch (e) {
      isOverlayOpen = false;
      rethrow;
    }
  }

  static void show() {
    if (isOverlayOpen) return;
    Get.showOverlay(
      asyncFunction: () async {
        isOverlayOpen = true;
        await completer.future;
      },
      loadingWidget: const Center(child: CircularProgressIndicator()),
      opacity: AppConstant.kLoaderBackgroundOpacity,
    );
  }

  static void hide() {
    if (!isOverlayOpen) return; // Early return if no overlay is open
    isOverlayOpen = false;
    completer.complete();
  }
}
