import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class CouponModel extends Model {
  final int id;
  final String promoCode;
  final String message;
  final num discount;
  final String discountType;
  final num? maxDiscountAmount;
  final num? minimumOrderAmount;
  final DateTime startDate;
  final DateTime endDate;
  final String? createdBy;
  final String? adminName;
  final String? adminEmail;
  final int? noOfUsers;
  final bool? repeatUsage;
  final int? noOfRepeatUsage;

  CouponModel({
    required this.id,
    required this.promoCode,
    required this.message,
    required this.discount,
    required this.discountType,
    required this.maxDiscountAmount,
    required this.minimumOrderAmount,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    required this.adminName,
    required this.adminEmail,
    required this.noOfUsers,
    required this.repeatUsage,
    required this.noOfRepeatUsage,
  });

  /// Returns formatted end date in dd-MM-yyyy format (e.g., 01-07-2028)
  String get formattedEndDate {
    final day = endDate.day.toString().padLeft(2, '0');
    final month = endDate.month.toString().padLeft(2, '0');
    final year = endDate.year.toString();
    return '$day-$month-$year';
  }

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json.require<int>('id'),
      promoCode: json.require<String>('promo_code'),
      message: json.require<String>('message'),
      discount: json.require<num>('discount'),
      discountType: json.require<String>('discount_type'),
      maxDiscountAmount: json.optional<num?>('max_discount_amount'),
      minimumOrderAmount: json.optional<num?>('minimum_order_amount'),
      startDate: DateTime.parse(json.require<String>('start_date')),
      endDate: DateTime.parse(json.require<String>('end_date')),
      createdBy: json.optional<String?>('created_by'),
      adminName: json.optional<String?>('instructor_name'),
      adminEmail: json.optional<String?>('instructor_email'),
      noOfUsers: json.optional<int?>('total_usage_limit'),
      repeatUsage: json.optional<bool?>('repeat_usage'),
      noOfRepeatUsage: json.optional<int?>('total_usage_per_user_limit'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'promo_code': promoCode,
    'message': message,
    'discount': discount,
    'discount_type': discountType,
    'max_discount_amount': maxDiscountAmount,
    'minimum_order_amount': minimumOrderAmount,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'created_by': createdBy,
    'admin_name': adminName,
    'admin_email': adminEmail,
    'no_of_users': noOfUsers,
    'repeat_usage': repeatUsage,
    'no_of_repeat_usage': noOfRepeatUsage,
  };
}
