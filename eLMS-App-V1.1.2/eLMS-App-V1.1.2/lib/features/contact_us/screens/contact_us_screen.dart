import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/contact_us/cubit/submit_contact_cubit.dart';
import 'package:elms/features/contact_us/repository/contact_repository.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:elms/utils/validator.dart' as validators;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  static Widget route() {
    return BlocProvider(
      create: (context) => SubmitContactCubit(ContactRepository()),
      child: const ContactUsScreen(),
    );
  }

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onTapSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<SubmitContactCubit>().submitContact(
        firstName: _firstNameController.text.trim(),
        email: _emailController.text.trim(),
        message: _messageController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLabels.contactUs.tr, showBackButton: true),
      body: BlocConsumer<SubmitContactCubit, SubmitContactState>(
        listener: (context, state) {
          if (state is SubmitContactSuccess) {
            UiUtils.showSnackBar(
              state.response['message'] ?? AppLabels.messageSentSuccessfully.tr,
            );
            // Clear form fields on success
            _firstNameController.clear();
            _emailController.clear();
            _messageController.clear();
            // Reset cubit state
            context.read<SubmitContactCubit>().reset();
          } else if (state is SubmitContactFail) {
            UiUtils.showSnackBar(UiUtils.friendlyErrorMessage(state.error), isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is SubmitContactInProgress;

          return SingleChildScrollView(
            padding: const .all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: .start,
                spacing: 20,
                children: [
                  CustomText(
                    AppLabels.contactUsDescription.tr,
                    style: TextStyle(
                      fontSize: context.font.small,
                      color: context.color.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: _firstNameController,
                    isRequired: true,
                    title: AppLabels.firstName.tr,
                    hintText: AppLabels.enterFirstName.tr,
                    fillColor: context.color.outline.withValues(alpha: .17),
                    enabled: !isLoading,
                    validator: validators.Validators.validateRequired,
                    requiredErrorMessage: AppLabels.firstNameRequired.tr,
                  ),
                  CustomTextFormField(
                    controller: _emailController,
                    isRequired: true,
                    title: AppLabels.email.tr,
                    hintText: AppLabels.enterEmail.tr,
                    fillColor: context.color.outline.withValues(alpha: .17),
                    enabled: !isLoading,
                    validator: validators.Validators.validateEmail,
                    requiredErrorMessage: AppLabels.emailRequired.tr,
                  ),
                  CustomTextFormField(
                    controller: _messageController,
                    isRequired: true,
                    title: AppLabels.message.tr,
                    minLines: 5,
                    isMultiline: true,
                    hintText: AppLabels.enterYourMessage.tr,
                    fillColor: context.color.outline.withValues(alpha: .17),
                    enabled: !isLoading,
                    validator: validators.Validators.validateRequired,
                    requiredErrorMessage: AppLabels.messageRequired.tr,
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    onPressed: isLoading ? null : _onTapSubmit,
                    title: isLoading
                        ? AppLabels.submitting.tr
                        : AppLabels.submit.tr,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
