import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class CourseModel extends Model {
  final int id;
  final String? slug;
  final String image;
  final int? categoryId;
  final String? categoryName;
  final int ratings;
  final num averageRating;
  final String title;
  final String shortDescription;
  final String authorName;
  final num price;
  final num? discountedPrice;
  final num discountPercentage;
  bool isWishlisted;
  final bool isEnrolled;
  final String level;
  final int? totalChapters;
  final int? completedChapters;
  final int? totalCurriculumItems;
  final int? completedCurriculumItems;
  final num? progressPercentage;
  final String? progressStatus;
  final String? currentChapter;
  final String courseType;

  // New pricing fields
  final num originalPrice;
  final num courseDiscount;
  final num subtotal;
  final num promoDiscount;
  final num taxableAmount;
  final num taxPercentage;
  final num taxAmount;
  final num total;
  final dynamic promoCodeDetails;
  final int enrollStudents;

  /// Returns the price without tax (subtotal after discount, before tax)
  num get finalPrice {
    if (courseType == 'free') {
      return 0;
    }
    // Return subtotal (price after discount, before tax)
    if (subtotal > 0) {
      return subtotal;
    }
    return originalPrice;
  }

  bool get hasDiscount {
    if (discountPercentage > 0 && subtotal > 0 && subtotal < originalPrice) {
      return true;
    }
    return false;
  }

  bool get isFree {
    return courseType == 'free';
  }

  CourseModel({
    required this.id,
    required this.slug,
    required this.image,
    required this.categoryId,
    required this.categoryName,
    required this.ratings,
    required this.averageRating,
    required this.title,
    required this.shortDescription,
    required this.authorName,
    required this.price,
    required this.level,
    this.discountedPrice,
    required this.discountPercentage,
    required this.isWishlisted,
    required this.isEnrolled,
    this.totalChapters,
    this.completedChapters,
    this.totalCurriculumItems,
    this.completedCurriculumItems,
    this.progressPercentage,
    this.progressStatus,
    this.currentChapter,
    required this.courseType,
    required this.originalPrice,
    required this.courseDiscount,
    required this.subtotal,
    required this.promoDiscount,
    required this.taxableAmount,
    required this.taxPercentage,
    required this.taxAmount,
    required this.total,
    this.promoCodeDetails,
    required this.enrollStudents,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    // Handle both old and new API field names
    final originalPrice =
        json.optional<num>('original_price') ??
        json.optional<num>('price') ??
        0;
    final total =
        json.optional<num>('total') ??
        json.optional<num>('discount_price') ??
        originalPrice;

    return CourseModel(
      id: json.require<int>('id'),
      slug: json.optional<String?>('slug'),
      image:
          json.require<String?>('image') ??
          json.require<String?>('thumbnail') ??
          '',
      categoryId: json.require<int?>('category_id'),
      categoryName: json.require<String?>('category_name'),
      ratings: json.require<int>('ratings'),
      averageRating: json.require<num>('average_rating'),
      title: json.require<String>('title'),
      shortDescription: json.require<String?>('short_description') ?? "",
      authorName: json.require<String>('author_name'),
      // Map original_price to price for backward compatibility
      price: originalPrice,
      // Map total to discountedPrice for backward compatibility
      discountedPrice: total,
      discountPercentage: json.optional<num>('discount_percentage') ?? 0,
      // API now sends is_wishlist instead of is_wishlisted
      isWishlisted:
          json.optional<bool>('is_wishlist') ??
          json.optional<bool>('is_wishlisted') ??
          false,
      isEnrolled: json.optional<bool>('is_enrolled') ?? false,
      level: json.optional<String>('level') ?? '',
      totalChapters:
          json.optional<int>('total_chapters') ??
          json.optional<int>('chapter_count'),
      completedChapters: json.optional<int>('completed_chapters'),
      totalCurriculumItems:
          json.optional<int>('total_curriculum_count') ??
          json.optional<int>('total_curriculum_items'),
      completedCurriculumItems:
          json.optional<int>('completed_curriculum_count') ??
          json.optional<int>('completed_curriculum_items'),
      progressPercentage: json.optional<num>('progress_percentage'),
      progressStatus: json.optional<String>('progress_status'),
      currentChapter: json.optional<String?>('current_chapter_name'),
      courseType: json.require<String>('course_type'),
      // New pricing fields
      originalPrice: originalPrice,
      courseDiscount: json.optional<num>('course_discount') ?? 0,
      subtotal: json.optional<num>('subtotal') ?? total,
      promoDiscount: json.optional<num>('promo_discount') ?? 0,
      taxableAmount: json.optional<num>('taxable_amount') ?? 0,
      taxPercentage: json.optional<num>('tax_percentage') ?? 0,
      taxAmount: json.optional<num>('tax_amount') ?? 0,
      total: total,
      promoCodeDetails: json.optional('promo_code_details'),
      enrollStudents: json.optional<int>('enroll_students') ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'image': image,
    'category_id': categoryId,
    'category_name': categoryName,
    'ratings': ratings,
    'average_rating': averageRating,
    'title': title,
    'short_description': shortDescription,
    'author_name': authorName,
    'price': price,
    'discounted_price': discountedPrice,
    'discount_percentage': discountPercentage,
    'is_wishlisted': isWishlisted,
    'is_enrolled': isEnrolled,
    'level': level,
    'total_chapters': totalChapters,
    'completed_chapters': completedChapters,
    'total_curriculum_items': totalCurriculumItems,
    'completed_curriculum_items': completedCurriculumItems,
    'progress_percentage': progressPercentage,
    'progress_status': progressStatus,
    'course_type': courseType,
    // New pricing fields
    'original_price': originalPrice,
    'course_discount': courseDiscount,
    'subtotal': subtotal,
    'promo_discount': promoDiscount,
    'taxable_amount': taxableAmount,
    'tax_percentage': taxPercentage,
    'tax_amount': taxAmount,
    'total': total,
    'promo_code_details': promoCodeDetails,
    'enroll_students': enrollStudents,
  };
}
