import 'package:elms/common/cubits/paginated_api_states.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_no_data_widget.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/wishlist/cubit/wishlist_action_cubit.dart';
import 'package:elms/features/wishlist/cubit/wishlist_cubit.dart';
import 'package:elms/features/wishlist/widgets/wishlist_card.dart';
import 'package:elms/features/wishlist/widgets/wishlist_card_shimmer.dart';
import 'package:elms/utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  // Factory method for route generation
  static Widget route() => BlocProvider(
    create: (context) => FetchWishlistCubit(),
    child: const WishlistScreen(),
  );

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final cubit = context.read<FetchWishlistCubit>();
      if (cubit.hasMore && cubit.state is! PaginatedApiLoadingMore) {
        cubit.fetchMoreData();
      }
    }
  }

  void _onTapRefresh() {
    context.read<FetchWishlistCubit>().fetchData();
  }

  void _onRemoveFromWishlist(CourseModel course) {
    context.read<WishlistActionCubit>().toggleWishlist(
      courseId: course.id,
      currentWishlistState:
          true, // Always true since we're removing from wishlist
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WishlistActionCubit, WishlistActionState>(
          listener: (context, state) {
            if (state is WishlistActionInProgress) {
              LoadingOverlay.show();
            } else {
              LoadingOverlay.hide();
            }
            if (state is WishlistActionSuccess && !state.isWishlisted) {
              // Item was successfully removed from wishlist
              context.read<FetchWishlistCubit>().removeItemFromList(
                state.courseId,
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is WishlistActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to remove from wishlist: ${state.error}',
                  ),
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: CustomAppBar(
          title: AppLabels.wishlist.tr,
          showBackButton: true,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _onTapRefresh();
            },
            child: _buildWishlistItems(context),
          ),
        ),
      ),
    );
  }

  Widget _buildWishlistItems(BuildContext context) {
    return BlocBuilder<FetchWishlistCubit, PaginatedApiState>(
      builder: (context, state) {
        if (state is PaginatedApiLoadingState) {
          return const ShimmerBuilder(
            padding: EdgeInsets.all(16),
            spacing: 16,
            shimmer: WishlistCardShimmer(),
          );
        }
        if (state is PaginatedApiFailureState) {
          return CustomErrorWidget(
            error: state.exception.toString(),
            onRetry: _onTapRefresh,
          );
        }

        if (state is PaginatedApiSuccessState<CourseModel>) {
          if (state.data.isEmpty) {
            return const CustomNoDataWidget(
              titleKey: AppLabels.yourWishlistIsEmpty,
            );
          }
          return ListView.separated(
            controller: _scrollController,
            padding: const .all(16),
            itemCount:
                state.data.length +
                (context.read<FetchWishlistCubit>().hasMore ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index >= state.data.length) {
                return const WishlistCardShimmer();
              }
              final CourseModel course = state.data[index];
              return WishlistCard(
                wishlistItem: course,
                onRemoveFromWishlist: () => _onRemoveFromWishlist(course),
              );
            },
          );
        }

        return Container();
      },
    );
  }
}
