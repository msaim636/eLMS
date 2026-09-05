import 'package:elms/common/models/data_class.dart';
import 'package:elms/common/models/review_model.dart';
import 'package:elms/common/models/user_review_model.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/features/course/models/course_review_response_model.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CourseReviewsState {}

class CourseReviewsInitial extends CourseReviewsState {}

class CourseReviewsLoading extends CourseReviewsState {}

class CourseReviewsSuccess extends CourseReviewsState {
  final CourseReviewResponseModel reviewResponse;
  final List<UserReviewModel> reviews;
  final int totalPages;
  final int currentPage;
  final bool isLoadingMore;

  CourseReviewsSuccess({
    required this.reviewResponse,
    required this.reviews,
    required this.totalPages,
    required this.currentPage,
    this.isLoadingMore = false,
  });

  ReviewModel get statistics => reviewResponse.statistics;
  MyReviewModel? get myReview => reviewResponse.myReview;

  CourseReviewsSuccess copyWith({
    CourseReviewResponseModel? reviewResponse,
    List<UserReviewModel>? reviews,
    int? totalPages,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return CourseReviewsSuccess(
      reviewResponse: reviewResponse ?? this.reviewResponse,
      reviews: reviews ?? this.reviews,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class CourseReviewsError extends CourseReviewsState {
  final String error;

  CourseReviewsError({required this.error});
}

class CourseReviewsCubit extends Cubit<CourseReviewsState> {
  final int courseId;

  CourseReviewsCubit({required this.courseId}) : super(CourseReviewsInitial());

  Future<void> fetchReviews() async {
    try {
      emit(CourseReviewsLoading());

      final result = await _fetchReviewsData(page: 1);

      if (!isClosed) {
        emit(
          CourseReviewsSuccess(
            reviewResponse: result.$1,
            reviews: result.$2.data,
            totalPages: result.$2.totalPage,
            currentPage: result.$2.currentPage,
          ),
        );
      }
    } catch (e) {
      if (isClosed) return;
      if (e is AppException) {
        emit(CourseReviewsError(error: e.message ?? e.toString()));
      } else {
        emit(CourseReviewsError(error: e.toString()));
      }
    }
  }

  Future<void> fetchMoreReviews() async {
    if (state is! CourseReviewsSuccess) return;

    final currentState = state as CourseReviewsSuccess;

    if (currentState.isLoadingMore) return;
    if (currentState.currentPage >= currentState.totalPages) return;

    try {
      if (!isClosed) emit(currentState.copyWith(isLoadingMore: true));

      final result = await _fetchReviewsData(
        page: currentState.currentPage + 1,
      );

      final allReviews = [...currentState.reviews, ...result.$2.data];

      if (!isClosed) {
        emit(
          CourseReviewsSuccess(
            reviewResponse: currentState.reviewResponse,
            reviews: allReviews,
            totalPages: result.$2.totalPage,
            currentPage: result.$2.currentPage,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<(CourseReviewResponseModel, PaginatedDataClass<UserReviewModel>)>
  _fetchReviewsData({required int page}) async {
    final Map<String, dynamic> parameters = {
      ApiParams.courseId: courseId,
      ApiParams.page: page,
    }.removeEmptyKeys();

    final Map<String, dynamic> response = await Api.get(
      Apis.getCourseReviews,
      data: parameters,
    );

    final data = response.require<Map<String, dynamic>>(ApiParams.data);

    // Extract review response (course info, statistics, my_review)
    final reviewResponse = CourseReviewResponseModel.fromMap(data);

    // Extract paginated reviews
    final reviewsData = data.require<Map<String, dynamic>>('reviews');
    final paginatedReviews = PaginatedDataClass(
      data: (reviewsData['data'] as List)
          .map((e) => UserReviewModel.fromMap(e))
          .toList(),
      total: reviewsData['total'] ?? 0,
      totalPage: reviewsData['last_page'] ?? 1,
      currentPage: reviewsData['current_page'] ?? 1,
    );

    return (reviewResponse, paginatedReviews);
  }

  void updateMyReview({required int rating, required String review}) {
    if (state is! CourseReviewsSuccess) return;
    final current = state as CourseReviewsSuccess;
    if (current.myReview == null) return;
    final updated = MyReviewModel(
      id: current.myReview!.id,
      rating: rating,
      review: review,
      createdAt: current.myReview!.createdAt,
      timestamp: current.myReview!.timestamp,
      timeAgo: current.myReview!.timeAgo,
      canEdit: current.myReview!.canEdit,
    );
    final newResponse = CourseReviewResponseModel(
      course: current.reviewResponse.course,
      statistics: current.reviewResponse.statistics,
      myReview: updated,
    );
    emit(current.copyWith(reviewResponse: newResponse));
  }

  bool get hasMore {
    if (state is CourseReviewsSuccess) {
      final successState = state as CourseReviewsSuccess;
      return successState.currentPage < successState.totalPages;
    }
    return false;
  }
}
