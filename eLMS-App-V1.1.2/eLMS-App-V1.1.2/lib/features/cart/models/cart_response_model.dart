// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/cart/models/billing_details_model.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class PromoCodeModel extends Model {
  final int? id;
  final String? code;
  final String? message;
  final num? discountValue;
  final String? discountType;
  final num? discountAmount;

  PromoCodeModel({
    required this.id,
    required this.code,
    required this.message,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
  });

  factory PromoCodeModel.fromJson(Map<String, dynamic> json) {
    return PromoCodeModel(
      id: json.require<int?>('id'),
      code:
          json.require<String?>('code') ?? json.require<String?>('promo_code'),
      message: json.require<String?>('message'),
      discountType: json.require<String?>('discount_type'),
      discountValue: json.require<num?>('discount_value'),
      discountAmount: json.require<num?>('discount_amount'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'message': message,
    'discount_type': discountType,
    'discount_value': discountValue,
    'discount_amount': discountAmount,
  };
}

class CartCourseModel extends Model {
  final int id;
  final String title;
  final String slug;
  final String thumbnail;
  final num originalPrice;
  final num courseDiscount;
  final num subtotal;
  final num promoDiscount;
  final num taxableAmount;
  final num taxPercentage;
  final num taxAmount;
  final num total;
  final PromoCodeModel? promoCode;
  final String instructor;
  final bool isWishlisted;
  final int ratings;
  final num averageRating;

  CartCourseModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.thumbnail,
    required this.originalPrice,
    required this.courseDiscount,
    required this.subtotal,
    required this.promoDiscount,
    required this.taxableAmount,
    required this.taxPercentage,
    required this.taxAmount,
    required this.total,
    this.promoCode,
    required this.instructor,
    required this.isWishlisted,
    required this.ratings,
    required this.averageRating,
  });

  factory CartCourseModel.fromJson(Map<String, dynamic> json) {
    return CartCourseModel(
      id: json.require<int>('id'),
      title: json.require<String>('title'),
      slug: json.require<String>('slug'),
      thumbnail: json.require<String?>('thumbnail') ?? '',
      originalPrice: json.require<num>('original_price'),
      courseDiscount: json.require<num>('course_discount'),
      subtotal: json.require<num>('subtotal'),
      promoDiscount: json.require<num>('promo_discount'),
      taxableAmount: json.require<num>('taxable_amount'),
      taxPercentage: json.require<num>('tax_percentage'),
      taxAmount: json.require<num>('tax_amount'),
      total: json.require<num>('total'),
      promoCode: json.optional<Map<String, dynamic>?>('promo_code') != null
          ? PromoCodeModel.fromJson(
              json.optional<Map<String, dynamic>>('promo_code')!,
            )
          : null,
      instructor: json.require<String>('instructor'),
      isWishlisted: json.require<bool>('is_wishlisted'),
      ratings: json.require<int>('ratings'),
      averageRating: json.require<num>('average_rating'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'thumbnail': thumbnail,
    'original_price': originalPrice,
    'course_discount': courseDiscount,
    'subtotal': subtotal,
    'promo_discount': promoDiscount,
    'taxable_amount': taxableAmount,
    'tax_percentage': taxPercentage,
    'tax_amount': taxAmount,
    'total': total,
    'promo_code': promoCode?.toJson(),
    'instructor': instructor,
    'is_wishlisted': isWishlisted,
    'ratings': ratings,
    'average_rating': averageRating,
  };

  num get effectivePrice => subtotal > 0 ? subtotal : originalPrice;
}

class CartResponseModel extends Model {
  final List<CartCourseModel> courses;
  final String? detectedCountryCode;
  final BillingDetailsModel? billingDetails;
  final num originalPrice;
  final num courseDiscount;
  final num subtotal;
  final num promoDiscount;
  final num taxableAmount;
  final num taxPercentage;
  final num taxAmount;
  final num total;
  final PromoCodeModel? promoCode;

  CartSummary get summary => CartSummary(
    subtotal: subtotal,
    displayPrice: originalPrice,
    discount: courseDiscount,
    appliedCouponCode: promoCode?.code,
    couponDiscount: promoCode?.discountAmount,
    finalTotal: total,
    taxPercentage: taxPercentage,
    totalTaxAmount: taxAmount,
  );

  CartResponseModel({
    required this.courses,
    this.detectedCountryCode,
    this.billingDetails,
    required this.originalPrice,
    required this.courseDiscount,
    required this.subtotal,
    required this.promoDiscount,
    required this.taxableAmount,
    required this.taxPercentage,
    required this.taxAmount,
    required this.total,
    this.promoCode,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    return CartResponseModel(
      courses: json
          .require<List>('courses')
          .map(
            (course) =>
                CartCourseModel.fromJson(course as Map<String, dynamic>),
          )
          .toList(),
      detectedCountryCode: json.optional<String?>('detected_country_code'),
      billingDetails:
          json.optional<Map<String, dynamic>?>('billing_details') != null
          ? BillingDetailsModel.fromJson(
              json.optional<Map<String, dynamic>>('billing_details')!,
            )
          : null,
      originalPrice: json.require<num>('original_price'),
      courseDiscount: json.require<num>('course_discount'),
      subtotal: json.require<num>('subtotal'),
      promoDiscount: json.require<num>('promo_discount'),
      taxableAmount: json.require<num>('taxable_amount'),
      taxPercentage: json.require<num>('tax_percentage'),
      taxAmount: json.require<num>('tax_amount'),
      total: json.require<num>('total'),
      promoCode:
          (json.optional('promo_discounts') is List &&
              (json.optional<List>('promo_discounts') ?? []).isNotEmpty)
          ? PromoCodeModel.fromJson(
              (json.optional<List>('promo_discounts')!).first
                  as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'courses': courses.map((course) => course.toJson()).toList(),
    'detected_country_code': detectedCountryCode,
    'billing_details': billingDetails?.toJson(),
    'original_price': originalPrice,
    'course_discount': courseDiscount,
    'subtotal': subtotal,
    'promo_discount': promoDiscount,
    'taxable_amount': taxableAmount,
    'tax_percentage': taxPercentage,
    'tax_amount': taxAmount,
    'total': total,
    'promo_code': promoCode?.toJson(),
  };
}

class CartSummary extends Model {
  CartSummary({
    required this.subtotal,
    this.appliedCouponCode,
    this.couponDiscount,
    required this.displayPrice,
    required this.discount,
    this.totalTaxAmount,
    this.finalTotal,
    this.taxPercentage,
  });

  final num subtotal;
  final num displayPrice;
  final String? appliedCouponCode;
  final num? couponDiscount;
  final num discount;
  final num? totalTaxAmount;
  final num? finalTotal;
  final num? taxPercentage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartSummary &&
          runtimeType == other.runtimeType &&
          subtotal == other.subtotal &&
          appliedCouponCode == other.appliedCouponCode &&
          couponDiscount == other.couponDiscount;

  @override
  int get hashCode =>
      subtotal.hashCode ^ appliedCouponCode.hashCode ^ couponDiscount.hashCode;

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      discount: json.require<num>('discount'),
      displayPrice: json.require<num>('display_price'),
      subtotal: json.require<num>('subtotal'),
      appliedCouponCode: json.optional<String>('appliedCouponCode'),
      couponDiscount: json.optional<num>('couponDiscount'),
      totalTaxAmount: json.optional<num>('totalTaxAmount'),
      finalTotal: json.optional<num>('finalTotal'),
      taxPercentage: json.require<num>('total_tax_percentage'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  String toString() {
    return 'CartSummary(subtotal: $subtotal, displayPrice: $displayPrice, appliedCouponCode: $appliedCouponCode, couponDiscount: $couponDiscount, discount: $discount, totalTaxAmount: $totalTaxAmount, finalTotal: $finalTotal, taxPercentage: $taxPercentage)';
  }
}
