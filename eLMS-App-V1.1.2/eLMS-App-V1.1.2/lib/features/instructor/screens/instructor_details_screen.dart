import 'package:elms/common/enums.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/models/instructor_model.dart';
import 'package:elms/common/models/review_model.dart';
import 'package:elms/common/repositories/review_repository.dart';
import 'package:elms/common/widgets/animated_showmore_container.dart';
import 'package:elms/common/widgets/course_card.dart';
import 'package:elms/common/widgets/ratings_widget.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/video_banner_container.dart';
import 'package:elms/common/widgets/review_bottom_sheet.dart';
import 'package:elms/common/widgets/tappable_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/login/guest_checker.dart';
import 'package:elms/features/instructor/cubit/instructor_details_cubit.dart';
import 'package:elms/features/instructor/models/instructor_details_model.dart';
import 'package:elms/features/instructor/widgets/current_user_review.dart';
import 'package:elms/features/instructor/widgets/instructor_social_media.dart';
import 'package:elms/features/instructor/widgets/instructor_stats_widget.dart';
import 'package:elms/features/video_player/bloc/video_player_bloc.dart';
import 'package:elms/features/video_player/video_player.dart';
import 'package:elms/utils/course_navigation_helper.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class InstructorDetailsScreen extends StatefulWidget {
  final InstructorModel instructor;
  const InstructorDetailsScreen({super.key, required this.instructor});

  static Widget route() {
    final InstructorModel instructor = (Get.arguments) as InstructorModel;
    return BlocProvider(
      create: (context) => InstructorDetailsCubit(),
      child: InstructorDetailsScreen(instructor: instructor),
    );
  }

  @override
  State<InstructorDetailsScreen> createState() =>
      _InstructorDetailsScreenState();
}

