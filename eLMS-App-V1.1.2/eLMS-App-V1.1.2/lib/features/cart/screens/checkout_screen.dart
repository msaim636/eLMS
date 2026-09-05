import 'package:country_code_picker/country_code_picker.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/restricted_widget.dart';
import 'package:elms/common/enums.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/cart/cubit/cart_cubit.dart';
import 'package:elms/features/cart/cubit/billing_details_cubit.dart';
import 'package:elms/features/cart/models/cart_response_model.dart';
import 'package:elms/features/cart/models/checkout_data_model.dart';
import 'package:elms/features/cart/models/place_order_response_model.dart';
import 'package:elms/features/cart/cubit/checkout_cubit.dart';
import 'package:elms/features/cart/repository/cart_repository.dart';
import 'package:elms/features/cart/repository/checkout_repository.dart';
import 'package:elms/features/cart/repository/billing_details_repository.dart';
import 'package:elms/features/cart/screens/billing_details_screen.dart';
import 'package:elms/features/cart/screens/payment_webview_screen.dart';
import 'package:elms/features/cart/widgets/order_summary_card.dart';
import 'package:elms/features/coupon/cubits/apply_coupon_cubit.dart';
import 'package:elms/features/cart/widgets/checkout_bar.dart';
import 'package:elms/features/cart/widgets/checkout_result_bottom_sheet.dart';
import 'package:elms/features/cart/widgets/billing_details_card.dart';
import 'package:elms/features/settings/cubit/app_settings_cubit.dart';
import 'package:elms/features/settings/cubit/settings_state.dart';
import 'package:elms/features/settings/models/app_setting_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/features/course/services/course_content_notifier.dart';
import 'package:elms/features/main/main_screen.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:elms/core/routes/routes.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CheckoutScreen extends StatefulWidget {
  final CheckoutDataModel? checkoutData;
  final CheckoutType checkoutType;
  final int? courseId;
  final int? promocodeId;

  const CheckoutScreen({
    super.key,
    this.checkoutData,
    this.checkoutType = CheckoutType.cart,
    this.courseId,
    this.promocodeId,
  });

  static Widget route() {
    final args = Get.arguments;
    CheckoutDataModel? checkoutData;
    CheckoutType checkoutType = CheckoutType.cart;
    int? courseId;
    int? promoCode;

    if (args is Map<String, dynamic>) {
      checkoutData = args['checkoutData'];
      checkoutType = args['checkoutType'] ?? CheckoutType.cart;
      courseId = args['courseId'];
      promoCode = args['promocodeId'];
    } else if (args is CheckoutDataModel) {
      // Backward compatibility
      checkoutData = args;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CheckoutCubit(CheckoutRepository())),
        BlocProvider(create: (context) => ApplyCouponCubit()),
        BlocProvider(
          create: (context) =>
              BillingDetailsCubit(BillingDetailsRepository())..fetch(),
        ),
      ],
      child: CheckoutScreen(
        checkoutData: checkoutData,
        checkoutType: checkoutType,
        courseId: courseId,
        promocodeId: promoCode,
      ),
    );
  }

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? selectedPaymentMethod;
  CheckoutDataModel? data;
  bool _isLoadingCart = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthenticationCubit>().refreshUserDetails();

    // If courseId is provided (direct enroll), fetch cart data from API
    if (widget.courseId != null) {
      _fetchCartDataForDirectEnroll();
    } else {
      data = widget.checkoutData;
      _initializePaymentMethod();
    }
  }

  Future<void> _fetchCartDataForDirectEnroll() async {
    setState(() {
      _isLoadingCart = true;
    });

    try {
      final cartRepository = CartRepository();
      final cartResponse = await cartRepository.getCartItems(
        courseId: widget.courseId,
        promoCodeId: widget.promocodeId,
      );

      // Convert CartResponseModel to CheckoutDataModel
      data = CheckoutDataModel.fromCart(cartResponse);

      _initializePaymentMethod();
    } catch (e) {
      // Handle error - show error message
      if (mounted) {
        UiUtils.showSnackBar(
          AppLabels.failedToLoadCheckoutData.tr,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCart = false;
        });
      }
    }
  }

  void _initializePaymentMethod() {
    final totalPay = _getTotalPay();

    // Don't select any payment method if total is zero (free after coupon/discount)
    if (totalPay <= 0) {
      selectedPaymentMethod = null;
      return;
    }

    // Check if wallet has sufficient balance and set it as default
    final userTotalBalance =
        context.read<AuthenticationCubit>().totalBalance ?? 0;

    if (userTotalBalance >= totalPay) {
      selectedPaymentMethod = 'wallet';
      return;
    }

    if (Platform.isIOS) {
      selectedPaymentMethod = null;
      return;
    }

    // Otherwise, use the first active payment method
    final settingsState = context.read<AppSettingsCubit>().state;
    if (settingsState is SettingsSuccess) {
      final activePayments = settingsState.settings.activePaymentSettings;
      if (activePayments != null && activePayments.isNotEmpty) {
        selectedPaymentMethod = activePayments.first.paymentGateway;
      }
    }
  }

  List<PaymentSettingModel> _getActivePaymentMethods() {
    if (Platform.isIOS) return [];

    final settingsState = context.read<AppSettingsCubit>().state;
    if (settingsState is SettingsSuccess) {
      return settingsState.settings.activePaymentSettings ?? [];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          ///This will be called when checkout api success because successful response means record is registered in panel
          _handlePayment(state.orderResponse);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: AppLabels.checkout.tr,
          showBackButton: true,
        ),
        body: _isLoadingCart
            ? const Center(child: CircularProgressIndicator())
            : data?.courses.isEmpty != false
            ? Center(
                child: CustomText(
                  AppLabels.yourCartIsEmpty.tr,
                  style: TextStyle(fontSize: context.font.small),
                ),
              )
            : BlocBuilder<CheckoutCubit, CheckoutState>(
                builder: (context, state) {
                  final isLoading = state is CheckoutInProgress;

                  return IgnorePointer(
                    ignoring: isLoading,
                    child: SingleChildScrollView(
                      padding: const .all(16),
                      child: Column(
                        children: [
                          if (_getTotalPay() > 0) ...[
                            _buildPaymentMethodsSection(),
                            const SizedBox(height: 16),
                          ],
                          if (data != null) ...[
                            _buildOrderDetailsSection(),
                            const SizedBox(height: 16),
                            // Hide billing details for free courses
                            if (_getTotalPay() > 0) ...[
                              _buildBillingDetailsCard(),
                              const SizedBox(height: 16),
                            ],
                            _buildBillDetailsSection(),
                          ],
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  );
                },
              ),
        bottomNavigationBar: data?.courses.isNotEmpty == true
            ? Padding(
                padding: const .all(16),
                child: BlocBuilder<CheckoutCubit, CheckoutState>(
                  builder: (context, state) {
                    return CheckoutBar(
                      totalAmount: _getTotalPay(),
                      buttonText: AppLabels.proceedToCheckout.tr,
                      onCheckout: _onTapProceedToCheckout,
                      isLoading: state is CheckoutInProgress,
                    );
                  },
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    final activePaymentMethods = _getActivePaymentMethods();

    return CustomCard(
      borderRadius: 4,
      padding: const .all(12),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            AppLabels.paymentDetails.tr,
            style: TextStyle(
              fontSize: context.font.medium,
              fontWeight: .w500,
              color: context.color.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          // Wallet payment option (always at index 0)
          _buildWalletPaymentOption(),
          // Other payment methods
          ...activePaymentMethods.asMap().entries.map((entry) {
            final PaymentSettingModel paymentMethod = entry.value;
            final String gatewayName = paymentMethod.paymentGateway ?? '';
            final String displayName = _getPaymentGatewayDisplayName(
              gatewayName,
            );
            return Column(
              children: [
                const SizedBox(height: 8),
                _buildPaymentMethodOption(gatewayName, displayName),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _getPaymentGatewayDisplayName(String gateway) {
    switch (gateway.toLowerCase()) {
      case 'stripe':
        return 'Stripe';
      case 'paypal':
        return 'Paypal';
      case 'razorpay':
        return 'Razorpay';

      default:
        // Capitalize first letter of gateway name
        if (gateway.isEmpty) return gateway;
        return gateway[0].toUpperCase() + gateway.substring(1).toLowerCase();
    }
  }

  Widget _buildPaymentMethodOption(String value, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: CustomCard(
        borderRadius: 4,
        padding: const .symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: .circle,
                    border: Border.all(
                      color: context.color.primary,
                      width: 1.5,
                    ),
                  ),
                  child: selectedPaymentMethod == value
                      ? Container(
                          margin: const .all(4),
                          decoration: BoxDecoration(
                            shape: .circle,
                            color: context.color.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                CustomText(
                  label,
                  style: TextStyle(
                    fontSize: context.font.small,
                    fontWeight: .w500,
                    color: context.color.onSurface,
                  ),
                ),
              ],
            ),
            _buildPaymentLogo(value),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentLogo(String method) {
    final String? iconPath = switch (method.toLowerCase()) {
      'stripe' => AppIcons.stripe,
      'razorpay' => AppIcons.razorpay,
      'flutterwave' => AppIcons.flutterWave,
      _ => null,
    };

    if (iconPath != null) {
      return CustomImage(
        iconPath,
        height: 24,
        width: 75,
        alignment: AlignmentDirectional.centerEnd,
      );
    }

    return Container(
      padding: const .all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      child: CustomText(
        method.toUpperCase(),
        style: TextStyle(
          fontSize: context.font.xSmall,
          fontWeight: .bold,
          color: context.color.primary,
        ),
      ),
    );
  }

  Widget _buildWalletPaymentOption() {
    final userTotalBalance =
        context.read<AuthenticationCubit>().totalBalance ?? 0;
    final totalPay = _getTotalPay();
    final isEnabled = userTotalBalance >= totalPay;
    const String walletValue = 'wallet';

    return GestureDetector(
      onTap: isEnabled
          ? () {
              setState(() {
                selectedPaymentMethod = walletValue;
              });
            }
          : null,
      child: CustomCard(
        borderRadius: 4,
        padding: const .symmetric(horizontal: 16, vertical: 8),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: .circle,
                      border: Border.all(
                        color: isEnabled
                            ? context.color.primary
                            : context.color.textSecondary,
                        width: 1.5,
                      ),
                    ),
                    child: selectedPaymentMethod == walletValue && isEnabled
                        ? Container(
                            margin: const .all(4),
                            decoration: BoxDecoration(
                              shape: .circle,
                              color: context.color.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    '${AppLabels.wallet.tr} (${userTotalBalance.toStringAsFixed(2).currency})',
                    style: TextStyle(
                      fontSize: context.font.small,
                      fontWeight: .w500,
                      color: isEnabled
                          ? context.color.onSurface
                          : context.color.textSecondary,
                    ),
                  ),
                ],
              ),
              _buildPaymentLogo(AppLabels.wallet.tr),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailsSection() {
    return CustomCard(
      borderRadius: 4,
      padding: const .all(12),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            AppLabels.orderDetails.tr,
            style: TextStyle(
              fontSize: context.font.medium,
              fontWeight: .w500,
              color: context.color.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          ...data!.courses.map((course) => _buildCourseItem(course)),
        ],
      ),
    );
  }

  Widget _buildCourseItem(CartCourseModel course) {
    return CustomCard(
      padding: const .all(8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImage(
              course.thumbnail,
              width: 45,
              height: 45,
              fit: .cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                CustomText(
                  course.title,
                  style: TextStyle(
                    fontSize: context.font.small,
                    fontWeight: .w500,
                    color: context.color.onSurface,
                  ),
                  maxLines: 1,
                  ellipsis: true,
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${AppLabels.by.tr} ',
                        style: TextStyle(
                          fontSize: context.font.xSmall,
                          color: context.color.textSecondary,
                        ),
                      ),
                      TextSpan(
                        text: course.instructor,
                        style: TextStyle(
                          fontSize: context.font.xSmall,
                          color: context.color.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CustomText(
            course.effectivePrice.toStringAsFixed(2).currency,
            style: TextStyle(
              fontSize: context.font.small,
              fontWeight: .bold,
              color: context.color.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingDetailsCard() {
    return BlocBuilder<BillingDetailsCubit, BillingDetailsState>(
      builder: (context, state) {
        if (state is BillingDetailsInProgress) {
          return CustomCard(
            borderRadius: 4,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CustomText(
                  AppLabels.billingDetails.tr,
                  style: TextStyle(fontSize: context.font.medium),
                ),
                const Spacer(),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
          );
        }

        if (state is BillingDetailsSuccess && state.billingDetails != null) {
          final billingDetails = state.billingDetails!;
          return BillingDetailsCard(
            companyName:
                '${billingDetails.firstName} ${billingDetails.lastName}',
            address: billingDetails.address,
            city: billingDetails.city,
            state: billingDetails.state,
            zipCode: billingDetails.postalCode,
            country:
                billingDetails.countryName ??
                CountryCode.fromCountryCode(billingDetails.countryCode).name,
            taxId: billingDetails.taxId,
            onEdit: () async {
              final cubit = context.read<BillingDetailsCubit>();
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: cubit,
                    child: const BillingDetailsScreen(),
                  ),
                ),
              );
              if (mounted && result == 'trigger-fetch') {
                await cubit.fetch();
              }
            },
          );
        }

        return GestureDetector(
          onTap: () async {
            final cubit = context.read<BillingDetailsCubit>();
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: cubit,
                  child: const BillingDetailsScreen(),
                ),
              ),
            );
            if (mounted && result == true) {
              await cubit.fetch();
            }
          },
          child: CustomCard(
            borderRadius: 4,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CustomText(
                  AppLabels.billingDetails.tr,
                  style: TextStyle(fontSize: context.font.medium),
                ),
                const Spacer(),
                CustomImage(AppIcons.right, color: context.color.darkColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillDetailsSection() {
    return OrderSummaryCard(
      summary: widget.checkoutData?.summary ?? data!.summary,
    );
  }

  num _getTotalPay() {
    final applyCouponState = context.read<ApplyCouponCubit>().state;
    if (applyCouponState is ApplyCouponSuccess) {
      return applyCouponState.previewData.total;
    }
    return data!.summary.finalTotal!;
  }

  void _onTapProceedToCheckout() {
    // Guard: if wallet is negative (iOS refund), block new purchases.
    final walletBalance = context.read<AuthenticationCubit>().totalBalance ?? 0;
    if (walletBalance < 0) {
      NegativeWalletPurchaseDialog.show(context);
      return;
    }

    final totalPay = _getTotalPay();

    // Validate billing details are filled only for paid courses
    if (totalPay > 0) {
      final billingState = context.read<BillingDetailsCubit>().state;
      if (billingState is! BillingDetailsSuccess ||
          billingState.billingDetails == null) {
        UiUtils.showSnackBar(
          AppLabels.pleaseAddBillingDetails.tr,
          isError: true,
        );
        return;
      }
    }

    // Validate payment method is selected only for paid courses
    if (totalPay > 0 &&
        (selectedPaymentMethod == null || selectedPaymentMethod!.isEmpty)) {
      UiUtils.showSnackBar(
        AppLabels.pleaseSelectPaymentMethod.tr,
        isError: true,
      );
      return;
    }

    final checkoutCubit = context.read<CheckoutCubit>();

    // Get promo code IDs from ApplyCouponCubit if applied
    List<String>? promoCodeIds;
    final applyCouponState = context.read<ApplyCouponCubit>().state;
    if (applyCouponState is ApplyCouponSuccess) {
      promoCodeIds = [
        ?applyCouponState.previewData.courses.first.promoCode?.id.toString(),
      ];
    } else if (data?.promoCodeId != null) {
      // Fallback to checkout data if available
      promoCodeIds = [data!.promoCodeId.toString()];
    }

    // For free courses, use 'free' as payment method if none selected
    final paymentMethod = totalPay > 0
        ? selectedPaymentMethod!
        : (selectedPaymentMethod ?? 'free');

    if (widget.checkoutType == CheckoutType.directEnroll) {
      // Direct enroll scenario - get course ID from checkout data
      final courseId = data?.courses.first.id;
      if (courseId != null) {
        checkoutCubit.placeOrderForDirectEnroll(
          paymentMethod: paymentMethod,
          courseId: courseId,
          promoCodeIds: promoCodeIds,
        );
      }
    } else {
      // Cart scenario
      checkoutCubit.placeOrderFromCart(
        paymentMethod: paymentMethod,
        promoCodeIds: promoCodeIds,
      );
    }
  }

  void _handlePayment(PlaceOrderResponse response) async {
    if (response.hasPaymentUrl && response.orderNumber != null) {
      // Navigate to payment webview screen
      final result = await Get.toNamed(
        AppRoutes.paymentWebViewScreen,
        arguments: {
          'paymentUrl': response.orderUrl!,
          'orderNumber': response.orderNumber!,
        },
      );

      if (result case final PaymentGatewayCallbackResponse data) {
        if (data.status == PaymentStatus.completed) {
          // Refresh user details if payment was made through wallet
          if (selectedPaymentMethod == 'wallet' && mounted) {
            try {
              await context.read<AuthenticationCubit>().refreshUserDetails();
            } catch (e) {
              // Continue even if refresh fails
            }
          }

          // Clear cart after successful payment for cart checkout
          if (widget.checkoutType == CheckoutType.cart && mounted) {
            try {
              await context.read<CartCubit>().clearCart();
            } catch (e) {
              // Continue even if clear cart fails
            }
          }

          await _showResultBottomSheet(
            isSuccess: true,
            amount: data.amount.toDouble(),
            txn: data.orderNumber,
          );
        } else if (data.status == PaymentStatus.paymentFailed ||
            data.status == PaymentStatus.cancelled) {
          await _showResultBottomSheet(
            isSuccess: false,
            amount: data.amount.toDouble(),
            txn: data.orderNumber,
          );
        }
      } else if (result is Map) {
        final isSuccess = result['success'] == true;

        if (isSuccess) {
          if (selectedPaymentMethod == 'wallet' && mounted) {
            try {
              await context.read<AuthenticationCubit>().refreshUserDetails();
            } catch (e) {
              // Ignore failure
            }
          }

          if (widget.checkoutType == CheckoutType.cart && mounted) {
            try {
              await context.read<CartCubit>().clearCart();
            } catch (e) {
              // Ignore failure
            }
          }
        }

        // Pass 0.0 or actual amount if we had it, orderNumber as txn
        final amount = num.parse(response.order?.totalPrice ?? '0').toDouble();
        await _showResultBottomSheet(
          isSuccess: isSuccess,
          amount: amount,
          txn:
              result['orderNumber'] as String? ??
              response.orderNumber ??
              response.orderId ??
              '',
        );
      }
    } else {
      // No payment URL - show result bottom sheet directly
      final isSuccess = !response.error;

      // Refresh user details if payment was made through wallet and successful
      if (isSuccess && selectedPaymentMethod == 'wallet' && mounted) {
        try {
          await context.read<AuthenticationCubit>().refreshUserDetails();
        } catch (e) {
          // Continue even if refresh fails
        }
      }

      // Clear cart after successful payment for cart checkout
      if (isSuccess && widget.checkoutType == CheckoutType.cart && mounted) {
        try {
          await context.read<CartCubit>().clearCart();
        } catch (e) {
          // Continue even if clear cart fails
        }
      }

      await _showResultBottomSheet(
        isSuccess: isSuccess,
        amount: num.parse(response.order?.totalPrice ?? '0').toDouble(),
        txn: response.orderId ?? '',
      );
    }
  }

  CourseModel? _buildEnrolledCourse() {
    if (widget.checkoutType != CheckoutType.directEnroll) return null;
    final cartCourse = data?.courses.firstOrNull;
    if (cartCourse == null) return null;
    return CourseModel(
      id: cartCourse.id,
      slug: cartCourse.slug,
      image: cartCourse.thumbnail,
      categoryId: null,
      categoryName: null,
      ratings: cartCourse.ratings,
      averageRating: cartCourse.averageRating,
      title: cartCourse.title,
      shortDescription: '',
      authorName: cartCourse.instructor,
      price: cartCourse.originalPrice,
      level: '',
      discountPercentage: 0,
      isWishlisted: cartCourse.isWishlisted,
      isEnrolled: true,
      courseType: cartCourse.originalPrice == 0 ? 'free' : 'paid',
      originalPrice: cartCourse.originalPrice,
      courseDiscount: cartCourse.courseDiscount,
      subtotal: cartCourse.subtotal,
      promoDiscount: cartCourse.promoDiscount,
      taxableAmount: cartCourse.taxableAmount,
      taxPercentage: cartCourse.taxPercentage,
      taxAmount: cartCourse.taxAmount,
      total: cartCourse.total,
      enrollStudents: 0,
    );
  }

  Future<void> _showResultBottomSheet({
    required bool isSuccess,
    required String txn,
    required double amount,
  }) async {
    if (mounted) {
      final enrolledCourse = isSuccess ? _buildEnrolledCourse() : null;

      Future<void> navigateOnSuccess() async {
        if (enrolledCourse != null) {
          await Get.offAllNamed(AppRoutes.mainActivity);
          if (AppConstant.kEnableExperimentalMiniPlayer) {
            CourseContentNotifier.instance.showCourse(enrolledCourse);
          } else {
            courseContentNavigator.value = CourseContentScreenArguments(
              course: enrolledCourse,
            );
          }
        } else {
          await Get.offAllNamed(AppRoutes.myLearningScreen);
        }
      }

      final result = await UiUtils.showCustomBottomSheet<bool?>(
        context,
        enableDrag: false,
        child: CheckoutResultBottomSheet(
          isSuccess: isSuccess,
          amount: amount,
          txn: txn,
          onAction: () async {
            Get.back();
            if (isSuccess) {
              await navigateOnSuccess();
            } else {
              // Retry: re-trigger the checkout/payment flow
              _onTapProceedToCheckout();
            }
          },
        ),
      );

      // Bottom sheet dismissed without tapping button
      if (result == null && mounted) {
        if (isSuccess) {
          await navigateOnSuccess();
        }
        // On failure dismissal: stay on checkout screen, user can retry manually
      }
    }
  }
}
