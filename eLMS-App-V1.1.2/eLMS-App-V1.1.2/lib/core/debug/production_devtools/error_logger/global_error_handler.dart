import 'dart:async';
import 'dart:isolate';

import 'package:elms/core/debug/production_devtools/error_logger/error_log_model.dart';
import 'package:elms/core/debug/production_devtools/error_logger/error_logger_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Global error handler that captures all uncaught errors in the app.
///
/// Usage in main.dart:
/// ```dart
/// void main() {
///   GlobalErrorHandler.init(() {
///     runApp(const MyApp());
///   });
/// }
/// ```
class GlobalErrorHandler {
  GlobalErrorHandler._();

  static bool _isInitialized = false;

  /// Initialize global error handling and run the app.
  /// This wraps the app in error catching zones.
  static void init(VoidCallback runApp) {
    if (_isInitialized) {
      runApp();
      return;
    }

    _isInitialized = true;

    // Capture Flutter framework errors
    FlutterError.onError = _handleFlutterError;

    // Capture async errors that escape the Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(
        error: error,
        stackTrace: stack,
        source: 'PlatformDispatcher',
        severity: ErrorSeverity.error,
      );
      return true; // Prevent the error from propagating
    };

    // Capture isolate errors
    Isolate.current.addErrorListener(
      RawReceivePort((pair) {
        final List<dynamic> errorAndStacktrace = pair as List<dynamic>;
        _logError(
          error: errorAndStacktrace.first,
          stackTrace: errorAndStacktrace.last != null
              ? StackTrace.fromString(errorAndStacktrace.last.toString())
              : null,
          source: 'Isolate',
          severity: ErrorSeverity.error,
        );
      }).sendPort,
    );

    // Run app in a guarded zone to catch any remaining errors
    runZonedGuarded(
      () {
        WidgetsFlutterBinding.ensureInitialized();
        ErrorLoggerService.instance.init();
        runApp();
      },
      (error, stackTrace) {
        _logError(
          error: error,
          stackTrace: stackTrace,
          source: 'Zone',
          severity: ErrorSeverity.error,
        );
      },
    );
  }

  /// Handle Flutter framework errors
  static void _handleFlutterError(FlutterErrorDetails details) {
    // Determine severity based on error type
    ErrorSeverity severity = ErrorSeverity.error;
    String source = 'Flutter';

    if (details.library != null) {
      source = details.library!;
    }

    // Check for specific error types
    final exception = details.exception;
    if (exception is FlutterError) {
      final message = exception.message;
      // Layout errors are usually warnings
      if (message.contains('RenderFlex') ||
          message.contains('overflow') ||
          message.contains('constraints')) {
        severity = ErrorSeverity.warning;
      }
    }

    _logError(
      error: details.exception,
      stackTrace: details.stack,
      source: source,
      severity: severity,
      context: details.context?.toString(),
    );

    // Also print to console in debug mode
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }

  /// Internal method to log errors
  static void _logError({
    required Object error,
    StackTrace? stackTrace,
    required String source,
    required ErrorSeverity severity,
    String? context,
  }) {
    final errorMessage = context != null
        ? '$error\nContext: $context'
        : error.toString();

    ErrorLoggerService.instance.logError(
      error: errorMessage,
      stackTrace: stackTrace,
      source: source,
      severity: severity,
    );
  }

  // ============ Manual Logging Methods ============

  /// Log an info message manually
  static void logInfo(String message, {String? source}) {
    ErrorLoggerService.instance.logInfo(message, source: source);
  }

  /// Log a warning manually
  static void logWarning(
    String message, {
    String? source,
    StackTrace? stackTrace,
  }) {
    ErrorLoggerService.instance.logWarning(
      message,
      source: source,
      stackTrace: stackTrace,
    );
  }

  /// Log an error manually
  static void logError(Object error, {StackTrace? stackTrace, String? source}) {
    ErrorLoggerService.instance.logError(
      error: error,
      stackTrace: stackTrace,
      source: source,
    );
  }

  /// Log a fatal error manually
  static void logFatal(Object error, {StackTrace? stackTrace, String? source}) {
    ErrorLoggerService.instance.logFatal(
      error,
      stackTrace: stackTrace,
      source: source,
    );
  }

  /// Log an exception with automatic stack trace capture
  static void logException(
    Object exception, {
    String? source,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    ErrorLoggerService.instance.logError(
      error: exception,
      stackTrace: StackTrace.current,
      source: source,
      severity: severity,
    );
  }

  /// Log from existing exception handler
  static void logFromExceptionHandler(
    Object error,
    StackTrace? stackTrace, {
    String? source,
  }) {
    ErrorLoggerService.instance.logError(
      error: error,
      stackTrace: stackTrace,
      source: source ?? 'ExceptionHandler',
    );
  }

  /// Wrap a function call and catch any errors
  static T? tryCatch<T>(T Function() function, {String? source, T? fallback}) {
    try {
      return function();
    } catch (e, stack) {
      logError(e, stackTrace: stack, source: source);
      return fallback;
    }
  }

  /// Wrap an async function call and catch any errors
  static Future<T?> tryCatchAsync<T>(
    Future<T> Function() function, {
    String? source,
    T? fallback,
  }) async {
    try {
      return await function();
    } catch (e, stack) {
      logError(e, stackTrace: stack, source: source);
      return fallback;
    }
  }
}
