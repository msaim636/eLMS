import 'package:country_code_picker/country_code_picker.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:flutter_country_state/flutter_country_state.dart';
import 'package:flutter_country_state/select_state.dart';
import 'package:flutter_country_state/state-list.dart';
import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_country_picker_field.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/cart/cubit/billing_details_cubit.dart';
import 'package:elms/features/cart/models/billing_details_model.dart';
import 'package:elms/features/cart/repository/billing_details_repository.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class BillingDetailsScreen extends StatefulWidget {
  const BillingDetailsScreen({super.key});

  static Widget route() => BlocProvider(
    create: (context) =>
        BillingDetailsCubit(BillingDetailsRepository())..fetch(),
    child: const BillingDetailsScreen(),
  );

  @override
  State<BillingDetailsScreen> createState() => _BillingDetailsScreenState();
}

class _BillingDetailsScreenState extends State<BillingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _taxIdController = TextEditingController();
  CountryCode? _selectedCountry;
  String? _selectedStateName;
  bool _isEditMode = false;
  bool _hasPrefilledData = false;

  @override
  void initState() {
    super.initState();
    // Check if data is already loaded in the cubit and prefill immediately
    final state = context.read<BillingDetailsCubit>().state;
    if (state is BillingDetailsSuccess && state.billingDetails != null) {
      _prefillData(state.billingDetails!);
    }
  }

  void _prefillData(BillingDetailsModel billingDetails) {
    if (_hasPrefilledData) return;
    _firstNameController.text = billingDetails.firstName;
    _lastNameController.text = billingDetails.lastName;
    // Try to find matching country by code
    if (billingDetails.countryCode.isNotEmpty) {
      _selectedCountry = CountryCode.fromCountryCode(
        billingDetails.countryCode,
      );
      // Set Selected.country for flutter_country_state package
      Selected.country = _selectedCountry?.name ?? '';
      // Load states for the selected country
      stateFunction().stateList();
    }
    _addressController.text = billingDetails.address;
    _cityController.text = billingDetails.city;
    // Prefill state
    if (billingDetails.state.isNotEmpty) {
      _selectedStateName = billingDetails.state;
      _stateController.text = billingDetails.state;
      Selected.state = billingDetails.state;
    }
    _zipController.text = billingDetails.postalCode ?? '';
    _taxIdController.text = billingDetails.taxId ?? '';
    _isEditMode = true;
    _hasPrefilledData = true;
  }

  void _onCountryChanged(CountryCode code) {
    if (!mounted) return;
    setState(() {
      _selectedCountry = code;
      // Set Selected.country for flutter_country_state package
      Selected.country = code.name ?? '';
      // Load states for the selected country
      stateFunction().stateList();
      // Reset state when country changes
      _selectedStateName = null;
      _stateController.clear();
      Selected.state = '';
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }

  void _onTapSaveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      final BillingDetailsCubit cubit = context.read<BillingDetailsCubit>();
      // Use selected state name if available, otherwise use text controller
      final stateName = _selectedStateName?.isNotEmpty == true
          ? _selectedStateName!
          : _stateController.text;

      if (_isEditMode) {
        cubit.update(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          countryCode: _selectedCountry?.code ?? '',
          address: _addressController.text,
          city: _cityController.text,
          state: stateName,
          postalCode: _zipController.text.isEmpty ? null : _zipController.text,
          taxId: _taxIdController.text.isEmpty ? null : _taxIdController.text,
        );
      } else {
        cubit.create(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          countryCode: _selectedCountry?.code ?? '',
          address: _addressController.text,
          city: _cityController.text,
          state: stateName,
          postalCode: _zipController.text.isEmpty ? null : _zipController.text,
          taxId: _taxIdController.text.isEmpty ? null : _taxIdController.text,
        );
      }
    }
  }

  void _showStatePicker() {
    if (_selectedCountry == null || Selected.country.isEmpty) {
      UiUtils.showSnackBar(
        AppLabels.pleaseSelectCountryFirst.tr,
        isError: true,
      );
      return;
    }

    // Ensure states are loaded for the selected country
    stateFunction().stateList();
    final List<String> states = List<String>.from(StateDialogs.stateItems);
    String searchQuery = '';

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredStates = states
              .where(
                (state) =>
                    state.toLowerCase().contains(searchQuery.toLowerCase()),
              )
              .toList();

          return Dialog(
            backgroundColor: context.color.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  // Header with close button
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        Flexible(
                          child: CustomText(
                            AppLabels.selectStateProvinceRegion.tr,
                            maxLines: 1,
                            ellipsis: true,
                            fontSize: context.font.medium,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: context.color.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Search field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                        });
                      },
                      style: TextStyle(
                        fontSize: context.font.small,
                        color: context.color.onSurface,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: context.color.surface,
                        hintText: AppLabels.search.tr,
                        hintStyle: TextStyle(
                          fontSize: context.font.small,
                        ).copyWith(color: context.color.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: context.color.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: context.color.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: context.color.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: context.color.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // State list
                  Expanded(
                    child: filteredStates.isEmpty
                        ? Center(
                            child: Text(
                              AppLabels.noResultsFound.tr,
                              style: TextStyle(
                                fontSize: context.font.small,
                              ).copyWith(color: context.color.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredStates.length,
                            itemBuilder: (context, index) {
                              final stateName = filteredStates[index];
                              final isSelected =
                                  stateName == _selectedStateName;

                              return ListTile(
                                title: Text(
                                  stateName,
                                  style: TextStyle(fontSize: context.font.small)
                                      .copyWith(
                                        color: context.color.onSurface,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                ),
                                tileColor: isSelected
                                    ? context.color.primaryContainer
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedStateName = stateName;
                                    _stateController.text = stateName;
                                    Selected.state = stateName;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStateField() {
    // Show state picker if country is selected
    if (_selectedCountry != null) {
      return GestureDetector(
        onTap: _showStatePicker,
        child: AbsorbPointer(
          child: CustomTextFormField(
            controller: _stateController,
            title: AppLabels.stateProvinceRegion.tr,
            hintText: AppLabels.selectStateProvinceRegion.tr,
            isRequired: true,
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: context.color.onSurface,
            ),
            requiredErrorMessage: AppLabels.stateRequired.tr,
          ),
        ),
      );
    }

    // Fallback to text input if no country selected yet
    return CustomTextFormField(
      controller: _stateController,
      title: AppLabels.stateProvinceRegion.tr,
      hintText: AppLabels.enterStateProvinceRegion.tr,
      isRequired: true,
      requiredErrorMessage: AppLabels.stateRequired.tr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillingDetailsCubit, BillingDetailsState>(
      listener: (context, state) {
        if (state is BillingDetailsSuccess) {
          if (state.type == BillingDetails.patch ||
              state.type == BillingDetails.post) {
            UiUtils.showSnackBar(
              _isEditMode
                  ? AppLabels.billingDetailsUpdatedSuccessfully.tr
                  : AppLabels.billingDetailsCreatedSuccessfully.tr,
            );

            Navigator.pop(context, 'trigger-fetch');
            return;
          }

          if (state.billingDetails != null && !_hasPrefilledData) {
            _prefillData(state.billingDetails!);
          } else if (_hasPrefilledData) {
            Get.back(result: true);
          }
        } else if (state is BillingDetailsFail) {
          UiUtils.showSnackBar(UiUtils.friendlyErrorMessage(state.error), isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: context.color.surfaceContainer,
        appBar: CustomAppBar(
          title: AppLabels.billingDetails.tr,
          showBackButton: true,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.color.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: context.color.outline),
              ),
              child: Column(
                children: [
                  CustomTextFormField(
                    controller: _firstNameController,
                    title: AppLabels.firstName.tr,
                    hintText: AppLabels.enterFirstName.tr,
                    isRequired: true,
                    requiredErrorMessage: AppLabels.firstNameRequired.tr,
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    controller: _lastNameController,
                    title: AppLabels.lastName.tr,
                    hintText: AppLabels.enterLastName.tr,
                    isRequired: true,
                    requiredErrorMessage: AppLabels.lastNameRequired.tr,
                  ),
                  const SizedBox(height: 12),
                  CustomCountryPickerField(
                    isRequired: true,
                    initialSelection: _selectedCountry,
                    onChanged: _onCountryChanged,
                    validator: (value) {
                      if (_selectedCountry == null) {
                        return AppLabels.countryRequired.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    controller: _addressController,
                    title: AppLabels.address.tr,
                    hintText: AppLabels.enterAddress.tr,
                    isRequired: true,
                    requiredErrorMessage: AppLabels.addressRequired.tr,
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    controller: _cityController,
                    title: AppLabels.city.tr,
                    hintText: AppLabels.enterCity.tr,
                    isRequired: true,
                    requiredErrorMessage: AppLabels.cityRequired.tr,
                  ),
                  const SizedBox(height: 12),
                  _buildStateField(),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    controller: _zipController,
                    title: AppLabels.zipPostalCode.tr,
                    hintText: AppLabels.enterZipPostalCode.tr,
                    requiredErrorMessage: AppLabels.fieldRequired.tr,
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    controller: _taxIdController,
                    title: AppLabels.taxId.tr,
                    hintText: AppLabels.enterTaxId.tr,
                    requiredErrorMessage: AppLabels.fieldRequired.tr,
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<BillingDetailsCubit, BillingDetailsState>(
                    builder: (context, state) {
                      final bool isLoading =
                          state is BillingDetailsCreateInProgress ||
                          state is BillingDetailsUpdateInProgress;
                      return CustomButton(
                        title: AppLabels.saveAndContinue.tr,
                        onPressed: isLoading ? null : _onTapSaveAndContinue,
                        fullWidth: true,
                        height: 40,
                        radius: 4,
                        isLoading: isLoading,
                      );
                    },
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
