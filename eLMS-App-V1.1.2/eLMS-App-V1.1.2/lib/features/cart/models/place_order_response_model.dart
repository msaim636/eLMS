import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

/// Order information from the API response
class OrderModel extends Model {
  final int id;
  final int userId;
  final String orderNumber;
  final String totalPrice;
  final String taxPrice;
  final String finalPrice;
  final String paymentMethod;
  final String status;
  final String createdAt;
  final String updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.totalPrice,
    required this.taxPrice,
    required this.finalPrice,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json.require<int>('id'),
      userId: json.require<int>('user_id'),
      orderNumber: json.require<String>('order_number'),
      totalPrice: json.require<String>('total_price'),
      taxPrice: json.require<String>('tax_price'),
      finalPrice: json.require<String>('final_price'),
      paymentMethod: json.require<String>('payment_method'),
      status: json.require<String>('status'),
      createdAt: json.require<String>('created_at'),
      updatedAt: json.require<String>('updated_at'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'order_number': orderNumber,
    'total_price': totalPrice,
    'tax_price': taxPrice,
    'final_price': finalPrice,
    'payment_method': paymentMethod,
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

/// Payment information from the API response
class PaymentModel extends Model {
  final String provider;
  final String id;
  final String url;

  PaymentModel({required this.provider, required this.id, required this.url});

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      provider: json.require<String>('provider'),
      id: json.require<String>('id'),
      url: json.require<String>('url'),
      // meta: json.optional<Map>('meta') ?? {},
    );
  }

  @override
  Map<String, dynamic> toJson() => {'provider': provider, 'id': id, 'url': url};
}

/// Response model for place order API
class PlaceOrderResponse extends Model {
  final bool error;
  final String message;
  final OrderModel? order;
  final PaymentModel? payment;
  final int? code;

  PlaceOrderResponse({
    required this.error,
    required this.message,
    this.order,
    this.payment,
    this.code,
  });

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json) {
    final dataSection = json.optional<Map<String, dynamic>>('data');

    return PlaceOrderResponse(
      error: json.optional<bool>('error') ?? false,
      message: json.optional<String>('message') ?? '',
      order: dataSection != null
          ? OrderModel.fromJson(
              dataSection.require<Map<String, dynamic>>('order'),
            )
          : json.optional<Map<String, dynamic>>('order') != null
          ? OrderModel.fromJson(json.require<Map<String, dynamic>>('order'))
          : null,
      payment: dataSection != null
          ? PaymentModel.fromJson(
              dataSection.require<Map<String, dynamic>>('payment'),
            )
          : json.optional<Map<String, dynamic>>('payment') != null
          ? PaymentModel.fromJson(json.require<Map<String, dynamic>>('payment'))
          : null,
      code: json.optional<int>('code'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'error': error,
    'message': message,
    if (order != null && payment != null)
      'data': {'order': order!.toJson(), 'payment': payment!.toJson()},
    if (code != null) 'code': code,
  };

  // Convenience getters for backward compatibility
  bool get success => !error;
  String? get orderUrl => payment?.url;
  String? get orderId => order?.id.toString();
  String? get orderNumber => order?.orderNumber;
  bool get hasPaymentUrl => payment?.url.isNotEmpty == true;
}

/// Enum for supported payment methods
enum PaymentMethod {
  stripe('stripe'),
  razorpay('razorpay'),
  paypal('paypal');

  const PaymentMethod(this.value);
  final String value;

  static PaymentMethod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'stripe':
        return PaymentMethod.stripe;
      case 'razorpay':
        return PaymentMethod.razorpay;
      case 'paypal':
        return PaymentMethod.paypal;
      default:
        throw ArgumentError('Unsupported payment method: $value');
    }
  }
}
