import 'package:flutter/services.dart';

class NoSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Check if the new value contains any spaces
    if (newValue.text.contains(' ')) {
      // If it does, return the old value
      return oldValue;
    }
    // Otherwise, return the new value
    return newValue;
  }
}

class DecimalFormatter extends TextInputFormatter {
  final int decimalPlaces;

  DecimalFormatter({this.decimalPlaces = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty value
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Check for valid decimal number format
    final regex = RegExp(r'^\d*\.?\d*$');
    if (!regex.hasMatch(newValue.text)) {
      return oldValue;
    }

    // Check if there's more than one decimal point
    if (newValue.text.split('.').length > 2) {
      return oldValue;
    }

    // Check decimal places limit
    if (newValue.text.contains('.')) {
      final parts = newValue.text.split('.');
      if (parts.length == 2 && parts[1].length > decimalPlaces) {
        return oldValue;
      }
    }

    return newValue;
  }
}
