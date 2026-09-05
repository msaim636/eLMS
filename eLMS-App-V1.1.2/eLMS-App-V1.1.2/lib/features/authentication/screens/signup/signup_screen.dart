import 'package:country_code_picker/country_code_picker.dart';
import 'package:elms/core/login/phone_password_login.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/widgets/adaptive_auth_field.dart';
import 'package:elms/features/authentication/widgets/terms_privacy_agreement.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/loader.dart';
import 'package:elms/utils/text_formatters.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:elms/utils/validator.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_dialog_box.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/authentication/cubit/check_user_exists_cubit.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

/// Holds pending phone registration data during OTP verification
class PendingPhoneRegistration {
  final String name;
  final String password;
  final String confirmPassword;
  final String? email;
  final String? country;

  PendingPhoneRegistration({
    required this.name,
    required this.password,
    required this.confirmPassword,
    this.email,
    this.country,
  });
}

enum SignupMode { email, phone }

class SignupScreen extends StatefulWidget {
  final SignupMode mode;
  final String? email;
  final PhoneNumber? phoneNumber;
  final String? firebaseToken;
  const SignupScreen({
    super.key,
    required this.mode,
    this.email,
    this.phoneNumber,
    this.firebaseToken,
  });

  static Widget route() {
    final SignupArguments arguments = Get.arguments as SignupArguments;

    return BlocProvider(
      create: (_) => CheckMobileUserExistsCubit(AuthRepository()),
      child: SignupScreen(
        mode: arguments.mode,
        email: arguments.email,
        phoneNumber: arguments.phoneNumber,
        firebaseToken: arguments.firebaseToken,
      ),
    );
  }

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isChecked = false;
  CountryCode? _countryCode;