class _InstructorDetailsScreenState extends State<InstructorDetailsScreen> {
  final ReviewRepository _reviewRepository = ReviewRepository();
  bool _isVideoPlaying = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<InstructorDetailsCubit>().fetchInstructorDetails(
          id: widget.instructor.id.toString(),
        );
      }
    });
    super.initState();
  }

  Future<void> _onTapDeleteReview(int ratingId) async {
    try {
      final cubit = context.read<InstructorDetailsCubit>();
      await _reviewRepository.deleteReview(ratingId: ratingId);
      if (!mounted) return;

      UiUtils.showSnackBar(AppLabels.reviewDeletedSuccessfully.tr);
      // Refresh instructor details to update UI without showing loading
      await cubit.fetchInstructorDetails(
        id: widget.instructor.id.toString(),
        skipProgress: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _onTapEditReview({
    required num rating,
    required String review,
  }) async {
    final cubit = context.read<InstructorDetailsCubit>();
    final result = await UiUtils.showCustomBottomSheet(
      context,
      child: ReviewBottomSheet(
        type: ReviewType.instructor,
        id: widget.instructor.id,
        initialRating: rating.toInt(),
        initialReview: review,
      ),
    );

    if (result is Map && mounted) {
      await cubit.fetchInstructorDetails(
        id: widget.instructor.id.toString(),
        skipProgress: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLabels.instructorProfile.tr,
        showBackButton: true,
      ),
      body: BlocBuilder<InstructorDetailsCubit, BaseState>(
        builder: (context, state) {
          if (state is SuccessDataState<InstructorDetailsModel>) {
            return SingleChildScrollView(
              child: Padding(
                padding: const .all(16.0),
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 16,
                  children: [
                    _buildPreviewVideo(state.data),
                    _buildInstructorHeader(context),
                    _buildInstructorStats(context),
                    _buildSocialMedia(context),
                    _buildDivider(context),
                    _buildAboutMe(context),
                    if (widget.instructor.qualification != null &&
                        widget.instructor.qualification!.isNotEmpty) ...[
                      _buildQualificationsSection(context),
                    ],
                    if (widget.instructor.skills != null &&
                        widget.instructor.skills!.isNotEmpty) ...[
                      _buildSkillsSection(context),
                    ],

                    if (state.data.reviewCount > 0) ...[
                      _buildDivider(context),

                      CustomText(
                        AppLabels.reviews.tr,
                        fontSize: context.font.large,
                        fontWeight: .w500,
                      ),
                      _buildReviews(context),
                      _buildLeaveReviewButton(context),
                    ],
                    if (state.data.courses.isNotEmpty) ...[
                      _buildDivider(context),
                      _buildCourses(state.data.courses),
                    ],
                  ],
                ),
              ),
            );
          } else if (state is ErrorState) {
            return Center(
              child: CustomErrorWidget(
                error: UiUtils.friendlyErrorMessage(state.error),
                onRetry: () {
                  context.read<InstructorDetailsCubit>().fetchInstructorDetails(
                    id: widget.instructor.id.toString(),
                  );
                },
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildPreviewVideo(InstructorDetailsModel instructorDetails) {
    final String? previewVideoUrl = instructorDetails.previewVideo;
    final bool hasVideo = previewVideoUrl != null && previewVideoUrl.isNotEmpty;

    if (_isVideoPlaying && hasVideo) {
      return BlocProvider(
        create: (context) => VideoPlayerBloc(),
        child: CustomVideoPlayer(url: previewVideoUrl, autoPlay: true),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: VideoBannerContainer(
        url: instructorDetails.profile,
        radius: 12,
        hideControlIcons: !hasVideo,
        onTap: hasVideo ? () => setState(() => _isVideoPlaying = true) : null,
      ),
    );
  }

  Widget _buildInstructorHeader(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: .start,
        spacing: 16,
        children: [
          Container(
            width: 71,
            height: 71,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: context.color.outline),
            ),
            child: TappableImage(
              widget.instructor.profile,
              fit: BoxFit.cover,
              radius: 4,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .spaceEvenly,
              children: [
                CustomText(
                  widget.instructor.displayName,
                  fontWeight: .w600,
                  fontSize: context.font.xLarge,
                ),
                CustomText(
                  widget.instructor.qualification?.stripHtmlTags ?? '',
                  fontSize: context.font.small,
                  fontWeight: .w400,
                  maxLines: 2,
                  ellipsis: true,
                  color: context.color.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveReviewButton(BuildContext context) {
    return CustomButton(
      title: AppLabels.leaveReview.tr,
      onPressed: () async {
        GuestChecker.check(
          onNotGuest: () async {
            final cubit = context.read<InstructorDetailsCubit>();
            final result = await UiUtils.showCustomBottomSheet(
              context,
              child: ReviewBottomSheet(
                type: ReviewType.instructor,
                id: widget.instructor.id,
              ),
            );

            if (result is Map && mounted) {
              await cubit.fetchInstructorDetails(
                id: widget.instructor.id.toString(),
                skipProgress: true,
              );
            }
          },
        );
      },
      fullWidth: true,
      radius: 4,
    );
  }

  Widget _buildInstructorStats(BuildContext context) {
    return BlocBuilder<InstructorDetailsCubit, BaseState>(
      builder: (context, state) {
        if (state is SuccessDataState<InstructorDetailsModel>) {
          return CustomCard(
            padding: const .symmetric(horizontal: 10, vertical: 8),
            borderColor: Colors.transparent,
            child: InstructorStatsWidget(
              studentsCount: state.data.studentEnrolledCount,
              coursesCount: state.data.activeCoursesCount,
              reviewsCount: state.data.reviewCount,
              rating: state.data.averageRating.toDouble(),
            ),
          );
        }
        return const CustomCard(
          padding: .symmetric(horizontal: 10, vertical: 8),
          borderColor: Colors.transparent,
          child: InstructorStatsWidget(
            studentsCount: 0,
            coursesCount: 0,
            reviewsCount: 0,
            rating: 0,
          ),
        );
      },
    );
  }

  Widget _buildSocialMedia(BuildContext context) {
    return BlocBuilder<InstructorDetailsCubit, BaseState>(
      builder: (context, state) {
        if (state is SuccessDataState<InstructorDetailsModel>) {
          return Column(
            crossAxisAlignment: .start,
            children: [
              if (state.data.socialMedias.isNotEmpty)
                Row(
                  children: [
                    CustomText(
                      AppLabels.followMe.tr,
                      style: TextStyle(fontSize: context.font.small),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: InstructorSocialMedia(
                        socialMedias: state.data.socialMedias,
                      ),
                    ),
                  ],
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(color: context.color.outline, height: 1);
  }

  Widget _buildAboutMe(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          'About Me',
          style: TextStyle(
            fontSize: context.font.medium,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedShowMore(
          content: widget.instructor.aboutMe?.stripHtmlTags,
          maxLines: 4,
          textStyle: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: context.color.onSurface),
          textColor: context.color.primary,
        ),
      ],
    );
  }

  Widget _buildReviews(BuildContext context) {
    final state = context.read<InstructorDetailsCubit>().state;
    if (state is! SuccessDataState<InstructorDetailsModel>) {
      return Container();
    }

    final List<InstructorRatingModel> ratings = state.data.ratings;
    final ReviewModel reviewData = _computeReviewData(state.data);

    return Column(
      crossAxisAlignment: .start,
      spacing: 16,
      children: [
        RatingsWidget(
          reviewData: reviewData,
          ratingTitle: AppLabels.reviews.tr,
        ),
        if (state.data.myReview != null)
          CurrentUserReview(
            myReview: state.data.myReview!,

            onDelete: () => _onTapDeleteReview(state.data.myReview!.id),
            onEdit: () => _onTapEditReview(
              rating: state.data.myReview!.rating,
              review: state.data.myReview!.review,
            ),
          ),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: ratings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildInstructorReviewCard(ratings[index], index);
          },
        ),
      ],
    );
  }

  ReviewModel _computeReviewData(InstructorDetailsModel data) {
    // Count ratings by star level
    int fiveStars = 0;
    int fourStars = 0;
    int threeStars = 0;
    int twoStars = 0;
    int oneStar = 0;

    for (final rating in data.ratings) {
      final ratingValue = rating.rating.round();
      if (ratingValue == 5) {
        fiveStars++;
      } else if (ratingValue == 4) {
        fourStars++;
      } else if (ratingValue == 3) {
        threeStars++;
      } else if (ratingValue == 2) {
        twoStars++;
      } else if (ratingValue == 1) {
        oneStar++;
      }
    }

    final totalRatings = data.ratings.length;

    // Compute percentages
    final num fiveStarsPercentage = totalRatings > 0
        ? ((fiveStars / totalRatings) * 100).round()
        : 0;
    final num fourStarsPercentage = totalRatings > 0
        ? ((fourStars / totalRatings) * 100).round()
        : 0;
    final num threeStarsPercentage = totalRatings > 0
        ? ((threeStars / totalRatings) * 100).round()
        : 0;
    final num twoStarsPercentage = totalRatings > 0
        ? ((twoStars / totalRatings) * 100).round()
        : 0;
    final num oneStarPercentage = totalRatings > 0
        ? ((oneStar / totalRatings) * 100).round()
        : 0;

    return ReviewModel(
      averageRating: data.averageRating.toDouble(),
      totalReviews: data.reviewCount,
      ratingDistribution: RatingDistribution(
        fiveStars: fiveStars,
        fourStars: fourStars,
        threeStars: threeStars,
        twoStars: twoStars,
        oneStar: oneStar,
        fiveStarsPercentage: fiveStarsPercentage,
        fourStarsPercentage: fourStarsPercentage,
        threeStarsPercentage: threeStarsPercentage,
        twoStarsPercentage: twoStarsPercentage,
        oneStarPercentage: oneStarPercentage,
      ),
    );
  }

  Widget _buildInstructorReviewCard(InstructorRatingModel rating, int index) {
    return CustomCard(
      padding: const .all(8),

      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              _buildReviewerAvatar(rating.userProfile, rating.id, index),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    CustomText(
                      rating.userName,
                      style: TextStyle(
                        fontSize: context.font.small,
                        fontWeight: .w600,
                        color: context.color.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      rating.createdAt.toFormattedDate,
                      style: TextStyle(
                        fontSize: context.font.xSmall,
                        color: context.color.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const .symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.color.warning,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: .min,
                  children: [
                    CustomImage(
                      AppIcons.starFilled,
                      width: 13,
                      height: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    CustomText(
                      rating.rating.ratingLabel,
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge!.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomText(
            rating.review,
            style: TextStyle(
              fontSize: context.font.small,
              color: context.color.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewerAvatar(String avatarUrl, int ratingId, int index) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: .circle,
        border: Border.all(color: context.color.onSurface, width: 0.83),
      ),
      padding: const .all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: TappableImage(avatarUrl, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildQualificationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        CustomText(
          AppLabels.qualifications.tr,
          fontWeight: FontWeight.w600,
          fontSize: context.font.medium,
        ),
        CustomText(
          widget.instructor.qualification!.stripHtmlTags,
          style: TextStyle(
            fontSize: context.font.small,
            color: context.color.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    final skills = widget.instructor.skills!
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        CustomText(
          AppLabels.mySkills.tr,
          fontWeight: FontWeight.w600,
          fontSize: context.font.medium,
        ),
        ...skills.map(
          (skill) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                '• ',
                style: TextStyle(
                  fontSize: context.font.small,
                  color: context.color.onSurface,
                ),
              ),
              Expanded(
                child: CustomText(
                  skill,
                  style: TextStyle(
                    fontSize: context.font.small,
                    color: context.color.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourses(List<CourseModel> courses) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          AppLabels.myCourses.tr,
          style: TextStyle(
            fontSize: context.font.medium,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: courses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return CourseCard.horizontal(
              course: courses[index],
              height: 200,
              onTap: () async {
                await CourseNavigationHelper.navigateToCourse(
                  courses[index],
                  context: context,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
