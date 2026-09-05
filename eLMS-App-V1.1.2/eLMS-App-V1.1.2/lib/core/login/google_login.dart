import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/core/error_management/firebase_exceptions.dart';
import 'package:elms/core/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

class GoogleLoginParameters extends LoginParameters {
  @override
  Map<String, dynamic> toMap() {
    return {};
  }
}

class GoogleLogin extends SocialLogin<UserCredential> {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final List<String> _scopes = ['profile', 'email'];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  String get provider => 'google';

  @override
  void init() {
    // No initialization needed
  }

  /// Sign out from Google Sign-In
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  @override
  Future<LoginResponse<UserCredential>> login() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      GoogleSignInClientAuthorization? auth;

      auth = await account.authorizationClient.authorizationForScopes(_scopes);

      auth ??= await account.authorizationClient.authorizeScopes(_scopes);

      final credentials = GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
        accessToken: auth.accessToken,
      );

      final userCredentials = await _auth.signInWithCredential(credentials);

      return LoginResponse(userCredentials);
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.fromCode(e.code);
    } on GoogleSignInException catch (exception) {
      if (exception.code == GoogleSignInExceptionCode.canceled) {
        throw CancelledException();
      }
      rethrow;
    } on PlatformException catch (e) {
      throw AppException(message: e.code.tr);
    } catch (e) {
      rethrow;
    }
  }
}
