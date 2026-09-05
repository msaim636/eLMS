import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_no_data_widget.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/transaction/cubits/fetch_transaction_history_cubit.dart';
import 'package:elms/features/transaction/models/transaction_history_model.dart';
import 'package:elms/features/transaction/widgets/transaction_card.dart';
import 'package:elms/features/transaction/widgets/transaction_card_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PurchasesSection extends StatefulWidget {
  const PurchasesSection({super.key});

  @override
  State<PurchasesSection> createState() => _PurchasesSectionState();
}

class _PurchasesSectionState extends State<PurchasesSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _onRefresh() async {
    context.read<FetchTransactionHistoryCubit>().fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<
      FetchTransactionHistoryCubit,
      FetchTransactionHistoryState
    >(
      builder: (context, state) {
        if (state is FetchTransactionHistoryInProgress) {
          return const ShimmerBuilder(
            padding: EdgeInsets.all(16),
            spacing: 16,
            shimmer: TransactionCardShimmer(),
          );
        }
        if (state is FetchTransactionHistoryFail) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomErrorWidget(error: state.error, onRetry: _onRefresh),
          );
        }
        if (state is FetchTransactionHistorySuccess) {
          if (state.data.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: const CustomNoDataWidget(titleKey: AppLabels.noDataFound),
            );
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              padding: const .all(16),
              itemCount: state.data.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16);
              },
              itemBuilder: (context, index) {
                final TransactionHistoryModel history = state.data[index];
                return TransactionCard(
                  orderId: history.orderId,
                  courses: history.courses,
                  title: history.courses.firstOrNull?.title ?? '',
                  txnId: history.orderNumber,
                  purchaseMode: history.paymentMethodDisplay,
                  purchaseDate: history.transactionDate,
                  amount: history.finalTotal.toDouble(),
                  status: history.transactionStatus,
                );
              },
            ),
          );
        }
        return Container();
      },
    );
  }
}
