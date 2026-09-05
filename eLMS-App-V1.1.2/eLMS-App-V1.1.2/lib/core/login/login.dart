import 'dart:async';

enum LoginStatus {
  initial,
  progress,
  verificationRequired,
  verificationInProgress,
  success,
  error,
}

/// Base class for all login parameter types
abstract class LoginParameters {
  Map<String, dynamic> toMap();
}

/// Generic result class for login operations
class LoginResult<T> {
  final T? data;
  final LoginStatus status;
  final String? error;

  const LoginResult.success(this.data)
    : status = LoginStatus.success,
      error = null;

  const LoginResult.verificationRequired()
    : data = null,
      status = LoginStatus.verificationRequired,
      error = null;

  const LoginResult.verificationInProgress()
    : data = null,
      status = LoginStatus.verificationInProgress,
      error = null;

  const LoginResult.error(this.error) : data = null, status = LoginStatus.error;

  const LoginResult.inProgress()
    : data = null,
      status = LoginStatus.progress,
      error = null;

  bool get isSuccess => status == LoginStatus.success;
  bool get needsVerification => status == LoginStatus.verificationRequired;
  bool get isError => status == LoginStatus.error;
  bool get isInProgress =>
      status == LoginStatus.progress ||
      status == LoginStatus.verificationInProgress;
}

/// Response wrapper for login operations
class LoginResponse<T> {
  final T response;
  LoginResponse(this.response);
}

/// Base class for all login implementations
abstract class Login<T> {
  LoginParameters? parameters;

  /// Whether this login method requires verification (like OTP)
  bool get requiresVerification => false;

  FutureOr<void> init();

  void setData(LoginParameters data) {
    parameters = data;
  }

  /// Execute the login operation
  Future<LoginResponse<T?>?> login();
}

/// Interface for social login providers
abstract class SocialLogin<T> extends Login<T> {
  String get provider;
}
