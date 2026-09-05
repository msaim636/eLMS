import 'package:elms/common/enums.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:get/get.dart';

class TransactionHistoryModel extends Model {
  final int orderId;
  final String orderNumber;
  final String status;
  final num totalPrice;
  final num taxPrice;
  final num totalDiscount;
  final num finalTotal;
  final String transactionDate;
  final String transactionDateFormatted;
  final String transactionDateHuman;
  final List<TransactionCourseModel> courses;
  final Map? promoCode;
  final String? paymentMethod;

  TransactionHistoryModel({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.totalPrice,
    required this.taxPrice,
    required this.totalDiscount,
    required this.finalTotal,
    required this.transactionDate,
    required this.transactionDateFormatted,
    required this.transactionDateHuman,
    required this.courses,
    this.promoCode,
    this.paymentMethod,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      orderId: json.require<int>('order_id'),
      orderNumber: json.require<String>('order_number'),
      status: json.require<String>('status'),
      totalPrice: json.require<num>('total_price'),
      taxPrice: json.require<num>('tax_price'),
      totalDiscount: json.optional<num>('total_discount') ?? 0,
      finalTotal: json.optional<num>('final_total') ?? 0,
      transactionDate: json.require<String>('transaction_date'),
      transactionDateFormatted: json.require<String>(
        'transaction_date_formatted',
      ),
      transactionDateHuman: json.require<String>('transaction_date_human'),
      courses: (json.require<List<dynamic>>(
        'courses',
      )).map((e) => TransactionCourseModel.fromJson(e)).toList(),
      promoCode: json.optional<Map>('promo_code'),
      paymentMethod: json.optional<String>('payment_method'),
    );
  }

  /// Converts the string status to TransactionStatus enum
  TransactionStatus get transactionStatus {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('success') ||
        statusLower.contains('completed') ||
        statusLower.contains('paid')) {
      return TransactionStatus.success;
    } else if (statusLower.contains('pending') ||
        statusLower.contains('processing')) {
      return TransactionStatus.pending;
    } else {
      return TransactionStatus.failed;
    }
  }

  /// Gets the display name for payment method
  String get paymentMethodDisplay {
    if (paymentMethod == null || paymentMethod!.isEmpty) {
      return AppLabels.notAvailable.tr;
    }
    // Capitalize first letter
    return paymentMethod![0].toUpperCase() + paymentMethod!.substring(1);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_number': orderNumber,
      'status': status,
      'total_price': totalPrice,
      'tax_price': taxPrice,
      'total_discount': totalDiscount,
      'final_total': finalTotal,
      'transaction_date': transactionDate,
      'transaction_date_formatted': transactionDateFormatted,
      'transaction_date_human': transactionDateHuman,
      'courses': courses.map((e) => e.toJson()).toList(),
      'promo_code': promoCode,
      'payment_method': paymentMethod,
    };
  }
}

class TransactionCourseModel {
  final int courseId;
  final String title;
  final num price;
  final num originalPrice;
  final num priceWithoutTax;
  final num discountAmount;
  final num taxPrice;
  final num finalPrice;
  final String image;
  final String courseType;
  final String creatorName;
  final bool refundEnabled;
  final int refundPeriodDays;
  final bool isRefundEligible;
  final num refundDaysRemaining;
  final bool hasRefundRequest;
  final RefundStatus refundRequestStatus;
  final int? refundRequestId;
  final String? refundAdminNotes;
  final String purchaseDate;

  TransactionCourseModel({
    required this.courseId,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.priceWithoutTax,
    required this.discountAmount,
    required this.taxPrice,
    required this.finalPrice,
    required this.image,
    required this.courseType,
    required this.creatorName,
    required this.refundEnabled,
    required this.refundPeriodDays,
    required this.isRefundEligible,
    required this.refundDaysRemaining,
    required this.hasRefundRequest,
    required this.refundRequestStatus,
    this.refundRequestId,
    this.refundAdminNotes,
    required this.purchaseDate,
  });

  factory TransactionCourseModel.fromJson(Map<String, dynamic> json) {
    final price = json.require<num>('price');
    return TransactionCourseModel(
      courseId: json.require<int>('course_id'),
      title: json.require<String>('title'),
      price: price,
      originalPrice: json.optional<num>('original_price') ?? price,
      priceWithoutTax: json.optional<num>('price_without_tax') ?? price,
      discountAmount: json.optional<num>('discount_amount') ?? 0,
      taxPrice: json.optional<num>('tax_price') ?? 0,
      finalPrice: json.optional<num>('final_price') ?? price,
      image: json.optional<String>('image') ?? '',
      courseType: json.optional<String>('course_type') ?? '',
      creatorName: json.optional<String>('creator_name') ?? '',
      refundEnabled: json.optional<bool>('refund_enabled') ?? false,
      refundPeriodDays: json.optional<int>('refund_period_days') ?? 0,
      isRefundEligible: json.optional<bool>('is_refund_eligible') ?? false,
      refundDaysRemaining: json.optional<num>('refund_days_remaining') ?? 0,
      hasRefundRequest: json.optional<bool>('has_refund_request') ?? false,
      refundRequestStatus: RefundStatus.fromString(
        json.optional<String>('refund_request_status'),
      ),
      refundRequestId: json.optional<int>('refund_request_id'),
      refundAdminNotes: json.optional<String>('refund_admin_notes'),
      purchaseDate: json.require<String>('purchase_date'),
    );
  }

  /// Determines if the user can request a refund for this course
  /// Conditions:
  /// 1. Course price must be greater than zero (free courses are not refundable)
  /// 2. Refund must be enabled for the course
  /// 3. Must be eligible for refund (within refund period)
  /// 4. Must have remaining days to request refund
  /// 5. Should not have an existing refund request (pending or approved)
  /// 6. If previously rejected, user can request again if still eligible
  bool get canRequestRefund {
    return finalPrice > 0 &&
        refundEnabled &&
        isRefundEligible &&
        refundDaysRemaining > 0 &&
        refundRequestStatus != RefundStatus.pending &&
        refundRequestStatus != RefundStatus.approved;
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'title': title,
      'price': price,
      'original_price': originalPrice,
      'price_without_tax': priceWithoutTax,
      'discount_amount': discountAmount,
      'tax_price': taxPrice,
      'final_price': finalPrice,
      'image': image,
      'course_type': courseType,
      'creator_name': creatorName,
      'refund_enabled': refundEnabled,
      'refund_period_days': refundPeriodDays,
      'is_refund_eligible': isRefundEligible,
      'refund_days_remaining': refundDaysRemaining,
      'has_refund_request': hasRefundRequest,
      'refund_request_status': refundRequestStatus.name,
      'refund_request_id': refundRequestId,
      'refund_admin_notes': refundAdminNotes,
      'purchase_date': purchaseDate,
    };
  }
}
