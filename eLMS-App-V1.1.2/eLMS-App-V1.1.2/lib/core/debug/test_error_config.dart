/// Test error types that can be simulated
enum TestErrorType {
  noInternet,
  unauthorized,
  forbidden,
  serverError,
  serverUnavailable,
  validationError,
  badRequest,
  forceUpdate,
  timeout,
  badResponse,
  apiError,
}

/// Configuration for simulating test errors in development/testing
///
/// This class allows you to simulate various API errors to test error handling
/// in your app without needing actual server errors or network issues.
///
/// Example usage:
/// ```dart
/// // Simulate no internet error
/// TestErrorSimulator.enableTestError(
///   TestErrorConfig(errorType: TestErrorType.noInternet, delayMs: 1000)
/// );
///
/// // Simulate 401 unauthorized
/// TestErrorSimulator.testUnauthorized();
///
/// // Simulate server error with custom message
/// TestErrorSimulator.testServerError(
///   message: 'Custom server error message',
///   delayMs: 2000
/// );
///
/// // Disable test errors
/// TestErrorSimulator.disableTestError();
/// ```
class TestErrorConfig {
  final TestErrorType errorType;
  final String? customMessage;
  final int delayMs;

  const TestErrorConfig({
    required this.errorType,
    this.customMessage,
    this.delayMs = 0,
  });
}

/// Static class to manage test error simulation
///
/// Use this class to enable/disable test errors during development and testing.
/// Test errors are simulated in the ErrorHandlerInterceptor before making
/// actual API calls.
class TestErrorSimulator {
  TestErrorSimulator._();

  /// Test error configuration (null when disabled)
  static TestErrorConfig? _testErrorConfig;

  // --- NEW: RTL SIMULATOR ---
  static bool isRtlSimulationEnabled = false;

  static void toggleRtlSimulation() {
    isRtlSimulationEnabled = !isRtlSimulationEnabled;
  }

  /// Enable test error mode
  ///
  /// Example usage:
  /// ```dart
  /// TestErrorSimulator.enableTestError(
  ///   TestErrorConfig(
  ///     errorType: TestErrorType.serverError,
  ///     customMessage: 'Custom error message',
  ///     delayMs: 2000
  ///   )
  /// );
  /// ```
  static void enableTestError(TestErrorConfig config) {
    _testErrorConfig = config;
  }

  /// Disable test error mode
  static void disableTestError() {
    _testErrorConfig = null;
  }

  /// Check if test error mode is enabled
  static bool get isTestErrorEnabled => _testErrorConfig != null;

  /// Get the current test error configuration
  static TestErrorConfig? get testErrorConfig => _testErrorConfig;

  // ========== Quick Helper Methods ==========

  /// Simulate no internet connection error
  ///
  /// Usage: `TestErrorSimulator.testNoInternet(delayMs: 1000);`
  static void testNoInternet({int delayMs = 0}) {
    enableTestError(
      TestErrorConfig(errorType: TestErrorType.noInternet, delayMs: delayMs),
    );
  }

  /// Simulate 401 unauthorized error (will trigger auto-logout)
  ///
  /// Usage: `TestErrorSimulator.testUnauthorized();`
  static void testUnauthorized({int delayMs = 0}) {
    enableTestError(
      TestErrorConfig(errorType: TestErrorType.unauthorized, delayMs: delayMs),
    );
  }

  /// Simulate 403 forbidden error (will trigger auto-logout)
  ///
  /// Usage: `TestErrorSimulator.testForbidden();`
  static void testForbidden({int delayMs = 0}) {
    enableTestError(
      TestErrorConfig(errorType: TestErrorType.forbidden, delayMs: delayMs),
    );
  }

  /// Simulate 500 server error
  ///
  /// Usage:
  /// ```dart
  /// TestErrorSimulator.testServerError(
  ///   message: 'Database connection failed',
  ///   delayMs: 2000
  /// );
  /// ```
  static void testServerError({String? message, int delayMs = 0}) {
    enableTestError(
      TestErrorConfig(
        errorType: TestErrorType.serverError,
        customMessage: message,
        delayMs: delayMs,
      ),
    );
  }

  /// Simulate 503 service unavailable error
  ///
  /// Usage: `TestErrorSimulator.testServerUnavailable();`
  static void testServerUnavailable({int delayMs = 0}) {
    enableTestError(
      TestErrorConfig(
        errorType: TestErrorType.serverUnavailable,
        delayMs: delayMs,
      ),
    );
  }

  /// Simulate 422 validation error
  ///
  /// Usage:
  /// ```dart
  /// TestErrorSimulator.testValidationError(
  ///   message: 'Email is required',
  ///   delayMs: 500
  /// );
  /// ```
  static void testValidationError({String? message, int delayMs = 0}) {
    enableTestError(
      TestErrorConfig(
        errorType: TestErrorType.validationError,
        customMessage: message,
        delayMs: delayMs,
      ),
    );
  }

  /// Simulate 400 bad request error
  ///
  /// Usage:
  /// ```dart
  /// TestErrorSimulator.testBadRequest(
  ///   message: 'Invalid request parameters'
  /// );
  /// ```
  static void testBadRequest({String? message, int delayMs = 0}) {
    enableTestError(
      TestErrorConfig(
        errorType: TestErrorType.badRequest,
        customMessage: message,
        delayMs: delayMs,
      ),
    );
  }

  /// Simulate 410 force update required error
  ///
  /// Usage: `TestErrorSimulator.testForceUpdate();`
  static void testForceUpdate({int delayMs = 0}) {
    enableTestError(
      TestErrorConfig(errorType: TestErrorType.forceUpdate, delayMs: delayMs),
    );
  }

  /// Simulate connection timeout error
  ///
  /// Usage: `TestErrorSimulator.testTimeout();`
  static void testTimeout({int delayMs = 0}) {
    enableTestError(
      TestErrorConfig(errorType: TestErrorType.timeout, delayMs: delayMs),
    );
  }

  /// Simulate bad response format error
  ///
  /// Usage: `TestErrorSimulator.testBadResponse();`
  static void testBadResponse({int delayMs = 0}) {
    enableTestError(
      TestErrorConfig(errorType: TestErrorType.badResponse, delayMs: delayMs),
    );
  }

  /// Simulate API-level error (error: true in response body)
  ///
  /// Usage:
  /// ```dart
  /// TestErrorSimulator.testApiError(
  ///   message: 'API operation failed'
  /// );
  /// ```
  static void testApiError({String? message, int delayMs = 0}) {
    enableTestError(
      TestErrorConfig(
        errorType: TestErrorType.apiError,
        customMessage: message,
        delayMs: delayMs,
      ),
    );
  }
}
