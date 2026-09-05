import 'dart:async';
import 'dart:io';

import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_no_data_widget.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/wallet/cubit/fetch_wallet_history_cubit.dart';
import 'package:elms/features/wallet/repository/wallet_repository.dart';
import 'package:elms/features/wallet/widgets/wallet_card_widget.dart';
import 'package:elms/features/wallet/widgets/wallet_transaction_card.dart';
import 'package:elms/features/wallet/widgets/withdraw_money_bottom_sheet.dart';
import 'package:elms/utils/extensions/color_extension.dart';
import 'package:elms/utils/extensions/context_extension.dart';

import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  static Widget route() => const WalletScreen();

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController? _tabController;
  late final ScrollController _transactionScrollController;
  late final ScrollController _withdrawScrollController;

  // Cubits lifted to state level so they can be refreshed after add-money success
  FetchWalletHistoryCubit? _transactionCubit;
  FetchWalletHistoryCubit? _withdrawCubit;
  FetchWalletHistoryCubit? _androidCubit;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _tabController = TabController(length: 2, vsync: this);
      _transactionCubit = FetchWalletHistoryCubit(WalletRepository())
        ..setFilter('received')
        ..fetch();
      _withdrawCubit = FetchWalletHistoryCubit(WalletRepository())
        ..setFilter('withdrawal')
        ..fetch();
    } else {
      _androidCubit = FetchWalletHistoryCubit(WalletRepository())
        ..setFilter('all')
        ..fetch();
    }
    _transactionScrollController = ScrollController();
    _withdrawScrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _transactionScrollController.dispose();
    _withdrawScrollController.dispose();
    _transactionCubit?.close();
    _withdrawCubit?.close();
    _androidCubit?.close();
    super.dispose();
  }

  Future<void> _onTapAddMoney() async {
    final result = await Get.toNamed(AppRoutes.addMoneyScreen);
    if (result == true && mounted) {
      await context.read<AuthenticationCubit>().refreshUserDetails();
      unawaited(_transactionCubit?.fetch());
      unawaited(_androidCubit?.fetch());
    }
  }

  void _onTapWithdrawMoney(BuildContext context) {
    final num balance = context.read<AuthenticationCubit>().walletBalance ?? 0;
    if (balance <= 0) {
      return;
    }
    UiUtils.showCustomBottomSheet(
      context,
      child: WithdrawMoneyBottomSheet.create(
        onWithdrawalSuccess: () {
          context.read<FetchWalletHistoryCubit>().fetch();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: CustomAppBar(title: AppLabels.wallet.tr, showBackButton: true),
      body: Platform.isIOS ? _buildIosLayout() : _buildAndroidPage(),
    );
  }

  // ── iOS: two-tab layout ───────────────────────────────────────────────────

  Widget _buildIosLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _buildTabBar(context),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _KeepAliveTab(child: _buildTransactionTab()),
              _KeepAliveTab(child: _buildWithdrawTab()),
            ],
          ),
        ),
      ],
    );
  }

  // ── Custom pill-style tab bar (matches reference image) ──────────────────

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.all(6),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: AppLabels.walletTransaction.tr),
          Tab(text: AppLabels.walletWithdraw.tr),
        ],
        dividerHeight: 0,
        splashBorderRadius: BorderRadius.circular(100),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: context.color.primary,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: context.color.primary,
        ),
        labelStyle: TextStyle(
          color: context.color.primary.getAdaptiveTextColor(),
          fontWeight: FontWeight.w500,
          height: 1.25,
        ),
        unselectedLabelStyle: TextStyle(
          color: context.color.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── Tab 0: Transaction tab ───────────────────────────────────────────────

  Widget _buildTransactionTab() {
    return BlocProvider.value(
      value: _transactionCubit!,
      child: Builder(
        builder: (tabContext) {
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                tabContext.read<FetchWalletHistoryCubit>().fetchMore();
              }
              return true;
            },
            child: RefreshIndicator(
              onRefresh: () {
                context.read<AuthenticationCubit>().refreshUserDetails();
                return tabContext.read<FetchWalletHistoryCubit>().fetch();
              },
              child: CustomScrollView(
                controller: _transactionScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Balance card — Add Money button
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child:
                          BlocBuilder<
                            FetchWalletHistoryCubit,
                            FetchWalletHistoryState
                          >(
                            builder: (context, state) {
                              final bool isLoading =
                                  state is FetchWalletHistoryProgress;
                              return WalletCardWidget(
                                buttonTitle: AppLabels.addMoney.tr,
                                onTapButton: isLoading ? null : _onTapAddMoney,
                                isTotalBalance: true,
                              );
                            },
                          ),
                    ),
                  ),

                  // Pending request note
                  BlocBuilder<FetchWalletHistoryCubit, FetchWalletHistoryState>(
                    builder: (context, state) {
                      if (state is FetchWalletHistorySuccess &&
                          state.isWalletRequestPending) {
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          sliver: SliverToBoxAdapter(
                            child: _buildPendingRequestNote(),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),

                  _buildHistorySlivers(tabContext),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Tab 1: Withdraw tab ──────────────────────────────────────────────────

  Widget _buildWithdrawTab() {
    return BlocProvider.value(
      value: _withdrawCubit!,
      child: Builder(
        builder: (tabContext) {
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                tabContext.read<FetchWalletHistoryCubit>().fetchMore();
              }
              return true;
            },
            child: RefreshIndicator(
              onRefresh: () {
                context.read<AuthenticationCubit>().refreshUserDetails();
                return tabContext.read<FetchWalletHistoryCubit>().fetch();
              },
              child: CustomScrollView(
                controller: _withdrawScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Balance card — Withdraw Money button
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child:
                          BlocBuilder<
                            FetchWalletHistoryCubit,
                            FetchWalletHistoryState
                          >(
                            builder: (context, state) {
                              final bool isPending =
                                  state is FetchWalletHistorySuccess &&
                                  state.isWalletRequestPending;
                              final bool isLoading =
                                  state is FetchWalletHistoryProgress;
                              return WalletCardWidget(
                                buttonTitle: AppLabels.withdrawMoney.tr,
                                onTapButton: (isPending || isLoading)
                                    ? null
                                    : () => _onTapWithdrawMoney(tabContext),
                              );
                            },
                          ),
                    ),
                  ),

                  // Pending request note
                  BlocBuilder<FetchWalletHistoryCubit, FetchWalletHistoryState>(
                    builder: (context, state) {
                      if (state is FetchWalletHistorySuccess &&
                          state.isWalletRequestPending) {
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          sliver: SliverToBoxAdapter(
                            child: _buildPendingRequestNote(),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),

                  _buildHistorySlivers(tabContext),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Android: single page with all transactions ───────────────────────────

  Widget _buildAndroidPage() {
    return BlocProvider.value(
      value: _androidCubit!,
      child: Builder(
        builder: (pageContext) {
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                pageContext.read<FetchWalletHistoryCubit>().fetchMore();
              }
              return true;
            },
            child: RefreshIndicator(
              onRefresh: () {
                context.read<AuthenticationCubit>().refreshUserDetails();
                return pageContext.read<FetchWalletHistoryCubit>().fetch();
              },
              child: CustomScrollView(
                controller: _withdrawScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Balance card — Withdraw Money button
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child:
                          BlocBuilder<
                            FetchWalletHistoryCubit,
                            FetchWalletHistoryState
                          >(
                            builder: (context, state) {
                              final bool isPending =
                                  state is FetchWalletHistorySuccess &&
                                  state.isWalletRequestPending;

                              final bool isLoading =
                                  state is FetchWalletHistoryProgress;

                              return WalletCardWidget(
                                buttonTitle: AppLabels.withdrawMoney.tr,
                                onTapButton: (isPending || isLoading)
                                    ? null
                                    : () => _onTapWithdrawMoney(pageContext),
                              );
                            },
                          ),
                    ),
                  ),

                  // Pending request note
                  BlocBuilder<FetchWalletHistoryCubit, FetchWalletHistoryState>(
                    builder: (context, state) {
                      if (state is FetchWalletHistorySuccess &&
                          state.isWalletRequestPending) {
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          sliver: SliverToBoxAdapter(
                            child: _buildPendingRequestNote(),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),

                  _buildHistorySlivers(pageContext),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _buildHistorySlivers(BuildContext tabContext) {
    return BlocBuilder<FetchWalletHistoryCubit, FetchWalletHistoryState>(
      builder: (context, state) {
        if (state is FetchWalletHistoryProgress) {
          return _buildShimmerLoading();
        }

        if (state is FetchWalletHistoryError) {
          return SliverFillRemaining(
            child: CustomErrorWidget(
              error: UiUtils.friendlyErrorMessage(state.error),
              onRetry: () => tabContext.read<FetchWalletHistoryCubit>().fetch(),
            ),
          );
        }

        if (state is FetchWalletHistorySuccess) {
          if (state.data.isEmpty) {
            return const SliverFillRemaining(
              child: CustomNoDataWidget(
                titleKey: AppLabels.noTransactionsFound,
              ),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: state.data.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == state.data.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return WalletTransactionCard(transaction: state.data[index]);
              },
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox());
      },
    );
  }

  Widget _buildShimmerLoading() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) =>
            const CustomShimmer(height: 150, borderRadius: 12),
      ),
    );
  }

  Widget _buildPendingRequestNote() {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: context.color.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              AppLabels.withdrawalRequestPending.tr,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: context.color.onSurface),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _KeepAliveTab extends StatefulWidget {
  final Widget child;

  const _KeepAliveTab({required this.child});

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
