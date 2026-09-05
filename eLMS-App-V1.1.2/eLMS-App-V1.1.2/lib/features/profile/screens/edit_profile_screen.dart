import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_country_picker_field.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/core/login/phone_password_login.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:elms/features/authentication/widgets/adaptive_auth_field.dart';
import 'package:elms/features/profile/cubits/edit_profile_cubit.dart';
import 'package:elms/features/profile/widgets/profile_image_widget.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static Widget route() {
    return BlocProvider(
      create: (context) => EditProfileCubit(AuthRepository()),
      child: const EditProfileScreen(),
    );
  }

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final PhoneNumber phone = PhoneNumber.lazy();
  File? profile;
  String? currentProfileImage;
  bool isEmailDisabled = false;
  bool isPhoneDisabled = false;
  CountryCode? _selectedCountry;
  CountryCode? selectedCountryCallingCode;
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  void _prefillUserData() {
    final authState = context.read<AuthenticationCubit>().state;
    if (authState is Authenticated && authState.user != null) {
      final user = authState.user!;

      // Prefill text fields
      _nameController.text = user.name;
      _emailController.text = user.email ?? '';

      // Prefill phone number if available
      if (user.mobile != null && user.mobile!.isNotEmpty) {
        _phoneController.text = user.mobile!;
        phone.setNumber(user.mobile!);

        // Prefill country calling code if available
        if (user.countryCallingCode != null &&
            user.countryCallingCode!.isNotEmpty) {
          phone.setCountryCallingCode(user.countryCallingCode!);
        }
      }

      // Prefill country if available
      if (user.countryCode != null && user.countryCode!.isNotEmpty) {
        _selectedCountry = CountryCode.fromCountryCode(user.countryCode!);
      }
      if (user.countryCallingCode != null &&
          user.countryCallingCode!.isNotEmpty) {
        selectedCountryCallingCode = CountryCode.fromDialCode(
          user.countryCallingCode!,
        );
        phone.setCountryCallingCode(selectedCountryCallingCode!.dialCode!);
      }

      // Store current profile image
      currentProfileImage = user.profile;

      // Determine which field should be disabled based on login method
      _determineDisabledFields(user.type);
    }
  }

  /// Determines which fields should be disabled based on the user's login type
  void _determineDisabledFields(String? loginType) {
    if (loginType == null) return;

    final String type = loginType.toLowerCase();

    // Disable email field if user logged in with email-based methods
    if (type == 'email' || type == 'google' || type == 'apple') {
      isEmailDisabled = true;
      isPhoneDisabled = false;
    }
    // Disable phone field if user logged in with phone
    else if (type == 'phone' || type == 'mobile') {
      isPhoneDisabled = true;
      isEmailDisabled = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLabels.editProfile.tr,
        showBackButton: true,
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const .symmetric(horizontal: 16, vertical: 8),
        height: kBottomNavigationBarHeight,
        child: CustomButton(
          title: AppLabels.saveChanges.tr,
          onPressed: () {
            ///In demo mode profile editing is disabled.
            if (AppConstant.kIsDemoMode) {
              UiUtils.showSnackBar(
                AppLabels.demoModeRestriction.tr,
                isError: true,
              );
              return;
            }
            if (_formKey.currentState?.validate() ?? false) {
              context.read<EditProfileCubit>().edit(
                email: _emailController.text,
                name: _nameController.text,
                phone: phone,
                profile: profile,
                country: _selectedCountry?.code,
              );
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: BlocListener<EditProfileCubit, EditProfileState>(
          listener: (context, state) {
            if (state is EditProfileSuccess) {
              context.read<AuthenticationCubit>().changeUserDetails(state.user);
              UiUtils.showSnackBar(AppLabels.updatedSuccessfully.tr);
            }
            if (state is EditProfileFail) {
              // Handle CustomException with toast enabled
              if (state.error is CustomException) {
                final CustomException exception =
                    state.error as CustomException;
                if (exception.toast) {
                  UiUtils.showSnackBar(exception.message ?? '', isError: true);
                }
              }
            }
          },
          child: Padding(
            padding: const .all(16.0),
            child: Column(
              children: [
                Center(
                  child: ProfileImageWidget(
                    image: currentProfileImage ?? '',
                    onSelected: (file) {
                      profile = file;
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 27),
                _buildForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 8,
        children: [
          CustomTextFormField(
            key: const ValueKey('edit_profile_name'),
            title: AppLabels.fullName.tr,
            hintText: AppLabels.enterName.tr,
            controller: _nameController,
            isRequired: true,
            requiredErrorMessage: AppLabels.nameRequired.tr,
          ),
          CustomTextFormField(
            key: const ValueKey('edit_profile_email'),
            title: AppLabels.email.tr,
            hintText: AppLabels.enterEmail.tr,
            controller: _emailController,
            enabled: !isEmailDisabled,
            hintColor: context.color.onSurface.withValues(alpha: 0.5),
            requiredErrorMessage: AppLabels.emailRequired.tr,
          ),
          AdaptiveAuthField(
            key: const ValueKey('edit_profile_phone'),
            title: AppLabels.phoneNumber.tr,
            fixedFieldType: AdaptiveFieldMode.number,
            hintText: '123456789',
            controller: _phoneController,
            enabled: !isPhoneDisabled,
            countryCallingCode: selectedCountryCallingCode,
            onChangedCountryCode: (code) {
              phone.setCountryCallingCode(code!.dialCode!);
            },
            onChanged: (String number) {
              phone.setNumber(number);
            },
          ),
          CustomCountryPickerField(
            key: const ValueKey('edit_profile_country'),
            initialSelection: _selectedCountry,
            onChanged: (code) {
              setState(() {
                _selectedCountry = code;
              });
            },
          ),
        ],
      ),
    );
  }
}
