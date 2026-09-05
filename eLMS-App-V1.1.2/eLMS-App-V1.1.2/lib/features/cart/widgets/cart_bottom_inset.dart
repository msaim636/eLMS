import 'package:elms/features/cart/cubit/cart_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const double kCartBottomInset = 72;

extension CartBottomInsetContext on BuildContext {
  double get cartBottomInset {
    final state = watch<CartCubit>().state;
    if (state is CartSuccess && state.cart.courses.isNotEmpty) {
      return kCartBottomInset;
    }
    return 0;
  }
}
