// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:elms/core/constants/app_labels.dart';
import 'package:flutter/foundation.dart';
import 'package:get/utils.dart';

abstract class CustomException implements Exception {
  String? get code;
  final String? message;
  final bool toast;
  CustomException({this.message, this.toast = true});
  @override
  String toString() {
    return code ?? message ?? '$runtimeType: unhandled-exception';
  }
}

class UnAuthorizedException extends CustomException {
  @override
  String? get code => 'unauthorized_error';
  UnAuthorizedException({super.toast});
  @override
  String toString() {
    return code!.tr;
  }
}

class NoInternetException extends CustomException {
  @override
  String? get code => 'no_internet_connection';

  NoInternetException({super.toast});
  @override
  String toString() {
    return code!.tr;
  }
}

class AppException extends CustomException {
  @override
  String? get code => kDebugMode ? null : 'app_error';

  AppException({super.message, super.toast});

  factory AppException.from(Exception exception) {
    return AppException(
      message: kDebugMode
          ? exception.toString()
          : AppLabels.somethingWentWrong.tr,
      toast: false,
    );
  }
  @override
  String toString() {
    return message ?? AppLabels.somethingWentWrong.tr;
  }
}

////Server related exceptions
class ServerException extends CustomException {
  @override
  String? get code => kDebugMode ? null : 'server_error';
  ServerException({super.message, super.toast});
}

class ServerUnavailableException extends CustomException {
  @override
  String? get code => 'server_unavailable';
  ServerUnavailableException({super.message, super.toast});
  @override
  String toString() {
    return code!.tr;
  }
}

class ValidationError extends CustomException {
  @override
  late String? code;

  ValidationError({super.message, this.code});
}

class ApiException extends CustomException {
  @override
  late String? code;

  ApiException({this.code, super.message, super.toast});

  @override
  String toString() => message ?? '';
}

class BadResponseFormateException extends CustomException {
  @override
  String? get code => 'invalid_response_format';
  BadResponseFormateException({super.toast});
  @override
  String toString() {
    return code!.tr;
  }
}

class ForceUpdateRequestException extends CustomException {
  @override
  String? get code => 'force_update_required';
  ForceUpdateRequestException({super.toast});
  @override
  String toString() {
    return code!.tr;
  }
}

/// Exception thrown when user cancels an operation (e.g., Google login).
/// This exception should be handled silently without showing any error.
class CancelledException extends CustomException {
  @override
  String? get code => null;
  CancelledException() : super(toast: false);
  @override
  String toString() => '';
}

/// Exception thrown when user's email is not verified.
/// Carries the email so verification can be resent.
class EmailNotVerifiedException extends CustomException {
  final String email;
  @override
  String? get code => 'email_not_verified';
  EmailNotVerifiedException({required this.email}) : super(toast: false);
  @override
  String toString() => code!;
}
