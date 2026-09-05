import 'dart:async';
import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_popscope.dart';
import 'package:elms/core/login/phone_password_login.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/loader.dart';
import 'package:elms/utils/countdown_timer.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/core/configs/app_settings.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/ui_utils.dart';

extension type VerificationDestination(String route) {}

class VerificationScreen extends StatefulWidget {
  final PhoneNumber phoneNumber;
  final String verificationId;

  const VerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  static Widget route() {
    final VerifyScreenArguments args = Get.arguments as VerifyScreenArguments;

    return VerificationScreen(
      phoneNumber: args.phoneNumber,
      verificationId: args.verificationId,
    );
  }

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  late CountdownTimer _timer;

  @override
  void initState() {
    super.initState();
    Get.put(VerificationDestination(Get.previousRoute));

    _timer = CountdownTimer(
      durationInSeconds: AppSettings.otpTimerDuration,
      onTick: (final int remainingSeconds) {
        setState(() {});
      },
      onComplete: () {
        setState(() {});
      },
    );

    // Start timer
    _timer.start();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer.dispose();
    super.dispose();
  }

  // Timer callback

  String formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  Future<void> _onTapVerifyButton() async {
    // Use the direct verifyOTP method with loading overlay
    await LoadingOverlay.execute(
      () => context.read<AuthenticationCubit>().verifyOTP(
        verificationId: widget.verificationId,
        otp: _otpController.text,
        phoneNumber: widget.phoneNumber,
      ),
    );
  }

  Future<void> _onTapResendOTP() async {
    await LoadingOverlay.execute(
      () => context.read<AuthenticationCubit>().resendOTP(
        phoneNumber: widget.phoneNumber,
      ),
    );
    _timer.reset();
    _timer.start();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScope(
      preventOverlay: true,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: SafeArea(child: _buildContent(context)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
      actions: [
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: CustomButton(
            onPressed: () => Get.offAllNamed(AppRoutes.loginScreen),
            border: 1,
            type: CustomButtonType.outlined,
            title: AppLabels.skip.tr,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const .all(16),
      child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 56),
              Text(
                AppLabels.signInWithMobile.tr,
                style: TextStyle(
                  fontWeight: .w500,
                  fontSize: context.font.xxxLarge,
                ),
                textAlign: .center,
              ),
              Padding(
                padding: const .symmetric(vertical: 8),
                child: Text(
                  AppLabels.verificationCodeSent.tr,
                  textAlign: .center,
                  style: TextStyle(
                    fontSize: context.font.small,
                    fontWeight: .w400,
                    color: context.color.textSecondary,
                  ),
                ),
              ),
              _buildPhoneNumberRow(context, state, colorScheme),
              const SizedBox(height: 58),
              _buildPinCodeField(context, state, colorScheme, screenSize),
              if (state is AuthFailed) ...[
                Text(
                  UiUtils.friendlyErrorMessage(state.error),
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              _buildVerifyButton(context, state, colorScheme),
              SizedBox(height: screenSize.height * 0.03),
              _buildResendSection(context, state, colorScheme, theme),
              const SizedBox(height: 14),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhoneNumberRow(
    BuildContext context,
    AuthenticationState state,
    ColorScheme colorScheme,
  ) {
    return Row(
      spacing: 4,
      mainAxisAlignment: .center,
      children: [
        Text(
          widget.phoneNumber.formattedNumber,
          style: TextStyle(
            fontSize: context.font.small,
            fontWeight: .w400,
            color: context.color.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: state is VerificationProcessing
              ? null
              : () {
                  Get.back();
                },
          child: Text(
            AppLabels.change.tr,
            style: TextStyle(
              color: state is VerificationProcessing
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinCodeField(
    BuildContext context,
    AuthenticationState state,
    ColorScheme colorScheme,
    Size screenSize,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: screenSize.width * 0.9),
      child: PinCodeTextField(
        appContext: context,
        length: 6,
        controller: _otpController,
        keyboardType: TextInputType.number,
        enabled: state is! VerificationProcessing,
        autoDisposeControllers: false,
        animationType: AnimationType.fade,

        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(8),
          fieldHeight: 53,
          fieldWidth: (screenSize.width - 72) / 6,

          activeFillColor: colorScheme.surface,
          inactiveFillColor: colorScheme.surface,
          selectedFillColor: colorScheme.surface,
          activeColor: colorScheme.textSecondary,
          inactiveColor: Colors.transparent,
          selectedColor: colorScheme.primary,
          disabledColor: colorScheme.outline.withValues(alpha: 0.5),
        ),
        hintCharacter: '0',
        animationDuration: const Duration(milliseconds: 300),
        enableActiveFill: true,

        // onCompleted: (_) => _onTapVerifyButton(), //Currently disabled as this is not needed
        onChanged: (_) {
          // Trigger rebuild to update verify button state
          setState(() {});
        },
      ),
    );
  }

  Widget _buildVerifyButton(
    BuildContext context,
    AuthenticationState state,
    ColorScheme colorScheme,
  ) {
    return CustomButton(
      onPressed:
          _otpController.text.length == 6 && state is! VerificationProcessing
          ? _onTapVerifyButton
          : null,
      title: state is VerificationProcessing
          ? AppLabels.verifying.tr
          : AppLabels.continueLabel.tr,
      fullWidth: true,
      backgroundColor: colorScheme.primary,
    );
  }

  Widget _buildResendSection(
    BuildContext context,
    AuthenticationState state,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final bool isProcessing = state is VerificationProcessing;

    if (_timer.remainingSeconds == 0) {
      return TextButton(
        onPressed: !isProcessing ? _onTapResendOTP : null,
        child: Text(
          AppLabels.resendOTP.tr,
          style: TextStyle(
            color: isProcessing
                ? colorScheme.primary.withValues(alpha: 0.4)
                : colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Text(
      '${AppLabels.resendOTPIn.tr} : ${_timer.formattedTime}',
      style: theme.textTheme.bodyMedium,
    );
  }
}
