import 'dart:async';

import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_no_data_widget.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/services/iap_manager.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/iap/cubit/fetch_iap_products_cubit.dart';
import 'package:elms/features/iap/repository/iap_repository.dart';
import 'package:elms/features/iap/widgets/add_money_product_card.dart';
import 'package:elms/utils/sliver_heighted_deliget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:elms/utils/ui_utils.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  static Widget route() {
    return BlocProvider(
      create: (_) => FetchIapProductsCubit(IapRepository())..fetch(),
      child: const AddMoneyScreen(),
    );
  }

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  bool _isLoadingStoreProducts = false;
  StreamSubscription<IapPurchaseResult>? _purchaseSubscription;

  @override
  void initState() {
    super.initState();
    _purchaseSubscription = IapManager.instance.purchaseStream.listen(
      _onPurchaseResult,
    );
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  void _onPurchaseResult(IapPurchaseResult result) {
    if (!mounted) return;
    if (result.success) {
      context.read<AuthenticationCubit>().refreshUserDetails();
      Get.back(result: true);
      UiUtils.showSnackBar(AppLabels.walletCreditedSuccessfully.tr);
    } else {
      UiUtils.showSnackBar(
        result.errorMessage ?? AppLabels.somethingWentWrong.tr,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLabels.addMoney.tr, showBackButton: true),
      body: BlocConsumer<FetchIapProductsCubit, FetchIapProductsState>(
        listener: (context, state) async {
          if (state is FetchIapProductsSuccess) {
            setState(() {
              _isLoadingStoreProducts = true;
            });
            await IapManager.instance.loadStoreProducts(
              state.data.map((e) => e.productId!).toSet(),
            );
            if (mounted) {
              setState(() {
                _isLoadingStoreProducts = false;
              });
            }
          }
        },
        builder: (context, state) {
          if (state is FetchIapProductsProgress ||
              (state is FetchIapProductsSuccess && _isLoadingStoreProducts)) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    height: 156,
                  ),
              itemBuilder: (_, __) =>
                  const CustomShimmer(height: 156, borderRadius: 12),
            );
          }

          if (state is FetchIapProductsError) {
            return CustomErrorWidget(
              error: UiUtils.friendlyErrorMessage(state.error),
              onRetry: () => context.read<FetchIapProductsCubit>().fetch(),
            );
          }

          if (state is FetchIapProductsSuccess && !_isLoadingStoreProducts) {
            final availableProducts = state.data.where((p) {
              return IapManager.instance.storeProducts.any(
                (sp) => sp.id == p.productId,
              );
            }).toList();

            if (availableProducts.isEmpty) {
              return const CustomNoDataWidget(titleKey: AppLabels.noDataFound);
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableProducts.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    height: 156,
                  ),
              itemBuilder: (context, index) {
                final product = availableProducts[index];
                final storeProduct = IapManager.instance.storeProducts
                    .firstWhere((sp) => sp.id == product.productId);
                return AddMoneyCard(
                  product: product,
                  storeProduct: storeProduct,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── Purchase handler ─────────────────────────────────────────────────────
}
