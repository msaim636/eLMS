import 'dart:io';
import 'package:dio/dio.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/core/debug/test_error_config.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/utils/local_storage.dart';
import 'package:get/get.dart' hide Response;

/// Interceptor that handles all API errors and converts them to CustomExceptions
///
/// This interceptor:
/// - Detects network errors (no internet, timeouts)
/// - Handles HTTP status codes (401, 403, 500, etc.)
/// - Parses API-level errors from response body
/// - Throws appropriate CustomExceptions
/// - Supports test error simulation for development and testing
class ErrorHandlerInterceptor extends Interceptor {
  /// HTTP status codes
  static const int ok = 200;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int forceUpdate = 410;
  static const int validationError = 422;
  static const int serverError = 500;
  static const int serverNotAvailable = 503;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if test error mode is enabled
    if (TestErrorSimulator.isTestErrorEnabled) {
      final config = TestErrorSimulator.testErrorConfig!;

      // Apply delay if configured
      if (config.delayMs > 0) {
        await Future.delayed(Duration(milliseconds: config.delayMs));
      }

      // Throw the configured test error
      final exception = _createTestError(config);
      handler.reject(
        DioException(
          requestOptions: options,
          error: exception,
          type: _getDioExceptionType(config.errorType),
        ),
      );
      return;
    }

    // Continue with normal request
    handler.next(options);
  }

  /// Creates a CustomException based on test error configuration
  CustomException _createTestError(TestErrorConfig config) {
    switch (config.errorType) {
      case TestErrorType.noInternet:
        return NoInternetException();

      case TestErrorType.unauthorized:
        _handleUnauthorized();
        return UnAuthorizedException();

      case TestErrorType.forbidden:
        return ApiException(
          message: config.customMessage ?? 'Forbidden: Access denied',
        );

      case TestErrorType.serverError:
        return ApiException(
          message: config.customMessage ?? AppLabels.genericServerError.tr,
        );

      case TestErrorType.serverUnavailable:
        return ServerUnavailableException();

      case TestErrorType.validationError:
        return ValidationError(
          message: config.customMessage ?? 'Validation failed',
        );

      case TestErrorType.badRequest:
        return ApiException(message: config.customMessage ?? 'Bad request');

      case TestErrorType.forceUpdate:
        return ForceUpdateRequestException();

      case TestErrorType.timeout:
        return NoInternetException();

      case TestErrorType.badResponse:
        return BadResponseFormateException();

      case TestErrorType.apiError:
        return ApiException(
          message: config.customMessage ?? AppLabels.unknownError.tr,
        );
    }
  }

  /// Gets the appropriate DioExceptionType for test errors
  DioExceptionType _getDioExceptionType(TestErrorType errorType) {
    switch (errorType) {
      case TestErrorType.noInternet:
      case TestErrorType.timeout:
        return DioExceptionType.connectionTimeout;

      case TestErrorType.unauthorized:
      case TestErrorType.forbidden:
      case TestErrorType.serverError:
      case TestErrorType.serverUnavailable:
      case TestErrorType.validationError:
      case TestErrorType.badRequest:
      case TestErrorType.forceUpdate:
        return DioExceptionType.badResponse;

      case TestErrorType.badResponse:
      case TestErrorType.apiError:
        return DioExceptionType.badResponse;
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Convert DioException to CustomException
    final exception = _handleDioError(err);

    // Reject with the custom exception
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: exception,
        type: err.type,
      ),
    );
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      // Validate response structure
      _validateResponse(response);

      // Check for API-level errors in response body (skip for byte responses)
      if (response.requestOptions.responseType != ResponseType.bytes &&
          response.data is Map) {
        final data = response.data as Map;
        if (data[ApiParams.error] == true) {
          throw ApiException(
            message: data[ApiParams.message] ?? AppLabels.unknownError.tr,
            code: response.statusCode?.toString(),
          );
        }
      }

      handler.next(response);
    } catch (e) {
      // Convert to DioException and let onError handle it
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: e is CustomException ? e : AppException(message: e.toString()),
          type: DioExceptionType.badResponse,
        ),
      );
    }
  }

  /// Validates response structure and content
  void _validateResponse(Response response) {
    // Skip validation for byte responses (downloads)
    // When downloading, response.data might be null as data is written to file
    if (response.requestOptions.responseType == ResponseType.bytes) {
      return;
    }

    // Handle null responses
    if (response.data == null) {
      throw ApiException(message: AppLabels.nullServerResponse.tr);
    }

    // Validate response format - must be a Map for JSON APIs
    if (response.data is! Map) {
      throw BadResponseFormateException();
    }
  }

  /// Converts DioException to appropriate CustomException
  CustomException _handleDioError(DioException error) {
    // If error already contains a CustomException, rethrow it
    if (error.error is CustomException) {
      return error.error as CustomException;
    }

    // Handle SocketException explicitly (no internet)
    if (error.error is SocketException) {
      return NoInternetException();
    }

    // Handle network-level errors (timeouts, connection errors)
    if (_isNetworkError(error)) {
      return NoInternetException();
    }

    // Handle errors with response (HTTP status codes)
    if (error.response != null) {
      return _handleResponseError(error);
    }

    // Handle errors without response (connection failed, etc.)
    return AppException(
      message: error.message ?? AppLabels.connectionFailed.tr,
    );
  }

  /// Checks if the error is a network-related error
  bool _isNetworkError(DioException error) {
    // Check for connection timeout, send timeout, receive timeout
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // Check for connection error
    if (error.type == DioExceptionType.connectionError) {
      return true;
    }

    return false;
  }

  /// Handles errors that have a response (HTTP status codes)
  CustomException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Handle specific HTTP status codes
    switch (statusCode) {
      case unauthorized:
        _handleUnauthorized();
        return UnAuthorizedException();

      case forbidden:
        return _extractApiException(responseData);

      case forceUpdate:
        return ForceUpdateRequestException();

      case validationError:
        return _handleValidationError(responseData);

      case serverError:
        return _handleServerError(responseData);

      case serverNotAvailable:
        return ServerUnavailableException();

      case badRequest:
        return _extractApiException(responseData);

      default:
        return _extractApiException(responseData);
    }
  }

  /// Handles unauthorized errors by logging out and navigating to login
  void _handleUnauthorized() {
    // Clear authentication state
    LocalStorage.setUserNotAuthenticated();
    LocalStorage.clearToken();

    // Navigate to login screen and clear navigation stack
    Get.offAllNamed(AppRoutes.loginScreen);
  }

  /// Handles validation errors (422)
  CustomException _handleValidationError(dynamic responseData) {
    if (responseData is Map && responseData.containsKey('message')) {
      return ValidationError(message: responseData['message']);
    }
    return ValidationError();
  }

  /// Handles server errors (500)
  CustomException _handleServerError(dynamic responseData) {
    if (responseData is Map) {
      if (responseData.containsKey('error') &&
          responseData.containsKey('message')) {
        return ApiException(
          message: responseData['message'] ?? AppLabels.genericServerError.tr,
        );
      }

      // If response has a message, use it
      if (responseData.containsKey('message')) {
        return ApiException(message: responseData['message']);
      }
    }

    return ApiException(
      message: responseData?.toString() ?? AppLabels.genericServerError.tr,
    );
  }

  /// Extracts ApiException from response data
  CustomException _extractApiException(dynamic responseData) {
    if (responseData is Map) {
      final message =
          responseData['message'] ??
          responseData['error'] ??
          AppLabels.unknownError.tr;
      return ApiException(message: message);
    }

    return AppException(
      message: responseData?.toString() ?? AppLabels.unknownError.tr,
    );
  }
}
