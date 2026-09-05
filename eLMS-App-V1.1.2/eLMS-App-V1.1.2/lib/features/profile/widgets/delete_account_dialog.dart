import 'dart:io';
import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_dialog_box.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/configs/app_settings.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/core/error_management/firebase_exceptions.dart';
import 'package:elms/core/login/apple_login.dart';
import 'package:elms/core/login/google_login.dart';
import 'package:elms/core/login/login.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/authentication/widgets/social_login_button.dart';
import 'package:elms/features/profile/cubit/delete_account_cubit.dart';
import 'package:elms/utils/countdown_timer.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

enum _LoginMethod { social, email, mobile }

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  bool isUserAgreed = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isVerificationInProgress = false;
  String? _firebaseToken;
  bool _isVerified = false;

  // OTP state
  bool _isOtpSent = false;
  String? _verificationId;
  CountdownTimer? _countdownTimer;

  @override
  void dispose() {
    _passwordController.dispose();
    _otpController.dispose();
    _countdownTimer?.dispose();
    super.dispose();
  }

  // --- Detection ---

  _LoginMethod _getLoginMethod() {
    final authState = context.read<AuthenticationCubit>().state;
    if (authState is Authenticated && authState.user != null) {
      final type = authState.user!.type?.toLowerCase();
      if (type == AuthenticationType.google.name ||
          type == AuthenticationType.apple.name) {
        return _LoginMethod.social;
      }
      if (type == 'phone' || type == 'mobile') {
        return _LoginMethod.mobile;
      }
    }
    return _LoginMethod.email;
  }

  AuthenticationType? _getSocialLoginType() {
    final authState = context.read<AuthenticationCubit>().state;
    if (authState is Authenticated && authState.user != null) {
      final userType = authState.user!.type;
      if (userType == AuthenticationType.google.name) {
        return AuthenticationType.google;
      } else if (userType == AuthenticationType.apple.name) {
        return AuthenticationType.apple;
      }
    }
    return null;
  }

  // --- Social login ---

  Future<void> _onTapSocialLogin() async {
    try {
      setState(() => _isVerificationInProgress = true);

      final socialLoginType = _getSocialLoginType();
      if (socialLoginType == null) return;

      if (socialLoginType == AuthenticationType.google) {
        await _handleGoogleLogin();
      } else if (socialLoginType == AuthenticationType.apple) {
        await _handleAppleLogin();
      }
    } catch (e) {
      UiUtils.showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isVerificationInProgress = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    final GoogleLogin googleLogin = GoogleLogin();
    final LoginResponse<UserCredential> loginResponse =
        await googleLogin.login();

    if (loginResponse.response.user != null) {
      _firebaseToken = await loginResponse.response.user?.getIdToken();
      if (mounted) setState(() => _isVerified = true);
    }
  }

  Future<void> _handleAppleLogin() async {
    final apple = AppleLogin();
    final LoginResponse<UserCredential> loginResponse = await apple.login();

    if (loginResponse.response.user != null) {
      _firebaseToken = await loginResponse.response.user?.getIdToken();
      if (mounted) setState(() => _isVerified = true);
    }
  }

  // --- Email/Password verification ---

  Future<void> _onTapVerifyPassword() async {
    if (_passwordController.text.isEmpty) {
      UiUtils.showSnackBar(AppLabels.pleaseEnterPassword.tr, isError: true);
      return;
    }

    try {
      setState(() => _isVerificationInProgress = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _passwordController.text,
        );
        await user.reauthenticateWithCredential(credential);
        _firebaseToken = await user.getIdToken();

        if (mounted) setState(() => _isVerified = true);
      }
    } catch (e) {
      UiUtils.showSnackBar(AppLabels.incorrectPassword.tr, isError: true);
    } finally {
      if (mounted) setState(() => _isVerificationInProgress = false);
    }
  }

  // --- Mobile OTP verification ---

  String _getMaskedPhoneNumber() {
    final authState = context.read<AuthenticationCubit>().state;
    if (authState is Authenticated && authState.user != null) {
      final user = authState.user!;
      final phone = user.mobile ?? '';
      final code = user.countryCallingCode ?? '';
      if (phone.length > 4) {
        return '$code ${'*' * (phone.length - 4)}${phone.substring(phone.length - 4)}';
      }
      return '$code $phone';
    }
    return '';
  }

  String _getFullPhoneNumber() {
    final authState = context.read<AuthenticationCubit>().state;
    if (authState is Authenticated && authState.user != null) {
      final user = authState.user!;
      return '${user.countryCallingCode ?? ''} ${user.mobile ?? ''}';
    }
    return '';
  }

  Future<void> _onTapSendOTP() async {
    try {
      setState(() => _isVerificationInProgress = true);

      final phoneNumber = _getFullPhoneNumber();
      if (phoneNumber.trim().isEmpty) {
        UiUtils.showSnackBar(AppLabels.phoneNumberRequired.tr, isError: true);
        return;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (usually on Android)
          try {
            final userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
            _firebaseToken = await userCredential.user?.getIdToken();
            if (mounted) setState(() => _isVerified = true);
          } on FirebaseAuthException catch (e) {
            if (mounted) {
              UiUtils.showSnackBar(
                FirebaseExceptions.fromCode(e.code).message ??
                    AppLabels.somethingWentWrong.tr,
                isError: true,
              );
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            setState(() => _isVerificationInProgress = false);
            UiUtils.showSnackBar(
              FirebaseExceptions.fromCode(e.code).message ??
                  AppLabels.somethingWentWrong.tr,
              isError: true,
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _isOtpSent = true;
              _isVerificationInProgress = false;
            });
            _startTimer();
            UiUtils.showSnackBar(AppLabels.otpSent.tr);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      UiUtils.showSnackBar(AppLabels.somethingWentWrong.tr, isError: true);
      if (mounted) setState(() => _isVerificationInProgress = false);
    }
  }

  Future<void> _onTapVerifyOTP() async {
    if (_otpController.text.length != 6 || _verificationId == null) return;

    try {
      setState(() => _isVerificationInProgress = true);

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      _firebaseToken = await userCredential.user?.getIdToken();

      if (mounted) setState(() => _isVerified = true);
    } on FirebaseAuthException catch (e) {
      UiUtils.showSnackBar(
        FirebaseExceptions.fromCode(e.code).message ??
            AppLabels.otpVerificationFailed.tr,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isVerificationInProgress = false);
    }
  }

  Future<void> _onTapResendOTP() async {
    _otpController.clear();
    await _onTapSendOTP();
  }

  void _startTimer() {
    _countdownTimer?.dispose();
    _countdownTimer = CountdownTimer(
      durationInSeconds: AppSettings.otpTimerDuration,
      onTick: (_) => setState(() {}),
      onComplete: () => setState(() {}),
    );
    _countdownTimer!.start();
  }

  // --- Confirm delete ---

  void _onTapConfirmDelete() {
    if (!isUserAgreed || _firebaseToken == null) return;
    context
        .read<DeleteAccountCubit>()
        .deleteAccount(firebaseToken: _firebaseToken!);
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final loginMethod = _getLoginMethod();

    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticatedAsGuest) {
          Get.offAllNamed(AppRoutes.loginScreen);
        }
      },
      child: BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
        listener: (context, state) {
          if (state is DeleteAccountSuccess) {
            context.read<AuthenticationCubit>().signOut();
          } else if (state is DeleteAccountFailed) {
            final error = state.error;
            if (error is CustomException) {
              if (error.toast) {
                UiUtils.showSnackBar(
                  error.message ?? AppLabels.somethingWentWrong.tr,
                  isError: true,
                );
              }
            } else {
              UiUtils.showSnackBar(error.toString(), isError: true);
            }
          }
        },
        builder: (context, state) {
          final bool isLoading = state is DeleteAccountInProgress;

          return CustomDialogBox(
            title: AppLabels.deleteAccount.tr,
            actions: _buildActions(loginMethod, isLoading),
            content: SingleChildScrollView(
              child: Column(
              spacing: 8,
              mainAxisSize: .min,
              children: [
                CustomImage(AppIcons.deleteIcon),
                CustomText(
                  AppLabels.deleteAccountPermanent.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: .w600),
                ),
                CustomText(
                  AppLabels.deleteAccountConfirmation.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: .w400),
                ),
                if (!_isVerified)
                  _buildVerificationContent(loginMethod, isLoading),
                if (_isVerified)
                  Row(
                    spacing: 8,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      CustomText(
                        AppLabels.verifiedSuccessfully.tr,
                        style: TextStyle(
                          fontSize: context.font.small,
                          color: Colors.green,
                          fontWeight: .w600,
                        ),
                      ),
                    ],
                  ),
                _buildDeleteAccountAgreement(),
              ],
            ),
            ),
          );
        },
      ),
    );
  }

  List<DialogButton> _buildActions(
    _LoginMethod loginMethod,
    bool isLoading,
  ) {
    return [
      DialogButton(
        title: AppLabels.no.tr,
        style: DialogButtonStyle.primary,
        onTap: isLoading ? null : () => Get.back(),
      ),
      if (!_isVerified)
        DialogButton(
          title: _getVerifyButtonTitle(loginMethod),
          style: DialogButtonStyle.outlined,
          onTap: _getVerifyButtonCallback(loginMethod, isLoading),
          color: _getVerifyButtonCallback(loginMethod, isLoading) != null
              ? null
              : context.color.textSecondary,
        ),
      if (_isVerified)
        DialogButton(
          title: AppLabels.confirmDeleteAccount.tr,
          style: DialogButtonStyle.outlined,
          onTap: !isLoading ? _onTapConfirmDelete : null,
          color: !isLoading ? Colors.green : context.color.textSecondary,
        ),
    ];
  }

  String _getVerifyButtonTitle(_LoginMethod loginMethod) {
    if (loginMethod == _LoginMethod.social) return AppLabels.verify.tr;
    if (loginMethod == _LoginMethod.email) return AppLabels.verifyPassword.tr;
    return _isOtpSent ? AppLabels.verifyOTP.tr : AppLabels.sendOTP.tr;
  }

  VoidCallback? _getVerifyButtonCallback(
    _LoginMethod loginMethod,
    bool isLoading,
  ) {
    if (!isUserAgreed || isLoading || _isVerificationInProgress) return null;

    if (loginMethod == _LoginMethod.social) return _onTapSocialLogin;
    if (loginMethod == _LoginMethod.email) return _onTapVerifyPassword;
    if (!_isOtpSent) return _onTapSendOTP;
    return _otpController.text.length == 6 ? _onTapVerifyOTP : null;
  }

  Widget _buildVerificationContent(_LoginMethod loginMethod, bool isLoading) {
    if (loginMethod == _LoginMethod.email) {
      return _buildEmailPasswordField(isLoading);
    }
    if (loginMethod == _LoginMethod.social) {
      return _buildSocialLoginButton(isLoading);
    }
    return _buildOtpVerification(isLoading);
  }

  Widget _buildEmailPasswordField(bool isLoading) {
    return CustomTextFormField(
      controller: _passwordController,
      title: AppLabels.password.tr,
      hintText: '*******',
      isPassword: true,
      enabled: !isLoading && !_isVerificationInProgress,
      requiredErrorMessage: AppLabels.passwordRequired.tr,
    );
  }

  Widget _buildOtpVerification(bool isLoading) {
    return Column(
      spacing: 8,
      crossAxisAlignment: .start,
      children: [
        CustomText(
          AppLabels.verifyIdentity.tr,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(fontWeight: .w600),
        ),
        CustomText(
          _getMaskedPhoneNumber(),
          style: TextStyle(
            fontSize: context.font.small,
            color: context.color.textSecondary,
          ),
        ),
        if (_isOtpSent) ...[
          CustomText(
            AppLabels.enterOTPToVerify.tr,
            style: TextStyle(
              fontSize: context.font.small,
              color: context.color.textSecondary,
            ),
          ),
          PinCodeTextField(
            appContext: context,
            length: 6,
            controller: _otpController,
            keyboardType: .number,
            enabled: !isLoading && !_isVerificationInProgress,
            autoDisposeControllers: false,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(8),
              fieldHeight: 45,
              fieldWidth: 36,
              activeFillColor: context.color.surface,
              inactiveFillColor: context.color.surface,
              selectedFillColor: context.color.surface,
              activeColor: context.color.textSecondary,
              inactiveColor: Colors.transparent,
              selectedColor: context.color.primary,
              disabledColor: context.color.outline.withValues(alpha: 0.5),
            ),
            hintCharacter: '0',
            animationDuration: const Duration(milliseconds: 300),
            enableActiveFill: true,
            onChanged: (_) => setState(() {}),
          ),
          _buildResendSection(),
        ],
      ],
    );
  }

  Widget _buildResendSection() {
    final timer = _countdownTimer;
    if (timer == null) return const SizedBox();

    if (timer.remainingSeconds == 0) {
      return GestureDetector(
        onTap: !_isVerificationInProgress ? _onTapResendOTP : null,
        child: CustomText(
          AppLabels.resendOTP.tr,
          style: TextStyle(
            color: !_isVerificationInProgress
                ? context.color.primary
                : context.color.primary.withValues(alpha: 0.4),
            fontWeight: .w500,
            fontSize: context.font.small,
          ),
        ),
      );
    }

    return CustomText(
      '${AppLabels.resendOTPIn.tr} : ${timer.formattedTime}',
      style: TextStyle(
        fontSize: context.font.small,
        color: context.color.textSecondary,
      ),
    );
  }

  Widget _buildSocialLoginButton(bool isLoading) {
    final socialLoginType = _getSocialLoginType();
    if (socialLoginType == null) return const SizedBox();

    String buttonText;
    String iconPath;

    if (socialLoginType == AuthenticationType.google) {
      buttonText = AppLabels.continueWithGoogle.tr;
      iconPath = AppIcons.googleIcon;
    } else if (socialLoginType == AuthenticationType.apple) {
      buttonText = AppLabels.continueWithApple.tr;
      iconPath = AppIcons.appleIcon;
    } else {
      return const SizedBox();
    }

    if (socialLoginType == AuthenticationType.apple && !Platform.isIOS) {
      return const SizedBox();
    }

    return Column(
      spacing: 8,
      crossAxisAlignment: .start,
      children: [
        CustomText(
          AppLabels.verifyIdentity.tr,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(fontWeight: .w600),
        ),
        SocialLoginButton(
          onPressed: (isLoading || _isVerificationInProgress)
              ? null
              : _onTapSocialLogin,
          iconPath: iconPath,
          text: buttonText,
        ),
      ],
    );
  }

  Widget _buildDeleteAccountAgreement() {
    return Row(
      crossAxisAlignment: .start,
      spacing: 15,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: isUserAgreed,
            onChanged: (value) {
              isUserAgreed = value ?? false;
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: CustomText(
            AppLabels.deleteAccountAgreement.tr,
            style: TextStyle(fontSize: context.font.small),
          ),
        ),
      ],
    );
  }
}
