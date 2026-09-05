import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/core/error_management/firebase_exceptions.dart';
import 'package:elms/core/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleLoginParameters extends LoginParameters {
  @override
  Map<String, dynamic> toMap() {
    return {};
  }
}

class AppleLogin extends SocialLogin<UserCredential> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  String get provider => 'apple';

  @override
  void init() {
    // No initialization needed
  }

  @override
  Future<LoginResponse<UserCredential>> login() async {
    try {
      final rawNonce = generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      if (appleCredential.identityToken == null) {
        throw Exception('Apple Sign In failed - no identity token received');
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );

      final UserCredential authResult = await _auth.signInWithCredential(
        oauthCredential,
      );
      return LoginResponse(authResult);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw CancelledException();
      }
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.fromCode(e.code);
    }
  }
}
