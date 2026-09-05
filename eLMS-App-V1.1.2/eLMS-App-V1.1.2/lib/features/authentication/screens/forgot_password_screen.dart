import 'package:country_code_picker/country_code_picker.dart';
import 'package:elms/common/widgets/custom_popscope.dart';
import 'package:elms/core/login/phone_password_login.dart';
import 'package:elms/features/authentication/cubit/reset_password_cubit.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/validator.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/authentication/widgets/adaptive_auth_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:elms/core/constants/app_labels.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final bool isPhoneLogin;
  const ForgotPasswordScreen({super.key, required this.isPhoneLogin});

  static Widget route() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    return BlocProvider(
      create: (context) => ResetPasswordCubit(AuthRepository()),
      child: ForgotPasswordScreen(
        isPhoneLogin: (arguments?['isPhoneLogin'] as bool?) ?? false,
      ),
    );
  }

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late bool isPhoneMode = widget.isPhoneLogin;
  bool isLoading = false;
  CountryCode? selectedCountryCode;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onPressContinue() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      if (isPhoneMode) {
        // Handle phone password reset
        context.read<AuthenticationCubit>().sendOTP(
          phoneNumber: PhoneNumber(
            number: _phoneController.text,
            countryCallingCode: selectedCountryCode!.dialCode!,
          ),
        );
      } else {
        context.read<AuthenticationCubit>().resetEmailPassword(
          email: _emailController.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScope(
      preventOverlay: true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
            builder: (BuildContext context, AuthenticationState state) {
              ////
              final bool isProcessing =
                  (state is AuthLoading ||
                  state is AuthVerifyingOTP ||
                  state is SendEmailVerificationLinkInProgress);
              ////
              return SingleChildScrollView(
                padding: const .all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      SizedBox(
                        width: context.screenWidth,
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              AppLabels.forgotPassword.tr,
                              style: TextStyle(
                                fontSize: context.font.xxxLarge,
                              ).copyWith(fontWeight: .w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isPhoneMode
                                  ? AppLabels.enterPhoneNumberForReset.tr
                                  : AppLabels.enterEmailForReset.tr,
                              textAlign: .center,
                              style: TextStyle(fontSize: context.font.small),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 52),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isPhoneMode
                            ? AdaptiveAuthField(
                                title: AppLabels.enterPhoneNumber.tr,
                                isRequired: true,
                                hintText: AppLabels.enterPhoneNumber.tr,
                                controller: _phoneController,
                                fixedFieldType: AdaptiveFieldMode.number,
                                onChangedCountryCode: (CountryCode? code) {
                                  selectedCountryCode = code;
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    timeStamp,
                                  ) {
                                    setState(() {});
                                  });
                                },
                              )
                            : CustomTextFormField(
                                title: AppLabels.email.tr,
                                hintText: AppLabels.emailHint.tr,
                                controller: _emailController,
                                isRequired: true,
                                validator: Validators.validateEmail,
                                requiredErrorMessage:
                                    AppLabels.emailRequired.tr,
                              ),
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        onPressed: isProcessing ? null : _onPressContinue,
                        title: isProcessing
                            ? AppLabels.processing.tr
                            : AppLabels.continueLabel.tr,
                        fullWidth: true,
                        backgroundColor: context.color.primary,
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
