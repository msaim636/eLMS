import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class PurchaseCertificateResponseModel extends Model {
  final int orderId;
  final String orderNumber;
  final int courseId;
  final String courseTitle;
  final num certificateFee;
  final String paymentMethod;
  final String status;
  final PaymentDetails? payment;
  final String createdAt;

  PurchaseCertificateResponseModel({
    required this.orderId,
    required this.orderNumber,
    required this.courseId,
    required this.courseTitle,
    required this.certificateFee,
    required this.paymentMethod,
    required this.status,
    this.payment,
    required this.createdAt,
  });

  factory PurchaseCertificateResponseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseCertificateResponseModel(
      orderId: json.require<int>('order_id'),
      orderNumber: json.optional<String>('order_number') ?? '',
      courseId: json.require<int>('course_id'),
      courseTitle: json.optional<String>('course_title') ?? '',
      certificateFee: json.optional<num>('certificate_fee') ?? 0,
      paymentMethod: json.optional<String>('payment_method') ?? '',
      status: json.optional<String>('status') ?? '',
      payment: json.optional<Map<String, dynamic>>('payment') != null
          ? PaymentDetails.fromJson(
              json.require<Map<String, dynamic>>('payment'),
            )
          : null,
      createdAt: json.optional<String>('created_at') ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_number': orderNumber,
      'course_id': courseId,
      'course_title': courseTitle,
      'certificate_fee': certificateFee,
      'payment_method': paymentMethod,
      'status': status,
      if (payment != null) 'payment': payment!.toJson(),
      'created_at': createdAt,
    };
  }
}

class PaymentDetails extends Model {
  final String provider;
  final String id;
  final String url;
  final Map<String, dynamic>? meta;

  PaymentDetails({
    required this.provider,
    required this.id,
    required this.url,
    this.meta,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      provider: json.optional<String>('provider') ?? '',
      id: json.optional<String>('id') ?? '',
      url: json.optional<String>('url') ?? '',
      meta: json.optional<Map<String, dynamic>>('meta'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'id': id,
      'url': url,
      if (meta != null) 'meta': meta,
    };
  }
}
