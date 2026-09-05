// ignore_for_file: public_member_api_docs, sort_constructors_first
/// Model for withdrawal request payload
/// Contains the necessary fields to submit a withdrawal request
class WithdrawalRequestModel {
  final num amount;
  final String paymentMethod;
  final Map<String, String> paymentDetails;
  final String entryType;

  WithdrawalRequestModel({
    required this.amount,
    required this.paymentMethod,
    required this.paymentDetails,
    required this.entryType,
  });

  /// Converts the model to a Map for API submission
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_details[account_holder_name]':
          paymentDetails['account_holder_name'],
      'payment_details[account_number]': paymentDetails['account_number'],
      'payment_details[bank_name]': paymentDetails['bank_name'],
      'payment_details[other_details]': paymentDetails['other_details'],
      'entry_type': entryType,
    };
  }

  /// Factory constructor to create a withdrawal request with bank transfer
  factory WithdrawalRequestModel.bankTransfer({
    required num amount,
    required String accountHolderName,
    required String accountNumber,
    required String bankName,
    required String otherDetails,
  }) {
    return WithdrawalRequestModel(
      amount: amount,
      paymentMethod: 'bank_transfer',
      paymentDetails: {
        'account_holder_name': accountHolderName,
        'account_number': accountNumber,
        'bank_name': bankName,
        'other_details': otherDetails,
      },
      entryType: 'user',
    );
  }

  @override
  String toString() {
    return 'WithdrawalRequestModel(amount: $amount, paymentMethod: $paymentMethod, paymentDetails: $paymentDetails, entryType: $entryType)';
  }
}
