import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/login/guest_checker.dart';
import 'package:elms/features/cart/widgets/coupon_card.dart';
import 'package:elms/features/coupon/cubits/apply_coupon_cubit.dart';
import 'package:elms/features/coupon/cubits/fetch_coupons_cubit.dart';
import 'package:elms/features/coupon/models/coupon_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CouponScreen extends StatefulWidget {
  final int? courseId;
  final CouponListTarget target;

  const CouponScreen({
    super.key,
    this.courseId,
    required this.target,
  });

  static Widget route() {
    final args = Get.arguments as Map<String, dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FetchCouponsCubit(
            courseId: args['courseId'] as int?,
          ),
        ),
        BlocProvider(create: (context) => ApplyCouponCubit()),
      ],
      child: CouponScreen(
        courseId: args['courseId'] as int?,
        target: args['target'] as CouponListTarget,
      ),
    );
  }

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  final TextEditingController _applyCoupon = TextEditingController();
  CouponModel? _appliedCoupon;
  bool _isApplyingManually = false;
  int? _loadingCouponId;

  @override
  void initState() {
    super.initState();
    context.read<FetchCouponsCubit>().fetch();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApplyCouponCubit, ApplyCouponState>(
      listener: (context, state) {
        if (state is ApplyCouponInProgress) {
          // Loading state is already set in the respective methods
        } else if (state is ApplyCouponSuccess) {
          setState(() {
            _isApplyingManually = false;
            _loadingCouponId = null;
          });
          Navigator.of(context).pop(state.previewData);
        } else if (state is ApplyCouponFail) {
          setState(() {
            _isApplyingManually = false;
            _loadingCouponId = null;
          });
          final errorMessage = UiUtils.friendlyErrorMessage(state.error);
          UiUtils.showSnackBar(errorMessage, isError: true);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(showBackButton: true, title: AppLabels.coupon.tr),
        body: Padding(
          padding: const .all(16),
          child: Column(
            spacing: 16,
            children: [
              _buildCouponApply(context),
              Expanded(
                child: BlocBuilder<FetchCouponsCubit, FetchCouponsState>(
                  builder: (context, state) {
                    if (state is FetchCouponsInProgress) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is FetchCouponsFail) {
                      return Center(child: ErrorWidget(state.error));
                    }
                    if (state is FetchCouponsSuccess) {
                      if (state.coupons.isEmpty) {
                        return const Center(
                          child: Text('No coupons available'),
                        );
                      }
                      return ListView.separated(
                        itemCount: state.coupons.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final CouponModel coupon = state.coupons[index];
                          return CouponCard(
                            message: coupon.message,
                            couponCode: coupon.promoCode,
                            expiryDate: coupon.formattedEndDate,
                            onCopy: () => _onTapCopyCoupon(coupon.promoCode),
                            onRedeem: () => _onTapRedeemCoupon(coupon),
                            appliedCouponName: _appliedCoupon?.id == coupon.id
                                ? coupon.promoCode
                                : null,
                            isLoading: _loadingCouponId == coupon.id,
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponApply(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _applyCoupon,
      builder: (context, value, child) {
        final bool isButtonEnabled =
            value.text.trim().isNotEmpty && !_isApplyingManually;

        return CustomTextFormField(
          controller: _applyCoupon,
          hintText: AppLabels.enterCouponCode.tr,
          enabled: !_isApplyingManually,
          requiredErrorMessage: AppLabels.fieldRequired.tr,
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: _isApplyingManually
                ? SizedBox(
                    height: 32,
                    width: 60,
                    child: Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.color.primary,
                        ),
                      ),
                    ),
                  )
                : CustomButton(
                    height: 32,
                    backgroundColor: context.color.primary,
                    onPressed: isButtonEnabled ? _onTapApplyCoupon : null,
                    title: AppLabels.apply.tr,
                  ),
          ),
        );
      },
    );
  }

  void _onTapApplyCoupon() {
    if (_applyCoupon.text.isEmpty) return;
    // Cart promos apply to the whole cart; only the course target needs a course id.
    if (widget.target == CouponListTarget.course && widget.courseId == null) {
      return;
    }
    setState(() {
      _isApplyingManually = true;
    });
    context.read<ApplyCouponCubit>().applyCouponByCode(
      code: _applyCoupon.text,
      courseId: widget.courseId,
      target: widget.target,
    );
  }

  void _onTapCopyCoupon(String couponCode) {
    Clipboard.setData(ClipboardData(text: couponCode));
  }

  void _onTapRedeemCoupon(CouponModel coupon) {
    // Cart promos apply to the whole cart; only the course target needs a course id.
    if (widget.target == CouponListTarget.course && widget.courseId == null) {
      return;
    }
    GuestChecker.check(
      onNotGuest: () {
        setState(() {
          _appliedCoupon = coupon;
          _loadingCouponId = coupon.id;
        });
        context.read<ApplyCouponCubit>().applyCouponById(
          coupon: coupon,
          courseId: widget.courseId,
          target: widget.target,
        );
      },
    );
  }
}