  @override
  void initState() {
    if (widget.mode == SignupMode.phone) {
      _phoneController.text = widget.phoneNumber?.formattedNumber ?? "";
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onTapSignupButton() async {
    if (_formKey.currentState!.validate() && _isChecked) {
      if (widget.mode == SignupMode.email) {
        String? formattedPhone;
        if (_phoneController.text.isNotEmpty && _countryCode != null) {
          formattedPhone = '${_countryCode!.dialCode}${_phoneController.text}';
        }

        await context.read<AuthenticationCubit>().register(
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          email: _emailController.text,
          name: _nameController.text,
          mobile: formattedPhone,
        );
      } else {
        // Phone registration: verify the number isn't already registered
        // before consuming an OTP.
        if (_countryCode == null) {
          UiUtils.showSnackBar(AppLabels.selectCountryCode.tr, isError: true);
          return;
        }

        await context
            .read<CheckMobileUserExistsCubit>()
            .checkIfMobileUserExists(
              _phoneController.text,
              countryCallingCode: _countryCode!.dialCode!,
            );
      }
    } else if (!_isChecked && _formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLabels.agreeToTerms.tr),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Stores pending registration data and sends an OTP to the entered phone
  /// number. Only called once the number is confirmed to be unregistered.
  void _sendPhoneOtp() {
    Get.put(
      PendingPhoneRegistration(
        name: _nameController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
      ),
    );

    context.read<AuthenticationCubit>().sendOTP(
      phoneNumber: PhoneNumber(
        number: _phoneController.text,
        countryCallingCode: _countryCode!.dialCode!,
      ),
    );
  }

  void _handleUserExistsStateChange(
    BuildContext context,
    CheckMobileUserExistsState state,
  ) {
    if (state is CheckMobileUserExistsLoading) {
      LoadingOverlay.show();
    } else {
      LoadingOverlay.hide();
    }

    if (state is MobileUserExists) {
      UiUtils.showSnackBar(AppLabels.accountAlreadyExists.tr, isError: true);
    } else if (state is MobileUserDoesNotExist) {
      _sendPhoneOtp();
    } else if (state is CheckMobileUserExistsError) {
      UiUtils.showSnackBar(state.message, isError: true);
    }
  }

  void _onTapSignIn() {
    Get.back();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthenticationCubit, AuthenticationState>(
          listener: _handleAuthStateChange,
        ),
        BlocListener<CheckMobileUserExistsCubit, CheckMobileUserExistsState>(
          listener: _handleUserExistsStateChange,
        ),
      ],
      child: PopScope(
        canPop: widget.mode == SignupMode.phone ? false : true,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            return;
          }

          ///exit the app because we have kept the login screen our stack for listeners
          if (widget.mode == SignupMode.phone) {
            Future.delayed(Duration.zero, () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            });
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    // Header
                    Center(
                      child: CustomText(
                        AppLabels.signupTitle.tr,
                        style: TextStyle(
                          fontSize: context.font.xxxLarge,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subheader
                    Center(
                      child: CustomText(
                        widget.mode == SignupMode.phone
                            ? AppLabels.signupSubtitlePhone.tr
                            : AppLabels.signupSubtitleEmail.tr,
                        textAlign: TextAlign.center,
                        color: context.color.textSecondary,
                        style: TextStyle(
                          fontSize: context.font.medium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSignupForm(),

                    // Sign Up button
                    CustomButton(
                      key: const Key('signup_submit_button'),
                      onPressed: _onTapSignupButton,
                      title: AppLabels.signUp.tr,
                      backgroundColor: context.color.primary,
                      textColor: context.color.onPrimary,
                      fullWidth: true,
                      height: 40,
                    ),
                    const SizedBox(height: 20),
                    // Already have account
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: AppLabels.alreadyHaveAccount.tr,
                          style: TextStyle(
                            fontSize: 16,
                            color: context.color.textSecondary,
                          ),
                          children: [
                            const WidgetSpan(child: SizedBox(width: 4)),
                            TextSpan(
                              text: AppLabels.login.tr,
                              style: TextStyle(
                                color: context.color.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _onTapSignIn,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Terms and Privacy
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _isChecked,
                          activeColor: context.color.primary,
                          onChanged: (value) {
                            setState(() {
                              _isChecked = value ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(top: 8),
                            child: TermsAndPrivacyAgreement(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleAuthStateChange(BuildContext context, AuthenticationState state) {
    // Handle loading states
    if (state is VerificationRequestProcessing || state is AuthLoading) {
      LoadingOverlay.show();
    } else {
      LoadingOverlay.hide();
    }

    // Handle OTP sent - navigate to verification screen
    if (state is AuthVerificationRequired && widget.mode == SignupMode.phone) {
      Get.toNamed(
        AppRoutes.verificationScreen,
        arguments: VerifyScreenArguments(
          phoneNumber: state.phoneNumber,
          verificationId: state.verificationId,
        ),
      );
    }
    // Handle OTP verified - call registerPhone API with stored data
    else if (state is VerificationCompleted &&
        widget.mode == SignupMode.phone) {
      _completePhoneRegistration(state.firebaseToken, state.phoneNumber);
    }
    // Handle email verification required - show dialog and redirect to login
    else if (state is EmailVerificationRequired) {
      _showEmailVerificationDialog(state.email);
    }
    // Handle registration success - for both phone and email
    else if (state is Authenticated) {
      if (Get.isRegistered<PendingPhoneRegistration>()) {
        Get.delete<PendingPhoneRegistration>(force: true);
      }
      Get.offAllNamed(AppRoutes.mainActivity);
    }
    // Handle errors
    else if (state is AuthFailed) {
      UiUtils.showSnackBar(
        UiUtils.friendlyErrorMessage(state.error),
        isError: true,
      );
    }
  }

  void _showEmailVerificationDialog(String email) {
    UiUtils.showDialog(
      context,
      dismissible: false,
      child: CustomDialogBox(
        title: AppLabels.requestEmailVerification.tr,
        content: CustomText('${AppLabels.sentVerificationEmail.tr}\n\n$email'),
        actions: [
          DialogButton(
            title: AppLabels.backToLogin.tr,
            style: DialogButtonStyle.primary,
            onTap: () {
              Get.back();
              Get.offAllNamed(AppRoutes.loginScreen);
            },
          ),
        ],
      ),
    );
  }

  void _completePhoneRegistration(
    String firebaseToken,
    PhoneNumber phoneNumber,
  ) {
    // Get stored pending registration data
    final pendingData = Get.find<PendingPhoneRegistration>();

    // Call registerPhone API
    context.read<AuthenticationCubit>().registerPhone(
      name: pendingData.name,
      password: pendingData.password,
      confirmPassword: pendingData.confirmPassword,
      phoneNumber: phoneNumber,
      firebaseToken: firebaseToken,
      email: pendingData.email,
      country: pendingData.country,
    );
  }

  Widget _buildSignupForm() {
    final phone = AdaptiveAuthField(
      key: const Key('signup_phone_input'),
      title: AppLabels.phoneNumber.tr,
      hintText: AppLabels.enterPhoneNumber.tr,
      isRequired: widget.mode == SignupMode.phone,
      controller: _phoneController,
      fixedFieldType: AdaptiveFieldMode.number,
      onChangedCountryCode: (code) {
        _countryCode = code;
      },
    );
    final email = AdaptiveAuthField(
      key: const Key('signup_email_input'),
      title: AppLabels.email.tr,
      hintText: AppLabels.emailHint.tr,
      isRequired: widget.mode == SignupMode.email,
      controller: _emailController,
      fixedFieldType: AdaptiveFieldMode.email,
    );
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          key: const Key('signup_name_input'),
          title: AppLabels.name.tr,
          hintText: AppLabels.enterName.tr,
          isRequired: true,
          controller: _nameController,
          validator: Validators.validateName,
          requiredErrorMessage: AppLabels.nameRequired.tr,
        ),

        if (widget.mode == SignupMode.phone) ...[
          phone,
          email,
        ] else ...[
          email,
          phone,
        ],

        CustomTextFormField(
          key: const Key('signup_password_input'),
          title: AppLabels.password.tr,
          hintText: AppLabels.passwordHint.tr,
          isRequired: true,
          controller: _passwordController,
          formatters: [NoSpaceFormatter()],
          validator: (v) => Validators.validatePassword(v, true),
          isPassword: true,
          requiredErrorMessage: AppLabels.passwordRequired.tr,
        ),
        CustomTextFormField(
          key: const Key('signup_confirm_password_input'),
          title: AppLabels.confirmPassword.tr,
          hintText: AppLabels.confirmPasswordHint.tr,
          isRequired: true,
          controller: _confirmPasswordController,
          validator: (value) => Validators.validateConfirmPassword(
            value,
            _passwordController.text,
          ),
          formatters: [NoSpaceFormatter()],
          requiredErrorMessage: AppLabels.confirmPasswordRequired.tr,
          isPassword: true,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
