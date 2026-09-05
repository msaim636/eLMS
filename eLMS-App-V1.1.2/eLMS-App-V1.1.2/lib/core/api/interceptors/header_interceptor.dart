import 'package:dio/dio.dart';
import 'package:elms/utils/local_storage.dart';

class HeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add common headers
    // Let Dio set appropriate Content-Type; override only when not multipart
    if (options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Language'] =
        LocalStorage.getLocale()?.languageCode;

    if (LocalStorage.token?.isNotEmpty ?? false) {
      options.headers['Authorization'] = 'Bearer ${LocalStorage.token}';
    }

    handler.next(options);
  }
}
