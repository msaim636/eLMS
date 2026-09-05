import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/settings/cubit/app_settings_cubit.dart';
import 'package:elms/features/wallet/cubit/withdrawal_cubit.dart';
import 'package:elms/features/wallet/repository/wallet_repository.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/text_formatters.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:elms/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class WithdrawMoneyBottomSheet extends StatefulWidget {
  final VoidCallback? onWithdrawalSuccess;
  const WithdrawMoneyBottomSheet({super.key, this.onWithdrawalSuccess});

  static Widget create({VoidCallback? onWithdrawalSuccess}) {
    return BlocProvider(
      create: (context) => WithdrawalCubit(WalletRepository()),
      child: WithdrawMoneyBottomSheet(onWithdrawalSuccess: onWithdrawalSuccess),
    );
  }

  @override
  State<WithdrawMoneyBottomSheet> createState() =>
      _WithdrawMoneyBottomSheetState();
}

class _WithdrawMoneyBottomSheetState extends State<WithdrawMoneyBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _otherDetailsController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _otherDetailsController.dispose();
    super.dispose();
  }

  void _onTapCancel() {
    Get.back();
  }

  Future<void> _onTapSend() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await context.read<WithdrawalCubit>().submitWithdrawalRequest(
      amount: num.parse(_amountController.text.trim()),
      accountHolderName: _accountNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      bankName: _bankNameController.text.trim(),
      otherDetails: _otherDetailsController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WithdrawalCubit, WithdrawalState>(
      listener: (context, state) {
        if (state is WithdrawalSuccess) {
          Get.back();
          context.read<AuthenticationCubit>().refreshUserDetails();
          widget.onWithdrawalSuccess?.call();
          UiUtils.showSnackBar(AppLabels.withdrawalRequestSubmitted.tr);
        } else if (state is WithdrawalFail) {
          UiUtils.showSnackBar(
            UiUtils.friendlyErrorMessage(state.error),
            isError: true,
          );
        }
      },
      child: BlocBuilder<WithdrawalCubit, WithdrawalState>(
        builder: (context, state) {
          final isLoading = state is WithdrawalInProgress;

          return SingleChildScrollView(
            child: Padding(
              padding: const .all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  spacing: 16,
                  children: [
                    CustomText(
                      AppLabels.withdrawMoney.tr,
                      fontSize: context.font.large,
                      fontWeight: .w500,
                    ),
                    CustomTextFormField(
                      title: AppLabels.amount.tr,
                      controller: _amountController,
                      fillColor: context.color.outline.withValues(alpha: 0.4),
                      hintText:
                          '${context.read<AppSettingsCubit>().currencySymbol}2500',
                      inputType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      isRequired: true,
                      formatters: [DecimalFormatter()],
                      validator: Validators.validatePrice,
                      requiredErrorMessage: AppLabels.amountRequired.tr,
                    ),
                    CustomText(
                      AppLabels.bankDetails.tr,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.copyWith(fontWeight: .w600),
                    ),
                    CustomTextFormField(
                      title: AppLabels.accountName.tr,
                      controller: _accountNameController,
                      hintText: AppLabels.name.tr,
                      isRequired: true,
                      validator: Validators.validateName,
                      requiredErrorMessage: AppLabels.accountNameRequired.tr,
                    ),
                    CustomTextFormField(
                      title: AppLabels.accountNumber.tr,
                      controller: _accountNumberController,
                      hintText: 'eg.123456789',
                      isRequired: true,
                      validator: Validators.validateNumber,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      requiredErrorMessage: AppLabels.accountNumberRequired.tr,
                    ),
                    CustomTextFormField(
                      title: AppLabels.bankName.tr,
                      controller: _bankNameController,
                      hintText: AppLabels.bankName.tr,
                      isRequired: true,
                      validator: Validators.validateRequired,
                      requiredErrorMessage: AppLabels.bankNameRequired.tr,
                    ),
                    CustomTextFormField(
                      title: AppLabels.other.tr,
                      controller: _otherDetailsController,
                      hintText: AppLabels.enterAdditionalDetails.tr,
                      isRequired: true,
                      validator: Validators.validateRequired,
                      minLines: 3,
                      isMultiline: true,
                      inputType: TextInputType.multiline,
                      requiredErrorMessage:
                          AppLabels.additionalDetailsRequired.tr,
                    ),
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: CustomButton(
                            title: AppLabels.cancel.tr,
                            onPressed: _onTapCancel,
                            type: .outlined,
                          ),
                        ),
                        Expanded(
                          child: CustomButton(
                            title: AppLabels.send.tr,
                            onPressed: isLoading ? null : _onTapSend,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
