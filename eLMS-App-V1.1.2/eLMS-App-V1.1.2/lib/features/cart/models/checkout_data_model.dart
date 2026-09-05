import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/cart/models/cart_response_model.dart';
import 'package:elms/features/coupon/models/promo_code_preview_model.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class CheckoutDataModel extends Model {
  final List<CartCourseModel> courses;
  final CartSummary summary;
  final int? promoCodeId;
  final PromoCodePreviewModel? promoPreview;

  CheckoutDataModel({
    required this.courses,
    required this.summary,
    this.promoCodeId,
    this.promoPreview,
  });

  factory CheckoutDataModel.fromCart(CartResponseModel cart) {
    return CheckoutDataModel(courses: cart.courses, summary: cart.summary);
  }

  @override
  Map<String, dynamic> toJson() => {
    'courses': courses.map((course) => course.toJson()).toList(),
    'summary': summary.toJson(),
    'promoCodeId': promoCodeId,
    'promoPreview': promoPreview?.toJson(),
  };

  factory CheckoutDataModel.fromJson(Map<String, dynamic> json) {
    return CheckoutDataModel(
      courses: (json.require<List>(
        'courses',
      )).map((course) => CartCourseModel.fromJson(course)).toList(),
      summary: CartSummary.fromJson(
        json.require<Map<String, dynamic>>('summary'),
      ),
      promoCodeId: json.optional<int>('promoCodeId'),
      promoPreview: json.optional<Map<String, dynamic>>('promoPreview') != null
          ? PromoCodePreviewModel.fromJson(
              json.require<Map<String, dynamic>>('promoPreview'),
            )
          : null,
    );
  }
}
