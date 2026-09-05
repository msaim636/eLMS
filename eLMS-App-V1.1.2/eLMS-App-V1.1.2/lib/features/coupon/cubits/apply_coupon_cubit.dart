import 'package:elms/common/enums.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/coupon/models/coupon_model.dart';
import 'package:elms/features/coupon/models/promo_code_preview_model.dart';
import 'package:elms/features/coupon/repository/coupon_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApplyCouponState {}

class ApplyCouponInitial extends ApplyCouponState {}

class ApplyCouponInProgress extends ApplyCouponState {}

class ApplyCouponSuccess extends ApplyCouponState {
  final PromoCodePreviewModel previewData;
  ApplyCouponSuccess(this.previewData);
}

final class ApplyCouponFail extends ErrorState implements ApplyCouponState {
  ApplyCouponFail({required super.error});
}

class RemoveCouponInProgress extends ApplyCouponState {}

class RemoveCouponSuccess extends ApplyCouponState {
  RemoveCouponSuccess();
}

final class RemoveCouponFail extends ErrorState implements ApplyCouponState {
  RemoveCouponFail({required super.error});
}

class ApplyCouponCubit extends Cubit<ApplyCouponState> {
  final CouponRepository _repository = CouponRepository();

  ApplyCouponCubit() : super(ApplyCouponInitial());

  /// Apply coupon by providing the coupon model (used when tapping Redeem button)
  /// This uses the promo_code_id parameter
  Future<void> applyCouponById({
    required CouponModel coupon,
    int? courseId,
    CouponListTarget target = CouponListTarget.course,
  }) async {
    try {
      emit(ApplyCouponInProgress());

      final PromoCodePreviewModel previewData = await _repository.applyCoupon(
        promoCodeId: coupon.id,
        courseId: courseId,
        target: target,
      );

      emit(ApplyCouponSuccess(previewData));
    } catch (e) {
      emit(ApplyCouponFail(error: e));
    }
  }

  /// Apply coupon by providing the coupon code (used when entering code manually)
  /// This uses the promo_code parameter
  Future<void> applyCouponByCode({
    required String code,
    int? courseId,
    CouponListTarget target = CouponListTarget.course,
  }) async {
    try {
      emit(ApplyCouponInProgress());

      final previewData = await _repository.applyCoupon(
        code: code,
        courseId: courseId,
        target: target,
      );

      emit(ApplyCouponSuccess(previewData));
    } catch (e) {
      emit(ApplyCouponFail(error: e));
    }
  }

  /// Remove applied coupon
  /// For cart: calls cart/remove-promo API
  /// For course: just clears local state
  Future<void> removeCoupon({required CouponListTarget target}) async {
    try {
      emit(RemoveCouponInProgress());

      await _repository.removeCoupon(target: target);

      emit(RemoveCouponSuccess());
    } catch (e) {
      emit(RemoveCouponFail(error: e));
    }
  }
}
