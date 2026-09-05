import 'dart:ui';

import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/debug/production_devtools/error_logger/error_log_model.dart';
import 'package:elms/core/debug/production_devtools/error_logger/error_logger_service.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class ExceptionHandler {
  ///This will be responsible to show snackbar if the exception is a custom exception
  ///and log all errors to the error logger service
  static void registerErrorSnackbarService() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log to error logger service
      _logFlutterError(details);

      if (details.exception is CustomException) {
        final CustomException exception =
            (details.exception as CustomException);
        if (exception.toast) {
          UiUtils.showSnackBar(exception.message ?? '', isError: true);
        }
      }
      FlutterError.presentError(details);
    };

    // Handle errors from the platform
    PlatformDispatcher.instance.onError = (error, stack) {
      // Log to error logger service
      _logPlatformError(error, stack);

      if (error is CustomException) {
        final CustomException exception = error;
        if (exception.toast) {
          UiUtils.showSnackBar(exception.message ?? '', isError: true);
        }
      }
      return true;
    };
  }

  /// Log Flutter framework errors to error logger
  static void _logFlutterError(FlutterErrorDetails details) {
    ErrorSeverity severity = ErrorSeverity.error;
    final String source = details.library ?? 'Flutter';

    // Determine severity based on error type
    final exception = details.exception;
    if (exception is FlutterError) {
      final String message = exception.message;
      // Layout errors are usually warnings
      if (message.contains('RenderFlex') ||
          message.contains('overflow') ||
          message.contains('constraints')) {
        severity = ErrorSeverity.warning;
      }
    }

    // Don't log custom exceptions with toast as errors (they're handled UI)
    if (exception is CustomException && exception.toast) {
      severity = ErrorSeverity.info;
    }

    ErrorLoggerService.instance.logError(
      error: details.exception,
      stackTrace: details.stack,
      source: source,
      severity: severity,
    );
  }

  /// Log platform dispatcher errors to error logger
  static void _logPlatformError(Object error, StackTrace stack) {
    ErrorSeverity severity = ErrorSeverity.error;

    // Don't log custom exceptions with toast as errors
    if (error is CustomException && error.toast) {
      severity = ErrorSeverity.info;
    }

    ErrorLoggerService.instance.logError(
      error: error,
      stackTrace: stack,
      source: 'Platform',
      severity: severity,
    );
  }

  /// Manually log an error from anywhere in the app
  static void logError(
    Object error, {
    StackTrace? stackTrace,
    String? source,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    ErrorLoggerService.instance.logError(
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
      source: source,
      severity: severity,
    );
  }

  /// Log a warning message
  static void logWarning(String message, {String? source}) {
    ErrorLoggerService.instance.logWarning(message, source: source);
  }

  /// Log an info message
  static void logInfo(String message, {String? source}) {
    ErrorLoggerService.instance.logInfo(message, source: source);
  }

  static void overrideFlutterErrorWidget() {
    // Override default error widget
    ErrorWidget.builder = (FlutterErrorDetails details) {
      final message = UiUtils.friendlyErrorMessage(details.exception);
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomImage(AppIcons.errorIllustrator, height: 150, width: 150),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      );
    };
  }
}
