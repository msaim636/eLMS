import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/cart/models/place_order_response_model.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';

class CheckoutRepository extends Blueprint {
  Future<PlaceOrderResponse> placeOrderFromCart({
    required String paymentMethod,
    List<String>? promoCodeIds,
  }) async {
    final Map<String, dynamic> requestData = {
      'payment_method': paymentMethod,
      'buy_now': 0,
      'type': 'app',
    };

    if (promoCodeIds != null && promoCodeIds.isNotEmpty) {
      requestData['promo_code_ids[]'] = promoCodeIds;
    }

    final response = await Api.post(Apis.placeOrder, data: requestData);

    return _parsePlaceOrderResponse(response);
  }

  Future<PlaceOrderResponse> placeOrderForDirectEnroll({
    required String paymentMethod,
    required int courseId,
    List<String>? promoCodeIds,
  }) async {
    final Map<String, dynamic> requestData = {
      'payment_method': paymentMethod,
      'course_id': courseId,
      'buy_now': 1,
      'type': 'app',
    };

    if (promoCodeIds != null && promoCodeIds.isNotEmpty) {
      requestData['promo_code_ids[]'] = promoCodeIds;
    }

    final response = await Api.post(Apis.placeOrder, data: requestData);

    return _parsePlaceOrderResponse(response);
  }

  PlaceOrderResponse _parsePlaceOrderResponse(Map<String, dynamic> response) {
    // If response has data field, use that, otherwise use the response directly
    final responseData =
        response[ApiParams.data] as Map<String, dynamic>? ?? response;
    return PlaceOrderResponse.fromJson(responseData);
  }
}
