import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_dialog_box.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/login/phone_password_login.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/features/authentication/cubit/check_user_exists_cubit.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:elms/features/authentication/screens/signup/signup_screen.dart';
import 'package:elms/features/authentication/screens/verification_screen.dart';
import 'package:elms/features/authentication/widgets/terms_privacy_agreement.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/loader.dart';
import 'package:elms/utils/local_storage.dart';
import 'package:elms/utils/text_formatters.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:elms/utils/validator.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/authentication/widgets/adaptive_auth_field.dart';
import 'package:elms/features/authentication/widgets/divider_with_text.dart';
import 'package:elms/features/authentication/widgets/social_login_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Widget route() => BlocProvider(
        create: (_) => CheckMobileUserExistsCubit(AuthRepository()),
        child: const LoginScreen(),
      );

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ///This is mode of screen
  bool isPhoneLogin = false;
  CountryCode? selectCountryCode;

  @override
  void initState() {
    ///This will set the user as guest but when the user opens app second time it will directly go to home
    LocalStorage.setUserIsGuest();

    ///Prefill demo credentials when demo mode is enabled.
    if (AppConstant.kIsDemoMode) {
      _emailController.text = AppConstant.kDemoEmail;
      _passwordController.text = AppConstant.kDemoPassword;
    }

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showResendVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDialogBox(
        title: AppLabels.emailNotVerifiedTitle.tr,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              AppLabels.emailNotVerifiedMessage.tr,
              style: TextStyle(fontSize: context.font.small),
            ),
            const SizedBox(height: 8),
            CustomText(
              email,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          DialogButton(
            title: AppLabels.cancel.tr,
            style: DialogButtonStyle.outlined,
            onTap: () {
              Get.back();
              context.read<AuthenticationCubit>().cancelEmailVerification();
            },
          ),
          DialogButton(
            title: AppLabels.resend.tr,
            style: DialogButtonStyle.primary,
            onTap: () {
              Get.back();
              context.read<AuthenticationCubit>().resendVerificationEmail(
                email: email,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showVerificationSentDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDialogBox(
        title: AppLabels.verificationEmailSent.tr,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              AppLabels.sentVerificationEmail.tr,
              style: TextStyle(fontSize: context.font.small),
            ),
            const SizedBox(height: 8),
            CustomText(
              email,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          DialogButton(
            title: AppLabels.ok.tr,
            style: DialogButtonStyle.primary,
            onTap: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  void _toggleLoginMode() {
    ///Reset the form to clear any validation error messages from the
    ///previous login type before switching.
    _formKey.currentState?.reset();
    setState(() {
      isPhoneLogin = !isPhoneLogin;
      _emailController.clear();
      _passwordController.clear();
      _phoneController.clear();
    });
  }

  Widget _buildEmailLoginFields() {
    return Column(
      children: [
        CustomTextFormField(
          title: AppLabels.email.tr,
          hintText: AppLabels.emailHint.tr,
          controller: _emailController,
          isRequired: true,
          formatters: [NoSpaceFormatter()],
          validator: Validators.validateEmail,
          requiredErrorMessage: AppLabels.emailRequired.tr,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          title: AppLabels.password.tr,
          hintText: AppLabels.passwordHint.tr,
          controller: _passwordController,
          isRequired: true,
          formatters: [NoSpaceFormatter()],
          isPassword: true,
          requiredErrorMessage: AppLabels.passwordRequired.tr,
        ),
      ],
    );
  }

  Widget _buildPhoneLoginFields() {
    return Column(
      children: [
        AdaptiveAuthField(
          title: AppLabels.phoneNumber.tr,
          isRequired: true,
          hintText: AppLabels.enterPhoneNumber.tr,
          controller: _phoneController,
          fixedFieldType: AdaptiveFieldMode.number,
          onChangedCountryCode: (CountryCode? code) {
            selectCountryCode = code;
          },
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          title: AppLabels.password.tr,
          hintText: AppLabels.passwordHint.tr,
          controller: _passwordController,
          isRequired: true,
          isPassword: true,
          validator: Validators.validatePassword,
          requiredErrorMessage: AppLabels.passwordRequired.tr,
        ),
      ],
    );
  }

  void _onPressContinue() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      if (isPhoneLogin) {
        context.read<CheckMobileUserExistsCubit>().checkIfMobileUserExists(
          _phoneController.text,
          countryCallingCode: selectCountryCode!.dialCode!,
        );
      } else {
        context
            .read<CheckMobileUserExistsCubit>()
            .checkIfEmailUserExists(_emailController.text);
      }
    }
  }

  void _proceedWithSignIn() {
    if (isPhoneLogin) {
      context.read<AuthenticationCubit>().signInWithPhonePassword(
        PhonePasswordLoginParameters(
          phoneNumber: PhoneNumber(
            number: _phoneController.text,
            countryCallingCode: selectCountryCode!.dialCode!,
          ),
          password: _passwordController.text,
        ),
      );
    } else {
      context.read<AuthenticationCubit>().signInWithEmail(
        password: _passwordController.text,
        email: _emailController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BlocListener<CheckMobileUserExistsCubit,
            CheckMobileUserExistsState>(
          listener: (context, state) {
            if (state is CheckMobileUserExistsLoading) {
              LoadingOverlay.show();
            } else {
              LoadingOverlay.hide();
            }
            if (state is MobileUserExists) {
              _proceedWithSignIn();
            } else if (state is MobileUserDoesNotExist) {
              UiUtils.showSnackBar(
                AppLabels.userNotFound.tr,
                isError: true,
              );
            } else if (state is CheckMobileUserExistsError) {
              UiUtils.showSnackBar(state.message, isError: true);
            }
          },
          child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
          listener: (BuildContext context, AuthenticationState state) {
            // Skip all handling if SignupScreen initiated the phone registration flow
            final isSignupPhoneFlow =
                Get.isRegistered<PendingPhoneRegistration>();

            ///This is to show loading overlay on login screen
            if (!isSignupPhoneFlow) {
              if (state is AuthLoading ||
                  state is SocialAuthLoading ||
                  state is AuthVerifyingOTP ||
                  state is SendEmailVerificationLinkInProgress) {
                LoadingOverlay.show();
              } else {
                LoadingOverlay.hide();
              }
            }
            if (state is SignUpAsEmail) {
              ///Close the screen if signup screen
              if (Get.currentRoute == AppRoutes.signupScreen) {
                Get.back();
              }
              UiUtils.showSnackBar(AppLabels.requestEmailVerification.tr);
            } else if (state is Authenticated) {
              // Skip if SignupScreen initiated the phone registration flow
              if (isSignupPhoneFlow) return;
              Get.offAllNamed(AppRoutes.mainActivity);
            } else if (state is AuthFailed) {
              // Skip if SignupScreen initiated the phone registration flow
              if (isSignupPhoneFlow) return;
              // Skip if current route is signup screen (email signup flow)
              if (Get.currentRoute == AppRoutes.signupScreen) return;
              // Show error message
              if (state.error case final FirebaseAuthException error) {
                UiUtils.showSnackBar(error.message.toString(), isError: true);
              } else {
                UiUtils.showSnackBar(UiUtils.friendlyErrorMessage(state.error), isError: true);
              }
            } else if (state is AuthVerificationRequired) {
              // Skip if SignupScreen initiated the phone registration flow
              if (isSignupPhoneFlow) return;
              Get.toNamed(
                AppRoutes.verificationScreen,
                arguments: VerifyScreenArguments(
                  phoneNumber: state.phoneNumber,
                  verificationId: state.verificationId,
                ),
              );
            } else if (state is VerificationCompleted) {
              // Skip if SignupScreen initiated the phone registration flow
              // (handles auto-verification on Android where VerificationCompleted
              // is emitted directly without going through VerificationScreen)
              if (isSignupPhoneFlow) return;

              ///Finding and comparing route here from, we injected the route from we came to the verification screen.
              final previousRoute = Get.find<VerificationDestination>().route;
              if (previousRoute == AppRoutes.forgotPasswordScreen) {
                Get.toNamed(AppRoutes.resetPasswordScreen);
              } else if (previousRoute != AppRoutes.signupScreen) {
                // Only navigate to SignupScreen if not coming from SignupScreen
                // (SignupScreen handles its own phone registration flow)
                Get.toNamed(
                  AppRoutes.signupScreen,
                  arguments: SignupArguments(
                    mode: SignupMode.phone,
                    phoneNumber: state.phoneNumber,
                    firebaseToken: state.firebaseToken,
                  ),
                );
              }
            } else if (state is EmailNotVerified) {
              // Show dialog to resend verification email
              _showResendVerificationDialog(state.email);
            } else if (state is EmailVerificationRequired) {
              // Skip if the signup screen is active — it shows its own dialog
              // (otherwise both listeners fire and two dialogs appear)
              if (Get.currentRoute == AppRoutes.signupScreen) return;
              // Verification email was sent successfully
              _showVerificationSentDialog(state.email);
            }
            if (state is SendEmailVerificationLinkSuccess) {
              UiUtils.showSnackBar(AppLabels.sentVerificationEmail.tr);
              Get.offNamedUntil(AppRoutes.loginScreen, (route) => true);
            }
            if (state is SendEmailVerificationLinkFail) {
              if (state.error case final FirebaseAuthException error) {
                UiUtils.showSnackBar(error.message.toString(), isError: true);
              } else {
                UiUtils.showSnackBar(UiUtils.friendlyErrorMessage(state.error), isError: true);
              }
            }
          },
          builder: (context, authenticationState) {
            final bool isProcessing = authenticationState is AuthLoading;

            void handleToggleMode() {
              if (!isProcessing) {
                _toggleLoginMode();
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: CustomButton(
                        type: CustomButtonType.outlined,
                        onPressed: isProcessing
                            ? null
                            : () => Get.offAllNamed(AppRoutes.mainActivity),
                        border: 1,
                        width: 61,
                        height: 38,
                        title: AppLabels.skip.tr,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: context.screenWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            AppLabels.signIn.tr,
                            style: TextStyle(
                              fontSize: context.font.xxxLarge,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isPhoneLogin
                                ? AppLabels.signInWithRegisteredNumber.tr
                                : AppLabels.signInWithRegisteredEmail.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: context.font.small,
                            ).copyWith(color: context.color.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 52),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isPhoneLogin
                          ? _buildPhoneLoginFields()
                          : _buildEmailLoginFields(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.forgotPasswordScreen,
                              arguments: {'isPhoneLogin': isPhoneLogin},
                            );
                          },
                          child: Text(
                            AppLabels.forgotPassword.tr,
                            style: TextStyle(
                              color: context.color.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    CustomButton(
                      key: const ValueKey('loginButton'),
                      onPressed: isProcessing ? null : _onPressContinue,
                      title: isProcessing
                          ? AppLabels.processing.tr
                          : AppLabels.signIn.tr,
                      fullWidth: true,
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: AppLabels.dontHaveAccount.tr,
                            style: TextStyle(
                              fontSize: context.font.small,
                            ).copyWith(color: context.color.textSecondary),
                          ),
                          const WidgetSpan(child: SizedBox(width: 4)),

                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed(AppRoutes.registerOptionsScreen);
                              },
                              child: Text(
                                AppLabels.signUp.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: context.color.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: DividerWithText(
                        text: AppLabels.orLoginWith.tr,
                        textColor: context.color.textSecondary,
                      ),
                    ),
                    Column(
                      spacing: 16,
                      children: [
                        SocialLoginButton(
                          onPressed: isProcessing
                              ? null
                              : () {
                                  context
                                      .read<AuthenticationCubit>()
                                      .signInWithGoogle();
                                },
                          iconPath: AppIcons.googleIcon,
                          text: AppLabels.continueWithGoogle.tr,
                        ),
                        if (Platform.isIOS)
                          SocialLoginButton(
                            onPressed: isProcessing
                                ? null
                                : () {
                                    context
                                        .read<AuthenticationCubit>()
                                        .signInWithApple();
                                  },
                            iconPath: AppIcons.appleIcon,
                            text: AppLabels.continueWithApple.tr,
                          ),
                        SocialLoginButton(
                          key: const ValueKey('toggle-mode'),
                          iconPath: isPhoneLogin
                              ? AppIcons.emailLoginIcon
                              : AppIcons.mobileLoginIcon,
                          onPressed: isProcessing ? null : handleToggleMode,
                          iconColor: context.color.primary,
                          text: isPhoneLogin
                              ? AppLabels.useEmail.tr
                              : AppLabels.usePhone.tr,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: TermsAndPrivacyAgreement(
                            align: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}
