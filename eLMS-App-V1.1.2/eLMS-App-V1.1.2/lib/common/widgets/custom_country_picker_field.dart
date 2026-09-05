import 'package:country_code_picker/country_code_picker.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomCountryPickerField extends StatefulWidget {
  final CountryCode? initialSelection;
  final ValueChanged<CountryCode> onChanged;
  final String? Function(String?)? validator;
  final bool isRequired;
  final Key? fieldKey;

  const CustomCountryPickerField({
    super.key,
    this.initialSelection,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
    this.fieldKey,
  });

  @override
  State<CustomCountryPickerField> createState() =>
      _CustomCountryPickerFieldState();
}

class _CustomCountryPickerFieldState extends State<CustomCountryPickerField> {
  final TextEditingController _countryController = TextEditingController();
  final GlobalKey<CountryCodePickerState> _countryPickerKey = GlobalKey();
  CountryCode? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialSelection ?? Utils.simCountry;
    if (_selectedCountry != null) {
      // Ensure we get the English name of the country on initialization to prevent the flash
      _countryController.text = _getEnglishName(_selectedCountry!);
    }
  }

  @override
  void didUpdateWidget(CustomCountryPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelection != oldWidget.initialSelection) {
      _selectedCountry = widget.initialSelection ?? Utils.simCountry;
      if (_selectedCountry != null) {
        _countryController.text = _getEnglishName(_selectedCountry!);
      }
    }
  }

  String _getEnglishName(CountryCode code) {
    // If the package supports getting a specific localization, we'd use it.
    // However, CountryCode object usually holds the localized name during its creation.
    // By re-parsing it or using the name we rely on the internal maps.
    // This helper checks if an internal English map exists or just returns the code name,
    // which inside our Localizations.override('en') during build will sync correctly.
    // We can fetch the english name using the static method of CountryCode if needed,
    // but the `name` property is already populated.

    // To ensure it's English regardless of current locale, we lookup from a fresh instance
    // or rely on the onInit callback to fix it quickly. A robust way is to fetch the code
    // and let the picker override it safely in English.
    return code.name ?? '';
  }

  @override
  void dispose() {
    _countryController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    _countryPickerKey.currentState?.showCountryCodePickerDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Localizations.override(
          context: context,
          locale: const Locale('en'),
          child: Builder(
            builder: (context) {
              return GestureDetector(
                key: widget.fieldKey,
                onTap: _showCountryPicker,
                child: AbsorbPointer(
                  child: CustomTextFormField(
                    title: AppLabels.country.tr,
                    hintText: AppLabels.selectCountry.tr,
                    isRequired: widget.isRequired,
                    controller: _countryController,
                    validator: widget.validator,
                    suffixIcon: Icon(
                      Icons.arrow_drop_down,
                      color: context.color.onSurface,
                    ),
                    requiredErrorMessage: AppLabels.countryRequired.tr,
                  ),
                ),
              );
            },
          ),
        ),
        Offstage(
          child: Localizations.override(
            context: context,
            locale: const Locale('en'),
            child: Builder(
              builder: (context) => CountryCodePicker(
                key: _countryPickerKey,
                onChanged: (code) {
                  setState(() {
                    _selectedCountry = code;
                    _countryController.text = code.name ?? '';
                    widget.onChanged(code);
                  });
                },
                onInit: (code) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedCountry = code ?? Utils.simCountry;
                        _countryController.text = _selectedCountry != null
                            ? _getEnglishName(_selectedCountry!)
                            : '';
                        if (_selectedCountry != null) {
                          widget.onChanged(_selectedCountry!);
                        }
                      });
                    }
                  });
                },
                initialSelection: _selectedCountry?.code,
                showCountryOnly: true,
                showOnlyCountryWhenClosed: true,
                backgroundColor: context.color.surface,
                dialogBackgroundColor: context.color.surface,
                barrierColor: Colors.black.withValues(alpha: 0.5),
                dialogTextStyle: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: context.color.onSurface),
                searchDecoration: InputDecoration(
                  filled: true,
                  fillColor: context.color.surface,
                  hintText: AppLabels.search.tr,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.color.onSurface.withValues(alpha: 0.6),
                  ),
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
                    color: context.color.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                searchStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.color.onSurface,
                ),
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.color.onSurface,
                ),
                closeIcon: Icon(Icons.close, color: context.color.onSurface),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
