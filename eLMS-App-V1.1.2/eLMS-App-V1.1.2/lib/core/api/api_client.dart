import 'dart:io';
import 'package:dio/dio.dart';
import 'package:elms/core/api/interceptors/header_interceptor.dart';
import 'package:elms/core/api/interceptors/error_handler_interceptor.dart';
import 'package:elms/core/api/interceptors/multipart_log_interceptor.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/debug/production_devtools/api_logger/api_log_interceptor.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/utils/local_storage.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:elms/utils/curl_logger_interceptor.dart';

export 'api_lists.dart';
export 'package:elms/core/debug/test_error_config.dart';

class Api {
  Api._();

  static final Dio _dio = _createDio();
  static final Dio _downloadDio = _createDownloadDio();

  static Dio _createDio() {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.addAll(<Interceptor>[
      if (AppConstant.kEnabledConsoleAPILogging)
        MultipartLogInterceptor(), // Log requests including FormData
      ApiLogInterceptor(), // Log API calls for production devtools
      CurlLoggerInterceptor(),
      HeaderInterceptor(),
      ErrorHandlerInterceptor(),
    ]);

    return dio;
  }

  /// Creates a separate Dio instance for file downloads
  /// Uses only HeaderInterceptor, skips ErrorHandlerInterceptor
  /// since downloads don't return JSON responses
  static Dio _createDownloadDio() {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );

    // Only add header interceptor for authentication
    // Skip error handler since binary responses don't follow JSON structure
    dio.interceptors.add(HeaderInterceptor());

