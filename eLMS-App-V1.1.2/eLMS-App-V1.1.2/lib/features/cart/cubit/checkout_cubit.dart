import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/cart/models/place_order_response_model.dart';
import 'package:elms/features/cart/repository/checkout_repository.dart';

abstract class CheckoutState {}

class CheckoutInitial extends CheckoutState {}

class CheckoutInProgress extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final PlaceOrderResponse orderResponse;

  CheckoutSuccess(this.orderResponse);
}

base class CheckoutFail extends ErrorState implements CheckoutState {
  CheckoutFail({required super.error});
}

class CheckoutCubit extends Cubit<CheckoutState> {
  final CheckoutRepository _checkoutRepository;

  CheckoutCubit(this._checkoutRepository) : super(CheckoutInitial());

  /// Places order from cart with selected payment method and optional promo codes
  /// [paymentMethod] - Selected payment method ('stripe', 'razorpay', or 'paypal')
  /// [promoCodeIds] - Optional list of promo code IDs to apply
  Future<void> placeOrderFromCart({
    required String paymentMethod,
    List<String>? promoCodeIds,
  }) async {
    try {
      emit(CheckoutInProgress());

      final PlaceOrderResponse result = await _checkoutRepository
          .placeOrderFromCart(
            paymentMethod: paymentMethod,
            promoCodeIds: promoCodeIds,
          );

      emit(CheckoutSuccess(result));
    } catch (e) {
      emit(CheckoutFail(error: e));
    }
  }

  /// Places order for direct course enrollment with selected payment method and optional promo codes
  /// [paymentMethod] - Selected payment method ('stripe', 'razorpay', or 'paypal')
  /// [courseId] - The ID of the course to purchase directly
  /// [promoCodeIds] - Optional list of promo code IDs to apply
  Future<void> placeOrderForDirectEnroll({
    required String paymentMethod,
    required int courseId,
    List<String>? promoCodeIds,
  }) async {
    try {
      emit(CheckoutInProgress());

      final PlaceOrderResponse result = await _checkoutRepository
          .placeOrderForDirectEnroll(
            paymentMethod: paymentMethod,
            courseId: courseId,
            promoCodeIds: promoCodeIds,
          );

      emit(CheckoutSuccess(result));
    } catch (e) {
      emit(CheckoutFail(error: e));
    }
  }

  /// Resets the checkout state to initial
  void reset() {
    emit(CheckoutInitial());
  }
}
