import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class PaymentDetails {
  final String? accountHolderName;
  final String? accountNumber;
  final String? bankName;
  final String? otherDetails;

  PaymentDetails({
    this.accountHolderName,
    this.accountNumber,
    this.bankName,
    this.otherDetails,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      accountHolderName: json.optional<String>('account_holder_name'),
      accountNumber: json.optional<String>('account_number'),
      bankName: json.optional<String>('bank_name'),
      otherDetails: json.optional<String>('other_details'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_holder_name': accountHolderName,
      'account_number': accountNumber,
      'bank_name': bankName,
      'otherDetails': otherDetails,
    };
  }
}

class WalletTransactionModel extends Model {
  final int? id;
  final int? userId;
  final num? amount;
  final String? type;
  final String? transactionType;
  final String? entryType;
  final String? referenceId;
  final String? referenceType;
  final String? description;
  final num? balanceBefore;
  final num? balanceAfter;
  final String? createdAt;
  final String? updatedAt;
  final String? courseName;
  final String? transactionId;
  final String? transactionDate;
  final String? status;
  final String? paymentMethod;
  final PaymentDetails? paymentDetails;
  final String? typeLabel;
  final String? transactionTypeLabel;
  final String? createdAtFormatted;
  final String? timeAgo;
  final String? orderNumber;
  final WalletTransactionReference? reference;

  WalletTransactionModel({
    this.id,
    this.userId,
    this.amount,
    this.type,
    this.transactionType,
    this.entryType,
    this.referenceId,
    this.referenceType,
    this.description,
    this.balanceBefore,
    this.balanceAfter,
    this.createdAt,
    this.updatedAt,
    this.courseName,
    this.transactionId,
    this.transactionDate,
    this.status,
    this.paymentMethod,
    this.paymentDetails,
    this.typeLabel,
    this.transactionTypeLabel,
    this.createdAtFormatted,
    this.timeAgo,
    this.reference,
    this.orderNumber,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json.optional<int>('id'),
      userId: json.optional<int>('user_id'),
      amount: json.optional<num>('amount'),
      type: json.optional<String>('type'),
      transactionType: json.optional<String>('transaction_type'),
      entryType: json.optional<String>('entry_type'),
      referenceId: json.optional<String>('reference_id'),
      referenceType: json.optional<String>('reference_type'),
      description: json.optional<String>('description'),
      balanceBefore: json.optional<num>('balance_before'),
      balanceAfter: json.optional<num>('balance_after'),
      createdAt: json.optional<String>('created_at'),
      updatedAt: json.optional<String>('updated_at'),
      courseName: json.optional<String>('course_name'),
      transactionId: json.optional<String>('transaction_id'),
      transactionDate: json.optional<String>('transaction_date'),
      status: json.optional<String>('status'),
      paymentMethod: json.optional<String>('payment_method'),
      orderNumber: json.optional<String>('order_number'),
      paymentDetails:
          json.optional<Map<String, dynamic>>('payment_details') != null
          ? PaymentDetails.fromJson(
              json.require<Map<String, dynamic>>('payment_details'),
            )
          : null,
      typeLabel: json.optional<String>('type_label'),
      transactionTypeLabel: json.optional<String>('transaction_type_label'),
      createdAtFormatted: json.optional<String>('created_at_formatted'),
      timeAgo: json.optional<String>('time_ago'),
      reference: json.optional<Map<String, dynamic>>('reference') != null
          ? WalletTransactionReference.fromJson(
              json.require<Map<String, dynamic>>('reference'),
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'transaction_type': transactionType,
      'entry_type': entryType,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'description': description,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'course_name': courseName,
      'transaction_id': transactionId,
      'transaction_date': transactionDate,
      'status': status,
      'payment_method': paymentMethod,
      'payment_details': paymentDetails?.toJson(),
      'type_label': typeLabel,
      'transaction_type_label': transactionTypeLabel,
      'created_at_formatted': createdAtFormatted,
      'time_ago': timeAgo,
      'reference': reference?.toJson(),
    };
  }
}

class WalletTransactionReference {
  final int? id;
  final int? userId;
  final int? courseId;
  final int? transactionId;
  final num? refundAmount;
  final String? status;
  final String? reason;
  final String? userMedia;
  final String? adminNotes;
  final String? adminReceipt;
  final String? purchaseDate;
  final String? requestDate;
  final String? processedAt;
  final int? processedBy;
  final String? createdAt;
  final String? updatedAt;
  final CourseModel? course;

  WalletTransactionReference({
    this.id,
    this.userId,
    this.courseId,
    this.transactionId,
    this.refundAmount,
    this.status,
    this.reason,
    this.userMedia,
    this.adminNotes,
    this.adminReceipt,
    this.purchaseDate,
    this.requestDate,
    this.processedAt,
    this.processedBy,
    this.createdAt,
    this.updatedAt,
    this.course,
  });

  factory WalletTransactionReference.fromJson(Map<String, dynamic> json) {
    return WalletTransactionReference(
      id: json.optional<int>('id'),
      userId: json.optional<int>('user_id'),
      courseId: json.optional<int>('course_id'),
      transactionId: json.optional<int>('transaction_id'),
      refundAmount: json.optional<num>('refund_amount'),
      status: json.optional<String>('status'),
      reason: json.optional<String>('reason'),
      userMedia: json.optional<String>('user_media'),
      adminNotes: json.optional<String>('admin_notes'),
      adminReceipt: json.optional<String>('admin_receipt'),
      purchaseDate: json.optional<String>('purchase_date'),
      requestDate: json.optional<String>('request_date'),
      processedAt: json.optional<String>('processed_at'),
      processedBy: json.optional<int>('processed_by'),
      createdAt: json.optional<String>('created_at'),
      updatedAt: json.optional<String>('updated_at'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'transaction_id': transactionId,
      'refund_amount': refundAmount,
      'status': status,
      'reason': reason,
      'user_media': userMedia,
      'admin_notes': adminNotes,
      'admin_receipt': adminReceipt,
      'purchase_date': purchaseDate,
      'request_date': requestDate,
      'processed_at': processedAt,
      'processed_by': processedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'course': course?.toJson(),
    };
  }
}
