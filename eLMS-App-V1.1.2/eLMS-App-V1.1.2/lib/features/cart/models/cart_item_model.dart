import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/features/cart/models/cart_response_model.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class CartItemModel extends Model {
  final int id;
  final int courseId;
  final CourseModel course;
  final num price;
  final num? discountedPrice;
  final String addedAt;

  CartItemModel({
    required this.id,
    required this.courseId,
    required this.course,
    required this.price,
    this.discountedPrice,
    required this.addedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json.require<int>('id'),
      courseId: json.require<int>('course_id'),
      course: CourseModel.fromJson(
        json.require<Map<String, dynamic>>('course'),
      ),
      price: json.require<num>('price').toDouble(),
      discountedPrice: json.optional<num>('discounted_price')?.toDouble(),
      addedAt: json.require<String>('created_at'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'course_id': courseId,
    'course': course.toJson(),
    'price': price,
    'discounted_price': discountedPrice,
    'created_at': addedAt,
  };

  num get effectivePrice => discountedPrice ?? price;
}

// Legacy dummy model for static UI elements
class CartItemDisplayModel extends Model {
  final String id;
  final String courseTitle;
  final String instructorName;
  final String imageUrl;
  final num rating;
  final int reviewCount;
  final num originalPrice;
  final num discountedPrice;
  final CartSummary summary;

  CartItemDisplayModel({
    required this.id,
    required this.courseTitle,
    required this.instructorName,
    required this.imageUrl,
    required this.rating,
    required this.originalPrice,
    required this.discountedPrice,
    required this.summary,
    this.reviewCount = 0,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseTitle': courseTitle,
      'instructorName': instructorName,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}
