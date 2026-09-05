// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/cart/models/billing_details_model.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class PromoCodePreviewModel extends Model {
  final List<CourseWithPromo> courses;
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
  final List<PromoDiscount> promoDiscounts;

  PromoCodePreviewModel({
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
    required this.promoDiscounts,
  });

  factory PromoCodePreviewModel.fromJson(Map<String, dynamic> json) {
    return PromoCodePreviewModel(
      courses: (json.require<List>(
        'courses',
      )).map((e) => CourseWithPromo.fromJson(e)).toList(),
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
      promoDiscounts: (json.require<List>(
        'promo_discounts',
      )).map((e) => PromoDiscount.fromJson(e)).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'courses': courses.map((e) => e.toJson()).toList(),
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
    'promo_discounts': promoDiscounts.map((e) => e.toJson()).toList(),
  };

  @override
  String toString() {
    return 'PromoCodePreviewModel(courses: $courses, originalPrice: $originalPrice, courseDiscount: $courseDiscount, subtotal: $subtotal, promoDiscount: $promoDiscount, taxableAmount: $taxableAmount, taxPercentage: $taxPercentage, taxAmount: $taxAmount, total: $total, promoDiscounts: $promoDiscounts)';
  }
}

class CourseWithPromo extends Model {
  final int id;
  final String title;
  final String slug;
  final String? thumbnail;
  final String instructor;
  final bool isWishlisted;
  final PromoCodeInfo? promoCode;
  final num originalPrice;
  final num courseDiscount;
  final num subtotal;
  final num promoDiscount;
  final num taxableAmount;
  final num taxPercentage;
  final num taxAmount;
  final num total;
  final int? ratings;
  final num? averageRating;

  CourseWithPromo({
    required this.id,
    required this.title,
    required this.slug,
    required this.thumbnail,
    required this.instructor,
    required this.isWishlisted,
    this.promoCode,
    required this.originalPrice,
    required this.courseDiscount,
    required this.subtotal,
    required this.promoDiscount,
    required this.taxableAmount,
    required this.taxPercentage,
    required this.taxAmount,
    required this.total,
    required this.ratings,
    required this.averageRating,
  });

  factory CourseWithPromo.fromJson(Map<String, dynamic> json) {
    return CourseWithPromo(
      id: json.require<int>('id'),
      title: json.require<String>('title'),
      slug: json.require<String>('slug'),
      thumbnail: json.require<String?>('thumbnail'),
      instructor: json.require<String>('instructor'),
      isWishlisted: json.require<bool>('is_wishlisted'),
      promoCode: json.optional<Map<String, dynamic>>('promo_code') == null
          ? null
          : PromoCodeInfo.fromJson(
              json.require<Map<String, dynamic>>('promo_code'),
            ),
      originalPrice: json.require<num>('original_price'),
      courseDiscount: json.require<num>('course_discount'),
      subtotal: json.require<num>('subtotal'),
      promoDiscount: json.require<num>('promo_discount'),
      taxableAmount: json.require<num>('taxable_amount'),
      taxPercentage: json.require<num>('tax_percentage'),
      taxAmount: json.require<num>('tax_amount'),
      total: json.require<num>('total'),
      ratings: json.optional<int>('ratings'),
      averageRating: json.optional<num>('average_rating'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'thumbnail': thumbnail,
    'instructor': instructor,
    'is_wishlisted': isWishlisted,
    'promo_code': promoCode?.toJson(),
    'original_price': originalPrice,
    'course_discount': courseDiscount,
    'subtotal': subtotal,
    'promo_discount': promoDiscount,
    'taxable_amount': taxableAmount,
    'tax_percentage': taxPercentage,
    'tax_amount': taxAmount,
    'total': total,
    'ratings': ratings,
    'average_rating': averageRating,
  };
}

class PromoCodeInfo extends Model {
  final int id;
  final String code;
  final String message;
  final String discountType;
  final num discountValue;
  final num discountAmount;

  PromoCodeInfo({
    required this.id,
    required this.code,
    required this.message,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
  });

  factory PromoCodeInfo.fromJson(Map<String, dynamic> json) {
    return PromoCodeInfo(
      id: json.require<int>('id'),
      code: json.require<String>('code'),
      message: json.require<String>('message'),
      discountType: json.require<String>('discount_type'),
      discountValue: json.require<num>('discount_value'),
      discountAmount: json.require<num>('discount_amount'),
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

class PromoDiscount extends Model {
  final int courseId;
  final int? promoCodeId;
  final String courseTitle;
  final String promoCode;
  final num discountAmount;

  PromoDiscount({
    required this.courseId,
    required this.courseTitle,
    required this.promoCode,
    required this.promoCodeId,
    required this.discountAmount,
  });

  factory PromoDiscount.fromJson(Map<String, dynamic> json) {
    return PromoDiscount(
      courseId: json.require<int>('course_id'),
      courseTitle: json.require<String>('course_title'),
      promoCode: json.require<String>('promo_code'),
      discountAmount: json.require<num>('discount_amount'),
      promoCodeId: json.optional<int>('promo_code_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'course_id': courseId,
    'course_title': courseTitle,
    'promo_code': promoCode,
    'discount_amount': discountAmount,
  };
}
