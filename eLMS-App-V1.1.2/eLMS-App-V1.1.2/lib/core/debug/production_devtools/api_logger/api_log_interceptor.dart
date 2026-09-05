import 'package:dio/dio.dart';
import 'package:elms/core/debug/production_devtools/api_logger/api_logger_service.dart';

class ApiLogInterceptor extends Interceptor {
  final ApiLoggerService _loggerService = ApiLoggerService.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestId = _loggerService.generateRequestId();
    options.extra['logRequestId'] = requestId;

    // Sanitize headers - remove sensitive data
    final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
    if (sanitizedHeaders.containsKey('Authorization')) {
      final auth = sanitizedHeaders['Authorization'] as String?;
      if (auth != null && auth.length > 20) {
        sanitizedHeaders['Authorization'] = '${auth.substring(0, 20)}...';
      }
    }

    // Sanitize request body
    dynamic sanitizedBody;
    if (options.data is FormData) {
      sanitizedBody = '[FormData]';
    } else {
      sanitizedBody = options.data;
    }

    _loggerService.logRequest(
      requestId: requestId,
      endpoint: options.uri.toString(),
      method: options.method,
      headers: sanitizedHeaders,
      body: sanitizedBody,
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId = response.requestOptions.extra['logRequestId'] as String?;
    if (requestId != null) {
      _loggerService.logResponse(
        requestId: requestId,
        statusCode: response.statusCode ?? 0,
        body: response.data,
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = err.requestOptions.extra['logRequestId'] as String?;
    if (requestId != null) {
      _loggerService.logError(
        requestId: requestId,
        errorMessage: err.message ?? err.type.name,
        statusCode: err.response?.statusCode,
      );
    }
    handler.next(err);
  }
}
