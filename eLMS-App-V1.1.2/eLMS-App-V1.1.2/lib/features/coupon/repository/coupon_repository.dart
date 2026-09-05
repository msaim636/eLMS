import 'package:elms/common/enums.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/features/coupon/models/coupon_model.dart';
import 'package:elms/features/coupon/models/promo_code_preview_model.dart';

class CouponRepository {
  Future<DataClass<CouponModel>> fetchCoupons({int? courseId}) async {
    final Map<String, dynamic> response = await Api.get(
      Apis.getCouponList,
      data: {if (courseId != null) ApiParams.courseId: courseId},
    );

    // The API nests the list under `data.promo_codes`, with `course` and
    // `total_codes` as sibling metadata, so `DataClass.fromResponse` (which
    // expects `data` to be a List) can't be used directly.
    final dynamic rawData = response[ApiParams.data];
    final Map<String, dynamic> dataMap = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};

    final dynamic rawList = dataMap['promo_codes'];
    final List<CouponModel> coupons = rawList is List
        ? rawList
              .map(
                (e) =>
                    CouponModel.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList()
        : <CouponModel>[];

    return DataClass(
      data: coupons,
      extraData: {
        'course': dataMap['course'],
        'total_codes': dataMap['total_codes'],
      },
    );
  }

  Future<PromoCodePreviewModel> applyCoupon({
    int? promoCodeId,
    String? code,
    int? courseId,
    CouponListTarget target = CouponListTarget.course,
  }) async {
    // Use different API based on target
    final bool isCart = target == CouponListTarget.cart;
    final String apiEndpoint = isCart ? Apis.applyCouponCart : Apis.applyCoupon;

    final Map<String, dynamic> response = await Api.post(
      apiEndpoint,
      data: {
        'promo_code_id': promoCodeId,
        'promo_code': code,
        // Cart promos apply to the whole cart, so no course_id is sent.
        // Course / enroll-now promos require the course_id.
        if (!isCart && courseId != null) 'course_id': courseId,
      },
    );

    return PromoCodePreviewModel.fromJson(response['data']);
  }

  Future<void> removeCoupon({required CouponListTarget target}) async {
    if (target == CouponListTarget.cart) {
      // Call the cart/remove-promo API for cart
      await Api.post(Apis.removeCouponCart, data: {});
    }
    // For course context, we don't need to call any API
  }
}
