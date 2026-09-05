import 'dart:async';
import 'dart:io';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/common/models/user_model.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/core/login/apple_login.dart';
import 'package:elms/core/login/google_login.dart';
import 'package:elms/core/login/guest_checker.dart';
import 'package:elms/core/login/login.dart';
import 'package:elms/core/login/login_as_guest.dart';
import 'package:elms/core/login/email_login.dart';
import 'package:elms/core/login/phone_password_login.dart';
import 'package:elms/core/error_management/firebase_exceptions.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elms/utils/local_storage.dart';
import 'package:get/get.dart';

int? forceResendingToken;

// Simple Authentication States
abstract class AuthenticationState {}

class AuthInitial extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final UserModel? user;

  Authenticated({this.user});
}

class VerificationCompleted extends AuthenticationState {
  final String firebaseToken;
  final PhoneNumber phoneNumber;

  VerificationCompleted(this.firebaseToken, this.phoneNumber);
}

class SignUpAsEmail extends Authenticated {}

/// State emitted after email signup when email verification is required
class EmailVerificationRequired extends AuthenticationState {
  final String email;

  EmailVerificationRequired({required this.email});
}

/// State emitted when login attempted with unverified email
class EmailNotVerified extends AuthenticationState {
  final String email;

  EmailNotVerified({required this.email});
}

class AuthenticatedAsGuest extends AuthenticationState {}

class UnAuthenticated extends AuthenticationState {
  final bool isFirstTime;
  UnAuthenticated({this.isFirstTime = false});
}

class AuthLoading extends AuthenticationState {}

class SocialAuthLoading extends AuthenticationState {}

class VerificationRequestProcessing extends AuthLoading {}

class VerificationProcessing extends AuthLoading {}

class AuthVerificationRequired extends AuthenticationState {
  final String verificationId;
  final PhoneNumber phoneNumber;

  AuthVerificationRequired({
    required this.verificationId,
    required this.phoneNumber,
  });
}

class AuthVerifyingOTP extends AuthenticationState {}

class AuthFailed<T> extends AuthenticationState {
  final T error;
  AuthFailed(this.error);
}

class AuthenticationInProgress<T extends Login> extends AuthenticationState {
  final Type method;
  AuthenticationInProgress({required this.method});

  AuthenticationInProgress copyWith({Type? method}) {
    return AuthenticationInProgress(method: method ?? this.method);
  }
}

class AuthenticationFailed<T> extends AuthenticationState {
  final T error;
  final bool isFirstTime;

  AuthenticationFailed(this.error, {this.isFirstTime = false});
}

///Email verification states parent of auth state
class SendEmailVerificationLinkState extends AuthenticationState {}

class SendEmailVerificationLinkInitial extends SendEmailVerificationLinkState {}

class SendEmailVerificationLinkInProgress
    extends SendEmailVerificationLinkState {}

class SendEmailVerificationLinkSuccess extends SendEmailVerificationLinkState {}

class SendEmailVerificationLinkFail extends AuthenticationFailed
    implements SendEmailVerificationLinkState {
  SendEmailVerificationLinkFail(super.error);
}