    return dio;
  }

  static Future<Map<String, dynamic>> post(
    String api, {
    required Map<String, dynamic> data,
  }) async {
    return await rawApiRequest(api, method: 'POST', data: data);
  }

  static Future<Map<String, dynamic>> postMultipart(
    String api, {
    required Map<String, dynamic> data,
    required List<File> files,
    required String fileKey,
    bool isFilesArray = true,
  }) async {
    // Prepare map for FormData
    final Map<String, dynamic> formDataMap = {};

    // Add normal fields
    data.forEach((key, value) {
      if (value != null) {
        formDataMap[key] = value;
      }
    });

    // Prepare files list
    final List<MultipartFile> multipartFiles = [];
    for (var i = 0; i < files.length; i++) {
      final File file = files[i];
      if (await file.exists()) {
        final String fileName = file.path.split(Platform.pathSeparator).last;
        multipartFiles.add(
          await MultipartFile.fromFile(file.path, filename: fileName),
        );
      }
    }

    // Create FormData from map fields
    final formData = FormData.fromMap(formDataMap);

    // Add files manually with proper key format
    // Use 'key[]' for array format expected by PHP/Laravel backends if isFilesArray is true
    final String actualKey = isFilesArray ? '$fileKey[]' : fileKey;
    for (final file in multipartFiles) {
      formData.files.add(MapEntry(actualKey, file));
    }

    return await rawApiRequest(api, method: 'POST', data: formData);
  }

  static Future<Map<String, dynamic>> putMultipart(
    String api, {
    required Map<String, dynamic> data,
    required List<File> files,
    required String fileKey,
    bool isFilesArray = true,
  }) async {
    // Prepare map for FormData
    final Map<String, dynamic> formDataMap = {};

    // Add normal fields
    data.forEach((key, value) {
      if (value != null) {
        formDataMap[key] = value;
      }
    });

    // Prepare files list
    final List<MultipartFile> multipartFiles = [];
    for (final file in files) {
      if (await file.exists()) {
        final String fileName = file.path.split(Platform.pathSeparator).last;
        multipartFiles.add(
          await MultipartFile.fromFile(file.path, filename: fileName),
        );
      }
    }

    // Create FormData from map fields
    final formData = FormData.fromMap(formDataMap);

    // Add files manually with proper key format
    // Use 'key[]' for array format expected by PHP/Laravel backends if isFilesArray is true
    if (multipartFiles.isNotEmpty) {
      final String actualKey = isFilesArray ? '$fileKey[]' : fileKey;
      for (final file in multipartFiles) {
        formData.files.add(MapEntry(actualKey, file));
      }
    }

    return await rawApiRequest(api, method: 'PUT', data: formData);
  }

  static Future<Map<String, dynamic>> get(
    String api, {
    Map<String, dynamic>? data,
  }) async {
    return await rawApiRequest(api, method: 'GET', queryParameters: data);
  }

  static Future<Map> put(String api, {Map<String, dynamic>? data}) async {
    return await rawApiRequest(api, method: 'PUT', data: data);
  }

  static Future<Map> patch(String api, {Map<String, dynamic>? data}) async {
    return await rawApiRequest(api, method: 'PATCH', data: data);
  }

  static Future<Map> delete(
    String api, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await rawApiRequest(
      api,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
    );
  }

  /// Download a PDF file to local storage
  ///
  /// [api] - The API endpoint
  /// [savePath] - The local path where the PDF should be saved
  /// [data] - POST data to send with the request
  static Future<String> downloadPdf(
    String api, {
    required String savePath,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Use separate download Dio instance to avoid JSON response validation
      final Response<dynamic> response = await _downloadDio.download(
        api,
        savePath,
        data: data,
        options: Options(
          method: 'POST',
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) {
            // Accept successful responses (200-299)
            if (status != null && status >= 200 && status < 300) {
              return true;
            }
            return false;
          },
        ),
      );

      // Verify download was successful
      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw AppException(message: AppLabels.pdfDownloadFailed.tr);
      }

      return savePath;
    } catch (e) {
      // If it's a DioException, extract the CustomException from error property
      if (e is DioException && e.error is CustomException) {
        throw e.error as CustomException;
      }
      // If it's already a CustomException, rethrow
      if (e is CustomException) {
        rethrow;
      }
      // Handle DioException with response (server error)
      if (e is DioException && e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode == 401) {
          throw UnAuthorizedException();
        }
        throw AppException(message: AppLabels.pdfDownloadFailed.tr);
      }
      // Handle network errors
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          throw NoInternetException();
        }
      }
      // Otherwise, wrap with PDF-specific error message
      throw AppException(message: AppLabels.pdfDownloadFailed.tr);
    }
  }

  static Future<dynamic> normalDioRequest(
    String api, {
    required String method,
    required Map<String, dynamic> data,
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final Response response = await _dio.request(
        api,
        queryParameters: queryParameters,
        data: data,
        options: Options(method: method),
      );

      // Interceptor handles error responses, return data if successful
      return response.data;
    } catch (e) {
      // If it's a DioException, extract the CustomException from error property
      if (e is DioException && e.error is CustomException) {
        throw e.error as CustomException;
      }
      // If it's already a CustomException, rethrow
      if (e is CustomException) {
        rethrow;
      }
      // Otherwise wrap in AppException
      throw AppException(message: e.toString());
    }
  }

  ////This is specific for project structured apis
  static Future<Map<String, dynamic>> rawApiRequest(
    String api, {
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      // Use different request methods for FormData vs regular data
      final Response response;

      if (data is FormData) {
        // For FormData, use post/put directly
        if (method == 'POST') {
          response = await _dio.post<dynamic>(
            api,
            data: data,
            options: Options(
              headers: {'Authorization': 'Bearer ${LocalStorage.token}'},
              contentType: 'multipart/form-data',
            ),
          );
        } else if (method == 'PUT') {
          response = await _dio.put(
            api,
            data: data,
            queryParameters: queryParameters,
          );
        } else {
          throw ApiException(
            message: 'Unsupported method for FormData: $method',
          );
        }
      } else {
        // For regular data, use request with Options
        response = await _dio.request(
          api,
          queryParameters: queryParameters,
          data: data,
          options: Options(
            method: method,
            followRedirects: true,
            validateStatus: (status) => status != null && status < 500,
          ),
        );
      }

      // Interceptor handles validation, just return the data
      return Map.from(response.data);
    } catch (e) {
      // If it's a DioException, extract the CustomException from error property
      if (e is DioException && e.error is CustomException) {
        throw e.error as CustomException;
      }
      // If it's already a CustomException, rethrow
      if (e is CustomException) {
        rethrow;
      }
      // Otherwise wrap in AppException
      throw AppException(message: e.toString());
    }
  }
}
