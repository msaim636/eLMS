import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/transaction/cubit/fetch_my_refunds_cubit.dart';
import 'package:elms/features/transaction/cubits/fetch_transaction_history_cubit.dart';
import 'package:elms/features/transaction/repository/refund_repository.dart';
import 'package:elms/features/transaction/repositories/transaction_history_repository.dart';
import 'package:elms/features/transaction/screens/purchases_section.dart';
import 'package:elms/features/transaction/screens/refund_details_section.dart';
import 'package:elms/utils/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  static Widget route() => const PurchaseHistoryScreen();

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FetchMyRefundsCubit(RefundRepository()),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: CustomAppBar(
            title: AppLabels.purchaseHistory.tr,
            showBackButton: true,
          ),
          body: Column(
            children: [
              _buildTabSelector(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildPurchaseHistoryTab(),
                    _buildRefundDetailsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(100),
      ),
      margin: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
      ).add(const EdgeInsetsDirectional.only(top: 10)),
      padding: const .all(6),
      child: TabBar(
        tabs: [
          Tab(text: AppLabels.purchaseHistory.tr),
          Tab(text: AppLabels.refundDetails.tr),
        ],
        dividerHeight: 0,
        splashBorderRadius: BorderRadius.circular(100),
        indicatorSize: .tab,
        indicatorColor: context.color.primary,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: context.color.primary,
        ),
        labelStyle: TextStyle(
          color: context.color.primary.getAdaptiveTextColor(),
          fontWeight: .w500,
          height: 1.25,
        ),
        unselectedLabelStyle: TextStyle(
          color: context.color.onSurface,
          fontWeight: .w500,
        ),
      ),
    );
  }

  Widget _buildPurchaseHistoryTab() {
    return BlocProvider(
      create: (context) =>
          FetchTransactionHistoryCubit(TransactionHistoryRepository())..fetch(),
      child: const PurchasesSection(),
    );
  }

  Widget _buildRefundDetailsTab() {
    return const RefundDetailsSection();
  }
}