// Authentication Cubit with separate methods for each login type
class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AuthRepository _authRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Services
  final GoogleLogin _googleLogin = GoogleLogin();
  final AppleLogin _appleLogin = AppleLogin();
  final LoginAsGuest _guestLogin = LoginAsGuest();
  final EmailLogin _emailLogin = EmailLogin();
  final EmailSignup _emailSignup = EmailSignup();
  final PhonePasswordLogin _phonePasswordLogin = PhonePasswordLogin();
  final Completer _authCheckCompleter = Completer();
  AuthenticationCubit(this._authRepository) : super(AuthInitial()) {
    _initLoginServices();
    // _checkAuthStatus();
    _authCheckCompleter.complete(_checkAuthStatus());
  }

  Future<void> get waitAuthCheckProcessComplete {
    return _authCheckCompleter.future;
  }

  // Initialize login services
  void _initLoginServices() {
    _googleLogin.init();
    _appleLogin.init();
    _guestLogin.init();
    _emailLogin.init();
    _emailLogin.init();
  }

  // Check initial authentication status
  Future<void> _checkAuthStatus() async {
    final authState = LocalStorage.getAuthState();

    switch (authState) {
      case AuthState.firstTime:
        emit(UnAuthenticated(isFirstTime: true));
        break;
      case AuthState.unAuthenticated:
        emit(UnAuthenticated());
        break;
      case AuthState.guest:
        emit(AuthenticatedAsGuest());
        break;
      case AuthState.authenticated:
        try {
          ///API here to get fresh user data on app load
          final UserModel user = await _authRepository.getUserDetails();
          GuestChecker.set('_checkAuthStatus', isGuest: false);
          emit(Authenticated(user: user));
        } catch (e) {
          // If token is invalid or API fails, logout user
          await LocalStorage.setUserNotAuthenticated();
          await LocalStorage.clearToken();
          emit(UnAuthenticated());
        }
        break;
    }
  }

  void changeUserDetails(UserModel user) {
    emit(Authenticated(user: user));
  }

  /// Resets the authentication state to initial.
  /// Used when user wants to go back from verification screen to change phone number.
  void resetState() {
    emit(AuthInitial());
  }

  Future<void> refreshUserDetails() async {
    try {
      final UserModel user = await _authRepository.getUserDetails();
      emit(Authenticated(user: user));
      await LocalStorage.storeUserDetails(user);
    } catch (e) {
      // Silently fail - keep existing user data
    }
  }

  // Send OTP
  Future<void> sendOTP({required PhoneNumber phoneNumber}) async {
    emit(VerificationRequestProcessing());

    try {
      // Use Firebase phone authentication
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.formattedNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: forceResendingToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (usually on Android)
          try {
            final UserCredential userCredential = await _auth
                .signInWithCredential(credential);

            final String? firebaseToken = await userCredential.user
                ?.getIdToken();
            if (firebaseToken == null) {
              throw UnAuthenticated();
            }
            emit(VerificationCompleted(firebaseToken, phoneNumber));
          } on FirebaseAuthException catch (e) {
            emit(
              AuthFailed(
                FirebaseExceptions.fromCode(e.code).message ??
                    AppLabels.somethingWentWrong.tr,
              ),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(
            AuthFailed(
              FirebaseExceptions.fromCode(e.code).message ??
                  AppLabels.somethingWentWrong.tr,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          forceResendingToken = resendToken;

          emit(
            AuthVerificationRequired(
              verificationId: verificationId,
              phoneNumber: phoneNumber,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      emit(
        AuthFailed(
          FirebaseExceptions.fromCode(e.code).message ??
              AppLabels.somethingWentWrong.tr,
        ),
      );
    }
  }

  // Verify OTP
  Future<void> verifyOTP({
    required String verificationId,
    required String otp,
    required PhoneNumber phoneNumber,
  }) async {
    emit(VerificationProcessing());

    try {
      // Create a credential
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Sign in with credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final String? firebaseToken = await userCredential.user?.getIdToken();
      if (firebaseToken == null) throw UnAuthenticated();
      emit(VerificationCompleted(firebaseToken, phoneNumber));
    } on FirebaseAuthException catch (e) {
      emit(
        AuthFailed(
          FirebaseExceptions.fromCode(e.code).message ??
              AppLabels.somethingWentWrong.tr,
        ),
      );
    }
  }

  // Resend OTP
  Future<void> resendOTP({required PhoneNumber phoneNumber}) async {
    await sendOTP(phoneNumber: phoneNumber);
  }

  ///This will always be for email registration
  Future<void> register({
    String? email,
    required String name,
    required String password,
    required String confirmPassword,
    String? mobile,
    String? country,
  }) async {
    emit(AuthLoading());
    try {
      final LoginResponse<EmailSignupResult?>? loginResponse =
          await (_emailSignup..setData(
                EmailSignupParameters(password: password, email: email),
              ))
              .login();

      try {
        // Register on backend but don't authenticate yet - email verification required
        await _authRepository.register(
          password: password,
          confirmPassword: confirmPassword,
          name: name,
          email: email,
          mobile: mobile,
          country: country,
          firebaseToken: loginResponse!.response!.firebaseToken,
        );

        // Sign out from Firebase to prevent auto-login
        await _auth.signOut();

        // Emit email verification required state instead of authenticated
        emit(EmailVerificationRequired(email: email!));
      } catch (e) {
        ///This is to ensure that if the registration is done on firebase but fails on the backend, we delete the user from firebase.
        await loginResponse!.response!.credentials.user?.delete();
        rethrow;
      }
    } catch (e) {
      emit(AuthFailed(e));
    }
  }

  // Google login
  Future<void> signInWithGoogle() async {
    emit(SocialAuthLoading());
    try {
      final LoginResponse<UserCredential> response = await _googleLogin.login();
      final credential = response.response;

      // Save user data to backend
      final UserModel user = await _authRepository.socialLogin(
        credential,
        _googleLogin.provider,
      );

      await LocalStorage.setUserAuthenticated();
      await LocalStorage.storeUserDetails(user);
      GuestChecker.set('signInWithGoogle', isGuest: false);
      emit(Authenticated(user: user));
    } on CancelledException {
      // User cancelled login - reset state silently without showing error
      emit(UnAuthenticated());
    } catch (e) {
      emit(AuthFailed(e));
    }
  }

  // Apple login
  Future<void> signInWithApple() async {
    emit(SocialAuthLoading());

    try {
      final LoginResponse<UserCredential> response = await _appleLogin.login();
      final credential = response.response;
      // Save user data to backend
      final user = await _authRepository.socialLogin(
        credential,
        _appleLogin.provider,
      );
      await LocalStorage.setUserAuthenticated();
      await LocalStorage.storeUserDetails(user);
      GuestChecker.set('signInWithApple', isGuest: false);
      emit(Authenticated(user: user));
    } on CancelledException {
      // User cancelled login - reset state silently without showing error
      emit(UnAuthenticated());
    } catch (e) {
      emit(AuthFailed(e));
    }
  }

  // Login with phone & password
  Future<void> signInWithEmail({
    String? email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      _emailLogin.setData(
        EmailLoginParameters(email: email!, password: password),
      );
      final LoginResponse<EmailLoginResult>? result = await _emailLogin.login();

      if (result == null || result.response.firebaseToken == null) {
        throw Exception(AppLabels.loginIncomplete.tr);
      }
      final UserModel user = await _authRepository.loginWithEmail(
        firebaseToken: result.response.firebaseToken!,
        password: password,
        email: email,
      );
      await LocalStorage.setUserAuthenticated();
      await LocalStorage.storeUserDetails(user);
      GuestChecker.set('signInWithEmail', isGuest: false);

      emit(Authenticated(user: user));
    } on EmailNotVerifiedException catch (e) {
      emit(EmailNotVerified(email: e.email));
    } on FirebaseAuthException catch (e) {
      emit(
        AuthFailed(
          FirebaseExceptions.fromCode(e.code).message ??
              AppLabels.somethingWentWrong.tr,
        ),
      );
    } on CustomException catch (exception) {
      emit(AuthFailed(exception.code?.tr ?? exception.message));
    }
  }

  /// Resends verification email to the specified email address
  /// User must be signed in to Firebase (kept signed in after EmailNotVerified state)
  Future<void> resendVerificationEmail({required String email}) async {
    try {
      emit(AuthLoading());
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        await _auth.signOut();
        emit(EmailVerificationRequired(email: email));
      } else {
        // User already verified or not signed in
        await _auth.signOut();
        emit(UnAuthenticated());
      }
    } on FirebaseAuthException catch (e) {
      await _auth.signOut();
      emit(
        AuthFailed(
          FirebaseExceptions.fromCode(e.code).message ??
              AppLabels.somethingWentWrong.tr,
        ),
      );
    }
  }

  /// Cancels the email verification flow and signs out
  Future<void> cancelEmailVerification() async {
    await _auth.signOut();
    emit(UnAuthenticated());
  }

  Future<void> signInWithPhonePassword(
    PhonePasswordLoginParameters parameters,
  ) async {
    try {
      emit(AuthLoading());
      _phonePasswordLogin.setData(parameters);
      final loginResponse = await _phonePasswordLogin.login();
      if (loginResponse == null) {
        throw UnAuthenticated();
      }

      // Store authentication state and user details
      await LocalStorage.setUserAuthenticated();
      await LocalStorage.storeUserDetails(loginResponse.response!.user);
      GuestChecker.set('signInWithPhonePassword', isGuest: false);

      emit(Authenticated(user: loginResponse.response?.user));
    } catch (e) {
      emit(AuthFailed(e));
    }
  }

  // Guest login
  Future<void> signInAsGuest() async {
    emit(AuthLoading());
    try {
      final LoginResponse<GuestLoginResult> response = await _guestLogin
          .login();
      final GuestLoginResult result = response.response;
      if (result.success) {
        await LocalStorage.setUserAuthenticatedAsGuest();
        emit(AuthenticatedAsGuest());
      } else {
        emit(AuthFailed(AppLabels.guestLoginFailed.tr));
      }
    } catch (e) {
      emit(AuthFailed(e));
    }
  }

  // Sign out
  void signOut() {
    emit(AuthLoading());
    try {
      _auth.signOut();
      _googleLogin.signOut();
      LocalStorage.setUserAuthenticatedAsGuest();
      LocalStorage.clearToken();
      GuestChecker.set('signOut', isGuest: true);
      emit(AuthenticatedAsGuest());
    } catch (e) {
      emit(AuthFailed(e));
    }
  }

  Future<void> registerPhone({
    required String name,
    required PhoneNumber phoneNumber,
    required String confirmPassword,
    required String password,
    required String firebaseToken,
    String? email,
    String? country,
  }) async {
    try {
      emit(AuthLoading());
      final String? fcmToken = await FirebaseMessaging.instance.getToken();

      final Map response = await Api.post(
        Apis.mobileRegister,
        data: {
          ApiParams.name: name,
          ApiParams.countryCallingCode: phoneNumber.countryCallingCode?.replaceAll('+', ''),
          ApiParams.mobile: phoneNumber.number,
          ApiParams.confirmPassword: confirmPassword,
          ApiParams.password: password,
          ApiParams.fcmId: fcmToken,
          ApiParams.platformType: Platform.operatingSystem,
          ApiParams.firebaseToken: firebaseToken,
          if (email != null) ApiParams.email: email,
          if (country != null) 'country_code': country,
        },
      );

      final UserModel user = UserModel.fromJson(
        Map.from(response[ApiParams.data]),
      );
      await LocalStorage.setUserAuthenticated();
      await LocalStorage.storeUserDetails(user);
      GuestChecker.set('registerPhone', isGuest: false);
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthFailed(e));
    }
  }

  void resetEmailPassword({required String email}) async {
    try {
      emit(SendEmailVerificationLinkInProgress());
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      emit(SendEmailVerificationLinkSuccess());
    } on FirebaseAuthException catch (e) {
      emit(
        SendEmailVerificationLinkFail(
          FirebaseExceptions.fromCode(e.code).message ??
              AppLabels.somethingWentWrong.tr,
        ),
      );
    }
  }

  num? get walletBalance {
    if (state case final Authenticated success) {
      return success.user?.walletBalance;
    }
    return 0.0;
  }

  num? get creditBalance {
    if (state case final Authenticated success) {
      return success.user?.creditBalance;
    }
    return 0.0;
  }

  num? get totalBalance {
    if (state case final Authenticated success) {
      return success.user?.totalBalance;
    }
    return 0.0;
  }
}
