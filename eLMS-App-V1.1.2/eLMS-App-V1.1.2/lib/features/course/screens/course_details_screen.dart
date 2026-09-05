import 'dart:async';
import 'package:elms/common/enums.dart';
import 'package:elms/common/models/course_details_model.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_no_data_widget.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/restricted_widget.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/login/guest_checker.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/cart/cubit/cart_cubit.dart';
import 'package:elms/features/coupon/cubits/apply_coupon_cubit.dart';
import 'package:elms/features/course/cubit/course_details_cubit.dart';
import 'package:elms/features/course/cubit/course_reviews_cubit.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/features/course/widgets/course_details_appbar.dart';
import 'package:elms/features/instructor/models/instructor_details_model.dart';
import 'package:elms/features/instructor/repository/instructor_repository.dart';
import 'package:elms/features/video_player/bloc/video_player_bloc.dart';
import 'package:elms/features/video_player/video_player.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:elms/utils/loader.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:elms/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:elms/features/course/widgets/certificate_widget.dart';
import 'package:elms/features/course/widgets/chapters_list_section.dart';
import 'package:elms/features/course/widgets/coupon_section_widget.dart';
import 'package:elms/features/course/widgets/course_overview_widget.dart';
import 'package:elms/common/widgets/reviews_widget.dart';
import 'package:elms/common/widgets/review_shimmer.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/features/course/widgets/instructor_card_widget.dart';
import 'package:elms/features/settings/cubit/app_settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CourseDetailsScreen extends StatefulWidget {
  final CourseModel course;
  final CourseDetailsModel? courseDetails;
  final String? slug;
  const CourseDetailsScreen({
    super.key,
    required this.course,
    this.courseDetails,
    this.slug,
  });

  static Widget route() {
    final CourseDetailsScreenArguments args =
        Get.arguments as CourseDetailsScreenArguments;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CourseDetailsCubit(CourseRepository()),
        ),
        BlocProvider(
          create: (context) =>
              CourseReviewsCubit(courseId: args.course.id)..fetchReviews(),
        ),
        BlocProvider(create: (context) => ApplyCouponCubit()),
      ],
      child: CourseDetailsScreen(
        course: args.course,
        courseDetails: args.course is CourseDetailsModel
            ? args.course as CourseDetailsModel
            : null,
        slug: args.slug,
      ),
    );
  }

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final TextEditingController _couponController = TextEditingController();

  int? selectedCouponId;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();

    if (widget.courseDetails != null) {
      context.read<CourseDetailsCubit>().setInitialData(widget.courseDetails!);
    } else {
      context.read<CourseDetailsCubit>().fetchCourseDetails(
        widget.course,
        slug: widget.slug,
      );
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
          buildWhen: (prev, curr) {
            final prevWish = prev is CourseDetailsSuccess
                ? prev.data.isWishlisted
                : widget.course.isWishlisted;
            final currWish = curr is CourseDetailsSuccess
                ? curr.data.isWishlisted
                : widget.course.isWishlisted;
            return prevWish != currWish;
          },
          builder: (context, state) {
            final bool isWishlisted = state is CourseDetailsSuccess
                ? state.data.isWishlisted
                : widget.course.isWishlisted;
            return CourseDetailsAppBar(
              course: widget.course,
              isWishlisted: isWishlisted,
            );
          },
        ),
      ),
      body: BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
        builder: (BuildContext context, CourseDetailsState state) {
          if (state is CourseDetailsProgress) {
            return _buildContent(
              state.initialData ??
                  CourseDetailsModel.fromCourseModel(widget.course),
              isLoading: true,
            );
          }

          if (state is CourseDetailsSuccess) {
            return _buildContent(state.data);
          }

          if (state is CourseDetailsError) {
            return _buildErrorWidget(state);
          }

          return _buildContent(
            CourseDetailsModel.fromCourseModel(widget.course),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildContent(
    CourseDetailsModel courseDetails, {
    bool isLoading = false,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const .symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: .start,
          spacing: 16,
          children: [
            _buildVideoPlayer(courseDetails),
            _buildCourseDetails(courseDetails, isLoading: isLoading),
            if (context.read<AppSettingsCubit>().isMultiInstructorMode) ...{
              if (courseDetails.instructor != null &&
                  courseDetails.instructor?.name != "admin")
                GestureDetector(
                  onTap: () {
                    LoadingOverlay.execute(() async {
                      final InstructorDetailsModel instructor =
                          await InstructorRepository().fetchInstructorDetails(
                            id: courseDetails.instructor!.instructorId
                                .toString(),
                          );
                      unawaited(
                        Get.toNamed(
                          AppRoutes.instructorDetailsScreen,
                          arguments: instructor,
                        ),
                      );
                    });
                  },
                  child: InstructorCardWidget(
                    instructor: courseDetails.instructor!.toInstructorModel(),
                  ),
                ),

              if (courseDetails.instructor?.name == "admin")
                CustomCard(
                  padding: const EdgeInsetsGeometry.all(16),
                  width: double.maxFinite,
                  child: CustomText(
                    AppLabels.addedByAdmin.tr,
                    style: TextStyle(fontSize: context.font.small),
                  ),
                ),
            },

            if (!courseDetails.isFree)
              CouponSelectorWidget(
                target: CouponListTarget.course,
                courseId: courseDetails.id,
                onApplyCoupon: _onApplyCoupon,
                onCouponApplied: (value) {
                  selectedCouponId = value.promoDiscounts.first.promoCodeId;
                },
              ),
            _buildCertificateWidget(),
            _buildChaptersSection(courseDetails, isLoading: isLoading),
            _buildReviewsSection(),
            if (isLoading)
              const Padding(
                padding: .all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(CourseDetailsError state) {
    return CustomErrorWidget.fromErrorState(
      errorState: state,
      onRetry: () {
        context.read<CourseDetailsCubit>().fetchCourseDetails(widget.course);
      },
    );
  }

  Widget _buildVideoPlayer(CourseDetailsModel courseDetails) {
    final introVideo = courseDetails.previewVideos
        .where((video) => video.type?.toLowerCase() == 'intro')
        .firstOrNull;

    final bool hasVideo =
        introVideo != null && (introVideo.fileUrl?.isNotEmpty ?? false);

    // Once the user taps play, swap the banner for the actual video player
    if (_isVideoPlaying && hasVideo) {
      return BlocProvider(
        create: (context) => VideoPlayerBloc(),
        child: CustomVideoPlayer(url: introVideo.fileUrl!, autoPlay: true),
      );
    }

    // Banner: thumbnail with an optional play button overlay
    final String thumbnailUrl = introVideo?.thumbnail?.isNotEmpty == true
        ? introVideo!.thumbnail!
        : courseDetails.image;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomImage(thumbnailUrl, fit: BoxFit.cover),
            if (hasVideo)
              GestureDetector(
                onTap: () => setState(() => _isVideoPlaying = true),
                child: Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseDetails(
    CourseDetailsModel courseDetails, {
    bool isLoading = false,
  }) {
    final int hours = ((courseDetails.totalDuration / 60) / 60).toInt();
    final Map<String, String> courseDetailsMap = {
      if (courseDetails.totalDuration > 0)
        'duration': hours.toString().getDurationLabel,
      'chapters': (courseDetails.chapterCount > 1)
          ? AppLabels.courseChaptersCount.translateWithTemplate({
              'count': courseDetails.chapterCount.toString(),
            })
          : AppLabels.courseChapterCount.translateWithTemplate({
              'count': courseDetails.chapterCount.toString(),
            }),
      'lectures': (courseDetails.lectureCount > 1)
          ? AppLabels.courseLecturesCount.translateWithTemplate({
              'count': courseDetails.lectureCount.toString(),
            })
          : AppLabels.courseLectureCount.translateWithTemplate({
              'count': courseDetails.lectureCount.toString(),
            }),
      'rating': courseDetails.ratings == 0
          ? AppLabels.courseNoRatings.tr
          : AppLabels.courseRating.translateWithTemplate({
              'rating': courseDetails.averageRating.ratingLabel,
              'count': courseDetails.ratings.toString(),
            }),
      'language': courseDetails.language.isNotEmpty
          ? AppLabels.courseTaughtIn.translateWithTemplate({
              'language': courseDetails.language,
            })
          : AppLabels.courseLanguage.tr,
      'access': courseDetails.level.isNotEmpty
          ? courseDetails.level.capitalize ?? ''
          : AppLabels.courseLevelAdvanced.tr,
    };

    final String overview =
        courseDetails.description ?? courseDetails.shortDescription;

    final List<String> learningPoints = courseDetails.learnings
        .map((learning) => learning.title)
        .toList();

    final List<String> requirements = courseDetails.requirements
        .map((requirement) => requirement.requirement)
        .toList();

    return CourseOverviewWidget(
      level: courseDetails.level.isNotEmpty
          ? courseDetails.level
          : AppLabels.courseLevelAdvanced.tr,
      isFree: courseDetails.isFree,
      category: courseDetails.categoryName ?? '',
      currentPrice: courseDetails.subtotal,
      originalPrice: courseDetails.originalPrice,
      title: courseDetails.title,
      courseDetails: courseDetailsMap,
      overview: overview,
      learningPoints: learningPoints,
      requirements: requirements,
      isLoading: isLoading,
    );
  }

  Widget _buildBottomBar() {
    return BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
      builder: (context, courseState) {
        final CourseDetailsModel courseDetails;

        if (courseState is CourseDetailsSuccess) {
          courseDetails = courseState.data;
        } else {
          courseDetails = CourseDetailsModel.fromCourseModel(widget.course);
        }

        final bool isFree = courseDetails.isFree;

        return ColoredBox(
          color: context.color.surface,
          child: Padding(
            padding: const .all(16),
            child: Row(
              spacing: 16,
              children: [
                Expanded(
                  child: CustomButton(
                    title: AppLabels.enrollNow.tr,
                    onPressed: _onEnrollTap,
                  ),
                ),
                if (!isFree)
                  Expanded(
                    child: BlocConsumer<CartCubit, CartState>(
                      listenWhen: (previous, current) =>
                          previous is UpdateCartInProgress &&
                          current is CartSuccess,
                      listener: (context, state) {
                        if (state is CartSuccess &&
                            state.isAddedInCart(widget.course.id)) {
                          UiUtils.showSnackBar(
                            AppLabels.courseAddedToCart.tr,
                            mainButton: TextButton(
                              onPressed: () {
                                Get.back();
                                Get.toNamed(AppRoutes.cartScreen);
                              },
                              child: CustomText(
                                AppLabels.goToCart.tr,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        final bool isAddedInCart = context
                            .read<CartCubit>()
                            .isAddedInCart(widget.course.id);
                        return CustomButton(
                          title: isAddedInCart
                              ? AppLabels.removeFromCart.tr
                              : AppLabels.addToCart.tr,
                          onPressed: state is UpdateCartInProgress
                              ? null
                              : _onCartToggle,
                          isLoading: state is UpdateCartInProgress,
                          type: CustomButtonType.outlined,
                          borderColor: context.color.primary,
                          textColor: context.color.primary,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onApplyCoupon(String couponCode) {
    GuestChecker.check(
      onNotGuest: () {
        if (couponCode.isNotEmpty) {
          context.read<ApplyCouponCubit>().applyCouponByCode(
            code: couponCode,
            courseId: widget.course.id,
          );
        }
      },
    );
  }

  void _onViewAllReviewsTap() {
    Get.toNamed(AppRoutes.reviewsScreen, arguments: widget.course.id);
  }

  Widget _buildReviewsSection() {
    return BlocBuilder<CourseReviewsCubit, CourseReviewsState>(
      builder: (context, state) {
        if (state is CourseReviewsLoading) {
          return const Column(
            spacing: 16,
            children: [
              CustomShimmer(
                height: 120,
                width: double.infinity,
                borderRadius: 8,
              ),
              ReviewsListShimmer(itemCount: 2),
            ],
          );
        }

        if (state is CourseReviewsSuccess) {
          return ReviewsWidget(
            reviewData: state.statistics,
            userReviews: state.reviews.take(3).toList(),
            onViewAllReviewsTap: _onViewAllReviewsTap,
          );
        }

        return const SizedBox();
      },
    );
  }

  void _onEnrollTap() {
    GuestChecker.check(
      onNotGuest: () {
        // Guard: if wallet is negative (iOS refund), block new purchases.
        final balance = context.read<AuthenticationCubit>().totalBalance ?? 0;
        if (balance < 0) {
          NegativeWalletPurchaseDialog.show(context);
          return;
        }

        Get.toNamed(
          AppRoutes.checkoutScreen,
          arguments: {
            'checkoutType': CheckoutType.directEnroll,
            'courseId': widget.course.id,
            "promocodeId": selectedCouponId,
          },
        );
      },
    );
  }

  void _onCartToggle() {
    GuestChecker.check(
      onNotGuest: () {
        context.read<CartCubit>().toggleCart(widget.course.id);
      },
    );
  }

  Widget _buildCertificateWidget() {
    return CustomCard(
      padding: const .all(8),
      child: Column(
        spacing: 8,
        children: [
          CustomText(
            AppLabels.enterOrPurchaseCertificate.tr,
            fontSize: context.font.large,
            fontWeight: .w500,
          ),
          CustomText(
            AppLabels.certificateSectionDescription.tr,
            style: TextStyle(fontSize: context.font.small),
            fontWeight: .w400,
            color: context.color.textSecondary,
            textAlign: .center,
          ),
          const CertificateWidget(
            height: 234,
            certificateImage: 'assets/images/certificate_bg.png',
          ),
        ],
      ),
    );
  }

  Widget _buildChaptersSection(
    CourseDetailsModel courseDetails, {
    bool isLoading = false,
  }) {
    if (isLoading) {
      return const Column(
        spacing: 8,
        children: [
          CustomShimmer(height: 20, width: double.infinity),
          CustomShimmer(height: 56, width: double.infinity),
          CustomShimmer(height: 56, width: double.infinity),
          CustomShimmer(height: 56, width: double.infinity),
        ],
      );
    }

    final chapters = courseDetails.chapters;
    if (chapters.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          CustomText(
            AppLabels.courseContent.tr,
            style: TextStyle(
              fontSize: context.font.xxLarge,
              fontWeight: FontWeight.w500,
              color: context.color.onSurface,
            ),
          ),
          const CustomNoDataWidget(
            titleKey: AppLabels.noCurriculumFound,
            illustratorSize: 140,
          ),
        ],
      );
    }

    final cubit = context.read<CourseDetailsCubit>();
    final duration = cubit.getFormattedDuration();
    final bool hasDuration = duration.isNotEmpty && duration != '0s';
    final String title =
        "${Utils.pluralize(chapters.length, singular: AppLabels.chapter, plural: AppLabels.chapters)}${hasDuration ? ' ($duration)' : ''}";
    return ChaptersListSection(
      chapters: chapters,
      title: title,
      sequentialAccess: courseDetails.sequentialAccess,
      isEnrolled: widget.course.isEnrolled,
      currentCurriculumId: courseDetails.currentCurriculum?.modelId,
      currentChapterId: courseDetails.currentCurriculum?.chapterId,
      shrinkWrap: true,
    );
  }
}
