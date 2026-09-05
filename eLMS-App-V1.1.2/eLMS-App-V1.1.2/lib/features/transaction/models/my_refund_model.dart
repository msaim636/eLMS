import 'package:elms/common/enums.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class MyRefundModel extends Model {
  final int id;
  final int userId;
  final int courseId;
  final int transactionId;
  final num refundAmount;
  final RefundStatus status;
  final String reason;
  final String? userMedia;
  final String? adminNotes;
  final String? adminReceipt;
  final DateTime purchaseDate;
  final DateTime requestDate;
  final DateTime? processedAt;
  final int? processedBy;
  final String? userMediaUrl;
  final String? adminReceiptUrl;
  final RefundCourseModel course;
  final RefundTransactionModel transaction;

  MyRefundModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.transactionId,
    required this.refundAmount,
    required this.status,
    required this.reason,
    this.userMedia,
    this.adminNotes,
    this.adminReceipt,
    required this.purchaseDate,
    required this.requestDate,
    this.processedAt,
    this.processedBy,
    this.userMediaUrl,
    this.adminReceiptUrl,
    required this.course,
    required this.transaction,
  });

  factory MyRefundModel.fromJson(Map<String, dynamic> json) {
    return MyRefundModel(
      id: json.require<int>('id'),
      userId: json.require<int>('user_id'),
      courseId: json.require<int>('course_id'),
      transactionId: json.require<int>('transaction_id'),
      refundAmount: json.require<num>('refund_amount'),
      status: RefundStatus.fromString(json.require<String>('status')),
      reason: json.optional<String>('reason') ?? '',
      userMedia: json.optional<String>('user_media'),
      adminNotes: json.optional<String>('admin_notes'),
      adminReceipt: json.optional<String>('admin_receipt'),
      purchaseDate: DateTime.parse(json.require<String>('purchase_date')),
      requestDate: DateTime.parse(json.require<String>('request_date')),
      processedAt: json.optional<String>('processed_at') != null
          ? DateTime.parse(json.require<String>('processed_at'))
          : null,
      processedBy: json.optional<int>('processed_by'),
      userMediaUrl: json.optional<String>('user_media_url'),
      adminReceiptUrl: json.optional<String>('admin_receipt_url'),
      course: RefundCourseModel.fromJson(
        json.require<Map<String, dynamic>>('course'),
      ),
      transaction: RefundTransactionModel.fromJson(
        json.require<Map<String, dynamic>>('transaction'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'transaction_id': transactionId,
      'refund_amount': refundAmount.toString(),
      'status': status.name,
      'reason': reason,
      'user_media': userMedia,
      'admin_notes': adminNotes,
      'admin_receipt': adminReceipt,
      'purchase_date': purchaseDate.toIso8601String(),
      'request_date': requestDate.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'processed_by': processedBy,
      'user_media_url': userMediaUrl,
      'admin_receipt_url': adminReceiptUrl,
      'course': course.toJson(),
      'transaction': transaction.toJson(),
    };
  }
}

class RefundCourseModel {
  final int id;
  final String title;
  final String thumbnail;
  final String creatorName;
  final num price;
  final num? discountPrice;
  final String courseType;

  RefundCourseModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.creatorName,
    required this.price,
    this.discountPrice,
    required this.courseType,
  });

  factory RefundCourseModel.fromJson(Map<String, dynamic> json) {
    return RefundCourseModel(
      id: json.require<int>('id'),
      title: json.optional<String>('title') ?? '',
      thumbnail: json.optional<String>('thumbnail') ?? '',
      creatorName: json.optional<String>('creator_name') ?? '',
      price: json.optional<num>('price') ?? 0,
      discountPrice: json.optional<num>('discount_price'),
      courseType: json.optional<String>('course_type') ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'creator_name': creatorName,
      'price': price.toString(),
      'discount_price': discountPrice?.toString(),
      'course_type': courseType,
    };
  }
}

class RefundTransactionModel {
  final int id;
  final String transactionId;
  final num amount;
  final String paymentMethod;
  final String status;
  final RefundOrderModel? order;

  RefundTransactionModel({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.order,
  });

  factory RefundTransactionModel.fromJson(Map<String, dynamic> json) {
    return RefundTransactionModel(
      id: json.require<int>('id'),
      transactionId: json.optional<String>('transaction_id') ?? '',
      amount: json.optional<num>('amount') ?? 0,
      paymentMethod: json.optional<String>('payment_method') ?? '',
      status: json.optional<String>('status') ?? '',
      order: json.optional<Map<String, dynamic>>('order') != null
          ? RefundOrderModel.fromJson(
              json.require<Map<String, dynamic>>('order'),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'amount': amount.toString(),
      'payment_method': paymentMethod,
      'status': status,
      'order': order?.toJson(),
    };
  }
}

class RefundOrderModel {
  final int id;
  final String orderNumber;
  final num totalPrice;
  final num taxPrice;
  final num finalPrice;

  RefundOrderModel({
    required this.id,
    required this.orderNumber,
    required this.totalPrice,
    required this.taxPrice,
    required this.finalPrice,
  });

  factory RefundOrderModel.fromJson(Map<String, dynamic> json) {
    return RefundOrderModel(
      id: json.require<int>('id'),
      orderNumber: json.optional<String>('order_number') ?? '',
      totalPrice: json.optional<num>('total_price') ?? 0,
      taxPrice: json.optional<num>('tax_price') ?? 0,
      finalPrice: json.optional<num>('final_price') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'total_price': totalPrice.toString(),
      'tax_price': taxPrice.toString(),
      'final_price': finalPrice.toString(),
    };
  }
}
