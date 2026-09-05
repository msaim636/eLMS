import 'package:elms/common/enums.dart';
import 'package:elms/common/repositories/review_repository.dart';
import 'package:elms/common/widgets/ratings_widget.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/review_bottom_sheet.dart';
import 'package:elms/common/widgets/review_shimmer.dart';
import 'package:elms/common/widgets/user_review_widget.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/course/cubit/course_reviews_cubit.dart';
import 'package:elms/features/instructor/widgets/current_user_review.dart';
import 'package:elms/utils/extensions/scroll_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:elms/utils/extensions/context_extension.dart';

class ReviewsScreen extends StatefulWidget {
  final int courseId;

  const ReviewsScreen({super.key, required this.courseId});

  static Widget route([RouteSettings? settings]) {
    final int? courseId = (settings?.arguments ?? Get.arguments) as int?;
    if (courseId == null) {
      throw Exception('ReviewsScreen requires courseId as argument');
    }
    return BlocProvider(
      create: (context) =>
          CourseReviewsCubit(courseId: courseId)..fetchReviews(),
      child: ReviewsScreen(courseId: courseId),
    );
  }

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ScrollController _scrollController = ScrollController();
  final ReviewRepository _reviewRepository = ReviewRepository();
  bool _isDeletingReview = false;

  Future<void> _onTapDeleteReview(int ratingId) async {
    if (_isDeletingReview) return;
    _isDeletingReview = true;
    final cubit = context.read<CourseReviewsCubit>();
    try {
      await _reviewRepository.deleteReview(ratingId: ratingId);
      if (!mounted) return;
      UiUtils.showSnackBar(AppLabels.reviewDeletedSuccessfully.tr);
      await cubit.fetchReviews();
    } catch (e) {
      if (!mounted) return;
      UiUtils.showSnackBar(e.toString(), isError: true);
    } finally {
      _isDeletingReview = false;
    }
  }

  Future<void> _onTapEditReview({
    required num rating,
    required String review,
    required int ratingId,
  }) async {
    final cubit = context.read<CourseReviewsCubit>();
    final result = await UiUtils.showCustomBottomSheet(
      context,
      child: ReviewBottomSheet(
        type: ReviewType.course,
        id: widget.courseId,
        initialRating: rating.toInt(),
        initialReview: review,
      ),
    );
    if (result is Map && mounted) {
      cubit.updateMyReview(
        rating: result['rating'] as int,
        review: result['review'] as String,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.isEndReached) {
      context.read<CourseReviewsCubit>().fetchMoreReviews();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLabels.review.tr, showBackButton: true),
      bottomNavigationBar: BlocBuilder<CourseReviewsCubit, CourseReviewsState>(
        builder: (context, state) {
          if (state is CourseReviewsSuccess && state.myReview != null) {
            return const SizedBox.shrink();
          }
          return BottomAppBar(
            padding: const .symmetric(horizontal: 16, vertical: 8),
            height: kBottomNavigationBarHeight,
            child: CustomButton(
              radius: 4,
              title: AppLabels.addReview.tr,
              onPressed: () async {
                final result = await UiUtils.showCustomBottomSheet(
                  context,
                  child: ReviewBottomSheet(
                    type: ReviewType.course,
                    id: widget.courseId,
                  ),
                );
                if (result is Map && context.mounted) {
                  await context.read<CourseReviewsCubit>().fetchReviews();
                }
              },
            ),
          );
        },
      ),
      body: BlocBuilder<CourseReviewsCubit, CourseReviewsState>(
        builder: (context, state) {
          if (state is CourseReviewsLoading) {
            return _buildLoadingState();
          }

          if (state is CourseReviewsSuccess) {
            return _buildSuccessState(state);
          }

          if (state is CourseReviewsError) {
            return _buildErrorState(state.error);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SingleChildScrollView(
      padding: .all(16),
      child: Column(
        spacing: 16,
        children: [
          CustomShimmer(height: 120, width: double.infinity, borderRadius: 8),
          ReviewsListShimmer(itemCount: 5),
        ],
      ),
    );
  }

  Widget _buildSuccessState(CourseReviewsSuccess state) {
    final otherReviews = state.myReview != null
        ? state.reviews.where((r) => r.id != state.myReview!.id).toList()
        : state.reviews;
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const .all(16),
      child: Column(
        spacing: 16,
        children: [
          RatingsWidget(
            reviewData: state.statistics,
            ratingTitle: AppLabels.courseReviews.tr,
          ),
          if (state.myReview != null)
            CurrentUserReview(
              myReview: state.myReview!,
              onEdit: () => _onTapEditReview(
                rating: state.myReview!.rating,
                review: state.myReview!.review,
                ratingId: state.myReview!.id,
              ),
              onDelete: () => _onTapDeleteReview(state.myReview!.id),
            ),
          if (otherReviews.isNotEmpty)
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: otherReviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return UserReviewWidget(review: otherReviews[index]);
              },
            )
          else if (state.myReview == null)
            Padding(
              padding: const .all(32),
              child: CustomText(
                AppLabels.noReviewsYet.tr,
                textAlign: .center,
                style: TextStyle(fontSize: context.font.medium),
              ),
            ),
          if (state.isLoadingMore)
            const Padding(
              padding: .all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return CustomErrorWidget(
      error: error,
      onRetry: () {
        context.read<CourseReviewsCubit>().fetchReviews();
      },
    );
  }
}
