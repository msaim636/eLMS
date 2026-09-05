import 'package:country_code_picker/country_code_picker.dart';
import 'package:elms/core/configs/app_settings.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:phone_numbers_parser/metadata.dart';

enum AdaptiveFieldMode { email, number }

class AdaptiveAuthField extends StatefulWidget {
  final String? title;
  final String? hintText;
  final bool isRequired;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final Function(AdaptiveFieldMode mode)? onChangedMode;
  final Function(CountryCode? code)? onChangedCountryCode;
  final bool enabled;
  final CountryCode? countryCallingCode;

  ///This field is to fix the field to specific type
  final AdaptiveFieldMode? fixedFieldType;

  const AdaptiveAuthField({
    super.key,
    this.title,
    this.hintText,
    this.fixedFieldType,
    this.isRequired = false,
    this.onChanged,
    this.controller,
    this.onChangedMode,
    this.onChangedCountryCode,
    this.enabled = true,
    this.countryCallingCode,
  });

  @override
  State<AdaptiveAuthField> createState() => _AdaptiveAuthFieldState();
}

class _AdaptiveAuthFieldState extends State<AdaptiveAuthField> {
  late bool isPhoneMode = widget.fixedFieldType != null
      ? widget.fixedFieldType == AdaptiveFieldMode.number
      : false;
  late CountryCode? selectedCountryCode =
      widget.countryCallingCode ?? Utils.simCountry ?? _loadDefaultDialCode();
  late final TextEditingController _controller;
  String _lastValue = '';

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    super.initState();
  }

  CountryCode? _loadDefaultDialCode() {
    try {
      return CountryCode.fromDialCode(AppSettings.defaultDialCode.toString());
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final String text = _controller.text;

    if (widget.fixedFieldType != null) {
      isPhoneMode = widget.fixedFieldType == AdaptiveFieldMode.number;

      if (_controller.text == _lastValue) return;
      _lastValue = _controller.text;

      setState(() {});
      widget.onChanged?.call(text);
      return;
    }

    // Check if the input is a valid phone number format
    bool newIsPhoneMode =
        text.startsWith('+') || RegExp(r'^[0-9]+$').hasMatch(text);

    if (text.isEmpty) {
      newIsPhoneMode = true;
    }
    if (newIsPhoneMode != isPhoneMode) {
      setState(() {
        isPhoneMode = newIsPhoneMode;
        widget.onChangedMode?.call(
          isPhoneMode ? AdaptiveFieldMode.number : AdaptiveFieldMode.email,
        );
      });
    }

    widget.onChanged?.call(text);
  }

  void _onCountryCodeSelection(CountryCode? code) {
    widget.onChangedCountryCode?.call(code);

    // Debug: print required phone number lengths for selected country
    if (code?.code != null) {
      try {
        final isoCode = IsoCode.values.byName(code!.code!);
        final lengths = metadataLenghtsByIsoCode[isoCode]!;
        debugPrint(
          '📞 ${code.name} (${code.code}) — '
          'General: ${lengths.general}, Mobile: ${lengths.mobile}, '
          'FixedLine: ${lengths.fixedLine}',
        );
      } catch (_) {}
    }

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            selectedCountryCode = code;
          });
        }
      });
    }
  }

  OutlineInputBorder getBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: color ?? context.color.outline),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        if (widget.title != null) ...{
          Text.rich(
            TextSpan(
              text: widget.title!,
              style: TextStyle(
                fontSize: context.font.small,
                fontWeight: FontWeight.w500,
              ),
              children: [
                if (widget.isRequired)
                  TextSpan(
                    text: '*',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        },
        TextFormField(
          autovalidateMode: .onUserInteraction,
          controller: _controller,
          enabled: widget.enabled,
          keyboardType: isPhoneMode
              ? TextInputType.number
              : TextInputType.emailAddress,
          inputFormatters: isPhoneMode
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.color.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isPhoneMode ? 0 : 12,
              vertical: 13,
            ),
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.color.onSurface.withValues(alpha: 0.6),
            ),
            disabledBorder: getBorder(),
            enabledBorder: getBorder(),
            focusedBorder: getBorder(color: context.color.primary),
            errorBorder: getBorder(color: context.color.error),
            focusedErrorBorder: getBorder(color: context.color.error),
            prefixIcon: isPhoneMode
                ? Container(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    margin: const EdgeInsetsDirectional.only(end: 8, start: 7),
                    decoration: BoxDecoration(
                      border: BorderDirectional(
                        end: BorderSide(color: context.color.outline),
                      ),
                    ),
                    child: Localizations.override(
                      context: context,
                      locale: const Locale('en'),
                      child: CountryCodePicker(
                        onChanged: _onCountryCodeSelection,
                        onInit: _onCountryCodeSelection,
                        initialSelection: selectedCountryCode?.code,
                        backgroundColor: context.color.surface,
                        dialogBackgroundColor: context.color.surface,
                        barrierColor: Colors.black.withValues(alpha: 0.5),
                        dialogTextStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: context.color.onSurface),
                        searchDecoration: InputDecoration(
                          filled: true,
                          fillColor: context.color.surface,
                          hintText: AppLabels.search.tr,
                          hintStyle: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: context.color.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                          border: getBorder(),
                          enabledBorder: getBorder(),
                          focusedBorder: getBorder(
                            color: context.color.primary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: context.color.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        searchStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: context.color.onSurface),
                        textStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: context.color.onSurface),
                        closeIcon: Icon(
                          Icons.close,
                          color: context.color.onSurface,
                        ),
                        builder: (CountryCode? countryCode) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomImage(
                                countryCode?.flagUri ?? '',
                                width: 34,
                                height: 24,
                                package: 'country_code_picker',
                              ),
                              const SizedBox(width: 4),
                              Text(
                                countryCode?.dialCode ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: context.color.onSurface,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  )
                : null,
          ),
          validator: (value) {
            if (widget.isRequired && (value?.isEmpty ?? true)) {
              return isPhoneMode
                  ? AppLabels.phoneNumberRequired.tr
                  : AppLabels.emailRequired.tr;
            }
            if (isPhoneMode && value != null && value.isNotEmpty) {
              try {
                final isoCode = IsoCode.values.byName(
                  selectedCountryCode?.code ?? 'US',
                );
                final phone = PhoneNumber.parse(
                  value,
                  callerCountry: isoCode,
                );
                if (!phone.isValidLength()) {
                  return AppLabels.enterValidPhoneNumber.tr;
                }
              } catch (_) {
                return AppLabels.enterValidPhoneNumber.tr;
              }
            } else if (!isPhoneMode && value != null && value.isNotEmpty) {
              if (!RegExp(
                r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
              ).hasMatch(value)) {
                return AppLabels.enterValidEmailAddress.tr;
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
