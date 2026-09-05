import 'dart:async';

import 'package:elms/common/models/course_list_dataclass.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_icon_button.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/common/widgets/profile_card.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/login/guest_checker.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/notification/notification_manager.dart';
import 'package:elms/features/category/cubits/fetch_category_cubit.dart';
import 'package:elms/features/cart/widgets/cart_bottom_inset.dart';
import 'package:elms/features/category/widgets/category_shimmer.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/features/explore/cubit/explore_cubit.dart';
import 'package:elms/features/home/cubits/fetch_featured_sections_cubit.dart';
import 'package:elms/features/home/cubits/fetch_slider_cubit.dart';
import 'package:elms/features/home/models/featured_section_model.dart';
import 'package:elms/features/home/models/slider_model.dart';
import 'package:elms/features/home/widgets/course_sections.dart';
import 'package:elms/features/home/widgets/featured_section_shimmer.dart';
import 'package:elms/features/home/widgets/slider_shimmer.dart';
import 'package:elms/features/instructor/cubit/instructor_details_cubit.dart';
import 'package:elms/features/instructor/models/instructor_details_model.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/category_card.dart';
import 'package:elms/common/models/category_model.dart';
import 'package:elms/features/home/widgets/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static Widget route() => const HomeScreen();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();

  bool showVideoPlayer = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTapSearch() {
    Get.toNamed(AppRoutes.searchScreen);
  }

  Future<void> _onTapSlider(SliderModel slider) async {
    // Handle custom_link type using value field
    if (slider.type == 'custom_link') {
      if (slider.value.isNotEmpty) {
        final uri = Uri.parse(slider.value);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
      return;
    }

    // Handle course type navigation
    if (slider.type == 'course' && slider.modelId != null) {
      try {
        // Fetch course details using repository
        final repository = CourseRepository();
        final courseDetails = await repository.fetchCourseDetails(
          courseId: slider.modelId!,
        );

        // Navigate to course details screen
        await Get.toNamed(
          AppRoutes.courseDetailsScreen,
          arguments: CourseDetailsScreenArguments(course: courseDetails),
        );
      } catch (e) {
        return;
      }
      return;
    }

    // Handle instructor type navigation
    if (slider.type == 'instructor' && slider.modelId != null) {
      try {
        // Create cubit and fetch instructor details
        final cubit = InstructorDetailsCubit();
        await cubit.fetchInstructorDetails(id: slider.modelId.toString());

        // Check if fetch was successful
        final state = cubit.state;
        if (state is SuccessDataState<InstructorDetailsModel>) {
          final instructor = state.data;

          // Navigate to instructor details screen
          // InstructorDetailsModel extends InstructorModel, so we can pass it directly
          await Get.toNamed(
            AppRoutes.instructorDetailsScreen,
            arguments: instructor,
          );
        }

        await cubit.close();
      } catch (e) {
        return;
      }
      return;
    }
  }

  @override
  void initState() {
    context.read<FetchSliderCubit>().fetch();

    context.read<FetchFeaturedSectionsCubit>().fetch();
    context.read<ExploreCubit>().fetch();
    // Request notification permission and initialize if granted
    NotificationManager.requestPermissionAndInit();

    super.initState();
  }

  Future<void> _onRefresh() async {
    unawaited(context.read<FetchCategoryCubit>().fetch());
    unawaited(context.read<FetchSliderCubit>().fetch());
    unawaited(context.read<FetchFeaturedSectionsCubit>().fetch());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.read<FetchFeaturedSectionsCubit>().fetch();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          height: kToolbarHeight + 20,
          customTitle: const ProfileCard(),
          actions: [
            CustomIconButton(
              image: AppIcons.notification,
              color: context.color.onSurface,
              onTap: () {
                GuestChecker.check(
                  onNotGuest: () {
                    Get.toNamed(AppRoutes.notificationScreen);
                  },
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SizedBox(
            height: double.maxFinite,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsetsDirectional.only(
                bottom: 10 + context.cartBottomInset,
              ),
              child: Column(
                crossAxisAlignment: .start,
                spacing: 7,
                children: [
                  _buildSearchBar(),
                  _buildBanner(),
                  _buildCategoriesSection(context),
                  BlocBuilder<
                    FetchFeaturedSectionsCubit,
                    FetchFeaturedSectionsState
                  >(
                    builder: (context, state) {
                      if (state is FetchFeaturedSectionsFail) {
                        return CustomErrorWidget(error: state.error);
                      }

                      if (state is FetchFeaturedSectionsSuccess) {
                        return Sections(
                          sections: List.generate(state.data.length, (
                            int index,
                          ) {
                            final FeaturedSectionModel section =
                                state.data[index];

                            ///horizontal course cards
                            if (section.type == 'newly_added_courses') {
                              return HorizontalCourseSection(section);
                            }
                            if (section.type == 'my_learning') {
                              return MyLearningSection(section: section);
                            } else if (section.type == 'top_rated_courses' ||
                                section.type == 'free_courses' ||
                                section.type == 'most_viewed_courses' ||
                                section.type == 'searching_based' ||
                                section.type == 'wishlist' ||
                                section.type == 'recommend_for_you') {
                              return VerticalCourseSection(section);
                            } else if (section.type ==
                                'top_rated_instructors') {
                              return InstructorListSection(section: section);
                            } else {
                              return UnsupportedSection();
                            }
                          }),
                        );
                      }
                      return const FeaturedSectionShimmer();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return BlocBuilder<FetchCategoryCubit, FetchCategoryState>(
      builder: (context, state) {
        ///
        final List<CategoryModel> categories =
            ((state is FetchCategorySuccess) ? state.data : <CategoryModel>[])
                .take(4)
                .toList();

        if (categories.isNotEmpty || state is FetchCategoryInProgress) {
          return _buildSection<CategoryModel>(
            title: AppLabels.categories.tr,
            items: categories,
            spacing: 8,
            isLoading: state is FetchCategoryInProgress,
            shimmerBuilder: () => const CategoryShimmer(),
            onTapSeeAll: () {
              Get.toNamed(AppRoutes.categoryListScreen);
            },
            height: 66,
            itemWidth: null,
            itemBuilder: (CategoryModel item) {
              return CategoryCard(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.courseListScreen,
                    arguments: CourseListForCategory(
                      category: item,
                      screenTitle: item.name,
                    ),
                  );
                },
                category: item,
              );
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _onTapSearch,
      child: Padding(
        // ignore: prefer_const_constructors
        padding: .fromSTEB(16, 16, 16, 7),
        child: CustomTextFormField(
          hintText: AppLabels.whatDoYouWantToLearn.tr,
          radius: 8,
          enabled: false,
          prefixIcon: AppIcons.search,
          requiredErrorMessage: AppLabels.fieldRequired.tr,
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return BlocBuilder<FetchSliderCubit, FetchSliderState>(
      builder: (context, state) {
        if (state is FetchSliderInProgress) {
          return const SliderShimmer();
        }
        if (state is FetchSliderFail) {
          return Container();
        }
        if (state is FetchSliderSuccess) {
          return CustomCarouselSliderWidget(
            height: 190,
            items: state.data.map((slider) {
              return CustomSliderItem(
                url: slider.image,
                onTap: () => _onTapSlider(slider),
              );
            }).toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSection<T extends Model>({
    required String title,
    required double? height,
    required double? itemWidth,
    required Widget Function(T item) itemBuilder,
    Widget Function()? shimmerBuilder,
    required List<T> items,
    bool isLoading = false,
    VoidCallback? onTapSeeAll,
    double? spacing,
  }) {
    return Column(
      crossAxisAlignment: .start,
      spacing: spacing ?? 8,
      children: [
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Expanded(
                child: CustomText(
                  title,
                  maxLines: 1,
                  ellipsis: true,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(fontWeight: .w500),
                ),
              ),
              if (onTapSeeAll != null)
                GestureDetector(
                  onTap: onTapSeeAll,
                  child: CustomText(
                    AppLabels.seeAll.tr,
                    style: TextStyle(
                      fontSize: context.font.small,
                      fontWeight: FontWeight.w500,
                      color: context.color.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (isLoading) ...{
          SizedBox(
            height: height,
            child: ListView.separated(
              itemCount: AppConstant.kShimmerCount,
              shrinkWrap: true,
              padding: const .symmetric(horizontal: 16),
              scrollDirection: .horizontal,
              separatorBuilder: (context, index) {
                return const SizedBox(width: 8);
              },
              itemBuilder: (context, index) {
                return shimmerBuilder?.call() ?? const SizedBox.shrink();
              },
            ),
          ),
        } else ...{
          SizedBox(
            height: height,
            width: context.screenWidth,
            child: ListView.separated(
              shrinkWrap: true,
              padding: const .symmetric(horizontal: 16),
              scrollDirection: .horizontal,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: itemWidth,
                  child: itemBuilder.call(items[index]),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(width: 8);
              },
              itemCount: items.length,
            ),
          ),
        },
      ],
    );
  }
}
