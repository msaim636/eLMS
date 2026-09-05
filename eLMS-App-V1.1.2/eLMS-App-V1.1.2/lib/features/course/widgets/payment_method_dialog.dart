import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_dialog_box.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/settings/cubit/app_settings_cubit.dart';
import 'package:elms/features/settings/cubit/settings_state.dart';
import 'package:elms/features/settings/models/app_setting_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class PaymentMethodDialog extends StatefulWidget {
  final Function(String paymentMethod) onPaymentMethodSelected;
  final num totalAmount;

  const PaymentMethodDialog({
    super.key,
    required this.onPaymentMethodSelected,
    required this.totalAmount,
  });

  static Future<void> show({
    required BuildContext context,
    required Function(String paymentMethod) onPaymentMethodSelected,
    required num totalAmount,
  }) {
    return showDialog(
      context: context,
      builder: (context) => PaymentMethodDialog(
        onPaymentMethodSelected: onPaymentMethodSelected,
        totalAmount: totalAmount,
      ),
    );
  }

  @override
  State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  String? _selectedPaymentMethod;

  List<PaymentSettingModel> _getActivePaymentMethods() {
    if (Platform.isIOS) return [];

    final settingsState = context.read<AppSettingsCubit>().state;
    if (settingsState is SettingsSuccess) {
      return settingsState.settings.activePaymentSettings ?? [];
    }
    return [];
  }

  String _getPaymentGatewayDisplayName(String gateway) {
    switch (gateway.toLowerCase()) {
      case 'stripe':
        return 'Stripe';
      case 'paypal':
        return 'Paypal';
      case 'razorpay':
        return 'Razorpay';
      default:
        // Capitalize first letter of gateway name
        if (gateway.isEmpty) return gateway;
        return gateway[0].toUpperCase() + gateway.substring(1).toLowerCase();
    }
  }

  @override
  void initState() {
    super.initState();

    // Check if wallet has sufficient balance and set it as default
    final userTotalBalance =
        context.read<AuthenticationCubit>().totalBalance ?? 0;
    if (userTotalBalance >= widget.totalAmount) {
      _selectedPaymentMethod = 'wallet';
      return;
    }

    // Otherwise, use the first active payment method
    final activePaymentMethods = _getActivePaymentMethods();
    if (activePaymentMethods.isNotEmpty) {
      _selectedPaymentMethod = activePaymentMethods.first.paymentGateway;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePaymentMethods = _getActivePaymentMethods();

    return CustomDialogBox(
      title: AppLabels.selectPaymentMethod.tr,
      content: _buildPaymentMethodsList(activePaymentMethods),
      actions: [
        DialogButton(
          title: AppLabels.cancel.tr,
          onTap: () {
            Navigator.pop(context);
          },
          color: context.color.primary,
          style: DialogButtonStyle.outlined,
        ),
        DialogButton(
          title: AppLabels.proceed.tr,
          onTap: _selectedPaymentMethod != null
              ? () {
                  Navigator.pop(context);
                  widget.onPaymentMethodSelected(_selectedPaymentMethod!);
                }
              : null,
          color: context.color.primary,
          style: DialogButtonStyle.primary,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsList(List<PaymentSettingModel> methods) {
    return Column(
      mainAxisSize: .min,
      children: [
        // Wallet payment option (always at index 0)
        _buildWalletPaymentTile(),
        // Other payment methods
        ...methods.map((method) {
          return _buildPaymentMethodTile(method);
        }),
      ],
    );
  }

  Widget _buildPaymentMethodTile(PaymentSettingModel method) {
    final paymentGateway = method.paymentGateway ?? '';
    final isSelected = _selectedPaymentMethod == paymentGateway;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = paymentGateway;
        });
      },
      child: Container(
        padding: const .symmetric(horizontal: 12, vertical: 16),
        margin: const .only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.color.primary.withValues(alpha: 0.1)
              : context.color.surface,
          border: Border.all(
            color: isSelected
                ? context.color.primary
                : context.color.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? context.color.primary
                  : context.color.textSecondary,
            ),
            const SizedBox(width: 12),
            CustomText(
              _getPaymentGatewayDisplayName(paymentGateway),
              style: TextStyle(
                fontSize: context.font.medium,
                fontWeight: isSelected ? .w600 : .w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletPaymentTile() {
    final userTotalBalance =
        context.read<AuthenticationCubit>().totalBalance ?? 0;
    final isEnabled = userTotalBalance >= widget.totalAmount;
    const String walletValue = 'wallet';
    final isSelected = _selectedPaymentMethod == walletValue;

    return InkWell(
      onTap: isEnabled
          ? () {
              setState(() {
                _selectedPaymentMethod = walletValue;
              });
            }
          : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          padding: const .symmetric(horizontal: 12, vertical: 16),
          margin: const .only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? context.color.primary.withValues(alpha: 0.1)
                : context.color.surface,
            border: Border.all(
              color: isSelected
                  ? context.color.primary
                  : context.color.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isSelected && isEnabled
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isEnabled
                    ? (isSelected
                          ? context.color.primary
                          : context.color.textSecondary)
                    : context.color.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomText(
                  '${AppLabels.wallet.tr} (${userTotalBalance.toStringAsFixed(2).currency})',
                  style: TextStyle(
                    fontSize: context.font.medium,
                    fontWeight: isSelected ? .w600 : .w400,
                    color: isEnabled
                        ? context.color.onSurface
                        : context.color.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
