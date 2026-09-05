import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/core/error_management/firebase_exceptions.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/reset_password_cubit.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/loader.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:elms/utils/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  static Widget route() => BlocProvider(
    create: (context) => ResetPasswordCubit(AuthRepository()),
    child: const ResetPasswordScreen(),
  );

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const .all(16.0),
        child: BlocListener<ResetPasswordCubit, ResetPasswordState>(
          listener: (context, state) {
            if (state is ResetPasswordInProgress) {
              LoadingOverlay.show();
            }
            if (state is ResetPasswordSuccess) {
              LoadingOverlay.hide();
              UiUtils.showSnackBar(AppLabels.passwordResetSuccess.tr);

              ///This will redirect to login screen
              Get.offNamedUntil(AppRoutes.loginScreen, (route) => true);
            }
            if (state is ResetPasswordFailed) {
              LoadingOverlay.hide();
              UiUtils.showSnackBar(UiUtils.friendlyErrorMessage(state.error), isError: true);
            }
          },
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  SizedBox(height: context.screenHeight * 0.2),
                  CustomText(
                    AppLabels.createNewPassword.tr,
                    style: TextStyle(fontSize: context.font.xxxLarge),
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    AppLabels.resetPasswordSubtitle.tr,
                    style: TextStyle(
                      fontSize: context.font.medium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomTextFormField(
                    controller: _passwordController,
                    title: AppLabels.password.tr,
                    isRequired: true,
                    hintText: AppLabels.passwordHint.tr,
                    validator: Validators.validateRequired,
                    requiredErrorMessage: AppLabels.passwordRequired.tr,
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _confirmPasswordController,
                    title: AppLabels.confirmPassword.tr,
                    isRequired: true,
                    hintText: AppLabels.passwordHint.tr,
                    validator: (p0) => Validators.validateConfirmPassword(
                      p0,
                      _passwordController.text,
                    ),
                    requiredErrorMessage: AppLabels.confirmPasswordRequired.tr,
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    title: AppLabels.changePassword.tr,
                    height: 40,
                    fullWidth: true,
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        try {
                          final cubit = context.read<ResetPasswordCubit>();
                          final String? firebaseToken = await FirebaseAuth
                              .instance
                              .currentUser
                              ?.getIdToken();
                          if (firebaseToken == null) {
                            throw AppException(
                              message: AppLabels.firebaseTokenError.tr,
                            );
                          }
                          if (!mounted) return;
                          cubit.reset(
                            password: _passwordController.text,
                            confirmPassword: _confirmPasswordController.text,
                            firebaseToken: firebaseToken,
                          );
                        } on FirebaseAuthException catch (e) {
                          UiUtils.showSnackBar(
                            FirebaseExceptions.fromCode(e.code).message ??
                                AppLabels.somethingWentWrong.tr,
                            isError: true,
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    child: GestureDetector(
                      onTap: () {
                        Get.offNamedUntil(
                          AppRoutes.loginScreen,
                          (Route route) => route.isFirst,
                        );
                      },
                      child: CustomText(
                        AppLabels.backToLogin.tr,
                        style: TextStyle(fontSize: context.font.small),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
