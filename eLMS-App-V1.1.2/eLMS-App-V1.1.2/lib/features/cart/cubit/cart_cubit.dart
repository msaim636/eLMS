import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/cart/models/cart_response_model.dart';
import 'package:elms/features/cart/repository/cart_repository.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartInProgress extends CartState {}

class CartSuccess extends CartState {
  final CartResponseModel cart;

  bool isAddedInCart(int id) {
    return cart.courses.indexWhere((element) => element.id == id) > -1;
  }

  CartSuccess(this.cart);
}

class UpdateCartInProgress extends CartState {
  final int id;
  UpdateCartInProgress({required this.id});
}

base class UpdateCartFail extends ErrorState implements CartState {
  UpdateCartFail({required super.error});
}

base class CartFail extends ErrorState implements CartState {
  CartFail({required super.error});
}

class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepository;
  CartCubit(this._cartRepository) : super(CartInitial());

  Future<void> fetch({int? courseId}) async {
    try {
      emit(CartInProgress());
      final CartResponseModel result = await _cartRepository.getCartItems(
        courseId: courseId,
      );
      emit(CartSuccess(result));
    } catch (e) {
      emit(CartFail(error: e));
    }
  }

  Future<void> clearCart() async {
    try {
      emit(CartInProgress());
      final CartResponseModel result = await _cartRepository.clearCart();
      emit(CartSuccess(result));
    } catch (e) {
      emit(CartFail(error: e));
    }
  }

  void addToCart(int id) async {
    try {
      if (state case final CartSuccess success) {
        emit(UpdateCartInProgress(id: id));
        final CartResponseModel cartResponseModel = await _cartRepository
            .addToCart(courseId: id);
        emit(CartSuccess(cartResponseModel));
      }
    } catch (e) {
      emit(UpdateCartFail(error: e));
    }
  }

  void removeFromCart(int id) async {
    try {
      if (state case final CartSuccess success) {
        emit(UpdateCartInProgress(id: id));
        final CartResponseModel cartResponseModel = await _cartRepository
            .removeFromCart(courseId: id);
        emit(CartSuccess(cartResponseModel));
      }
    } catch (e) {
      emit(UpdateCartFail(error: e));
    }
  }

  void toggleCart(int id) async {
    if (state is! CartSuccess) {
      await fetch();
    }
    if (state case final CartSuccess success) {
      if (success.isAddedInCart(id)) {
        removeFromCart(id);
      } else {
        addToCart(id);
      }
    }
  }

  bool isAddedInCart(int id) {
    if (state case final CartSuccess success) {
      return success.isAddedInCart(id);
    }
    return false;
  }
}
