import 'dart:io';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/authentication/screens/signup/signup_screen.dart';
import 'package:elms/features/authentication/widgets/social_login_button.dart';
import 'package:elms/features/authentication/widgets/terms_privacy_agreement.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class RegisterOptionsScreen extends StatefulWidget {
  const RegisterOptionsScreen({super.key});

  static Widget route() => const RegisterOptionsScreen();

  @override
  State<RegisterOptionsScreen> createState() => _RegisterOptionsScreenState();
}

class _RegisterOptionsScreenState extends State<RegisterOptionsScreen> {
  Future<void> _onTapSkip() async {
    await Get.offAllNamed(AppRoutes.mainActivity);
  }

  void _onTapRegisterWithPhone() {
    Get.toNamed(
      AppRoutes.signupScreen,
      arguments: SignupArguments(mode: SignupMode.phone),
    );
  }

  void _onTapRegisterWithEmail() {
    Get.toNamed(
      AppRoutes.signupScreen,
      arguments: SignupArguments(mode: SignupMode.email),
    );
  }

  void _onTapContinueWithApple() {
    if (Platform.isIOS) {
      context.read<AuthenticationCubit>().signInWithApple();
    }
  }

  void _onTapContinueWithGoogle() {
    context.read<AuthenticationCubit>().signInWithGoogle();
  }

  void _onTapLogin() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildSkipButton(context),
                    const SizedBox(height: 64),
                    _buildHeader(context),
                    const SizedBox(height: 40),
                    _buildRegistrationOptions(context),
                    const SizedBox(height: 40),
                    _buildAlreadyHaveAccount(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildTermsAndPrivacy(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: CustomButton(
        onPressed: _onTapSkip,
        title: AppLabels.skip.tr,
        height: 36,
        width: 70,
        backgroundColor: context.color.surface,
        textColor: context.color.onSurface,
        textSize: 14,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          CustomText(
            AppLabels.registrationOption.tr,
            style: Theme.of(
              context,
            ).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          CustomText(
            AppLabels.selectRegistrationMethod.tr,
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          CustomText(
            AppLabels.registrationMethodDescription.tr,
            style: TextStyle(fontSize: context.font.small),
            textAlign: TextAlign.center,
            color: context.color.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationOptions(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        SocialLoginButton(
          onPressed: _onTapRegisterWithEmail,
          iconPath: AppIcons.emailLoginIcon,
          text: AppLabels.continueWithEmail.tr,
        ),
        SocialLoginButton(
          onPressed: _onTapRegisterWithPhone,
          iconPath: AppIcons.telePhoneIcon,
          text: AppLabels.continueWithPhone.tr,
        ),
        SocialLoginButton(
          onPressed: _onTapContinueWithGoogle,
          iconPath: AppIcons.googleIcon,
          text: AppLabels.continueWithGoogle.tr,
        ),
        if (Platform.isIOS)
          SocialLoginButton(
            onPressed: _onTapContinueWithApple,
            iconPath: AppIcons.appleIcon,
            text: AppLabels.continueWithApple.tr,
          ),
      ],
    );
  }

  Widget _buildAlreadyHaveAccount(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: AppLabels.alreadyHaveAccount.tr,
          style: TextStyle(
            fontSize: context.font.small,
            color: context.color.textSecondary,
          ),
          children: [
            const TextSpan(text: ' '),
            TextSpan(
              text: AppLabels.login.tr,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()..onTap = _onTapLogin,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAndPrivacy(BuildContext context) {
    return const Center(
      child: TermsAndPrivacyAgreement(align: TextAlign.center),
    );
  }
}
