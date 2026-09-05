import 'dart:async';
import 'dart:io';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/core/error_management/firebase_exceptions.dart';
import 'package:elms/core/login/login.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum CredentialLoginType { phone, email }

class EmailSignupParameters extends LoginParameters {
  final String? password;
  final String? email;

  EmailSignupParameters({required this.password, required this.email});
  @override
  Map<String, dynamic> toMap() {
    return {ApiParams.platformType: Platform.operatingSystem}.removeEmptyKeys();
  }
}

class EmailLoginParameters extends LoginParameters {
  final String email;
  final String password;

  EmailLoginParameters({required this.email, required this.password});
  @override
  Map<String, dynamic> toMap() {
    return {};
  }
}

class EmailSignupResult {
  final String firebaseToken;
  final UserCredential credentials;

  EmailSignupResult(this.firebaseToken, this.credentials);
}

class EmailLoginResult {
  final String? firebaseToken;

  EmailLoginResult(this.firebaseToken);
}

class EmailLogin extends Login<EmailLoginResult> {
  @override
  void init() {
    // Nothing to initialize
  }

  @override
  Future<LoginResponse<EmailLoginResult>?> login() async {
    try {
      final EmailLoginParameters params = parameters as EmailLoginParameters;
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: params.email,
            password: params.password,
          );

      // In demo mode, skip email verification for the demo account so the
      // app can be showcased without a verified inbox.
      final bool skipVerification =
          AppConstant.kIsDemoMode && params.email == AppConstant.kDemoEmail;

      if (!skipVerification && userCredential.user?.emailVerified == false) {
        // Keep user signed in so we can resend verification email
        // The cubit will handle signing out after resending
        throw EmailNotVerifiedException(email: params.email);
      }

      final String? firebaseToken = await userCredential.user?.getIdToken();
      return LoginResponse(EmailLoginResult(firebaseToken));
    } on EmailNotVerifiedException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.fromCode(e.code);
    }
  }
}

class EmailSignup extends Login<EmailSignupResult> {
  @override
  FutureOr<void> init() {}

  @override
  Future<LoginResponse<EmailSignupResult?>?> login() async {
    try {
      final EmailSignupParameters? params =
          parameters as EmailSignupParameters?;

      if (params == null) {
        throw Exception('Set Email Signup Parameters.');
      }
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: params.email!,
            password: params.password!,
          );

      await userCredential.user?.sendEmailVerification();

      final String? firebaseToken = await userCredential.user?.getIdToken();
      if (firebaseToken == null) {
        throw AppException(message: 'Firebase token is null', toast: false);
      }
      return LoginResponse(EmailSignupResult(firebaseToken, userCredential));
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.fromCode(e.code);
    }
  }
}
