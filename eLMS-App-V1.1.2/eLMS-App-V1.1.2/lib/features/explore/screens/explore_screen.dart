import 'package:elms/common/widgets/course_card.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_icon_button.dart';
import 'package:elms/common/widgets/custom_no_data_widget.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/login/guest_checker.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/cart/widgets/cart_bottom_inset.dart';
import 'package:elms/features/course/cubits/fetch_course_languages_cubit.dart';
import 'package:elms/features/course/models/filter.dart';
import 'package:elms/features/explore/cubit/explore_cubit.dart';
import 'package:elms/utils/course_navigation_helper.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/scroll_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  static Widget route() => const ExploreScreen();

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  TextEditingController searchController = TextEditingController();
  final ValueNotifier<bool> _filterApplied = ValueNotifier(false);
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    searchController.removeDebouncedListener();
    searchController.dispose();
    _filterApplied.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTapFilter() {
    final cubit = context.read<ExploreCubit>();
    cubit.updateLanguageValues(
      context.read<FetchCourseLanguagesCubit>().getCourseLanguages(),
    );
    Get.toNamed(AppRoutes.filterScreen, arguments: cubit.courseFilters)?.then((
      value,
    ) {
      if (value is List<Filter> && context.mounted) {
        cubit.applyFilters(value);
        _filterApplied.value = cubit.courseFilters.hasAppliedFilters;
      }
    });
  }

  @override
  void initState() {
    searchController.addDebouncedListener(() {
      context.read<ExploreCubit>().search(searchController.text);
    });
    _scrollController.addEndListener(() {
      context.read<ExploreCubit>().fetchMore();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLabels.explore.tr,
        actions: [
          CustomIconButton(
            image: AppIcons.bookmark,
            onTap: () {
              GuestChecker.check(
                onNotGuest: () {
                  Get.toNamed(AppRoutes.wishlistScreen);
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => context.read<ExploreCubit>().refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: _buildSearchRow(context)),
            // Course list sliver will go here
            BlocBuilder<ExploreCubit, ExploreState>(
              builder: (context, state) {
                if (state is ExploreProgress) {
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      16 + context.cartBottomInset,
                    ),
                    sliver: SliverList.separated(
                      itemCount: 6,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) => const CustomShimmer(
                        height: 154,
                        width: double.infinity,
                        margin: .zero,
                      ),
                    ),
                  );
                }
                if (state is ExploreSuccess) {
                  if (state.data.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: CustomNoDataWidget(),
                    );
                  }
                  return SliverMainAxisGroup(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          16,
                          0,
                          16,
                          16 + context.cartBottomInset,
                        ),
                        sliver: SliverList.separated(
                          itemCount: state.data.length,
                          itemBuilder: (context, index) {
                            final course = state.data[index];
                            return SizedBox(
                              height: 157,
                              child: CourseCard.horizontal(
                                course: course,
                                onTap: () async {
                                  await CourseNavigationHelper.navigateToCourse(
                                    course,
                                    context: context,
                                  );
                                },
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 16);
                          },
                        ),
                      ),
                      if (state.isLoadingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                    ],
                  );
                }

                if (state is ExploreError) {
                  return SliverToBoxAdapter(
                    child: CustomErrorWidget(error: state.error),
                  );
                }
                return const SliverFillRemaining();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: CustomTextFormField(
              hintText: AppLabels.whatDoYouWantToLearn.tr,
              radius: 8,
              controller: searchController,
              prefixIcon: AppIcons.search,
              requiredErrorMessage: AppLabels.fieldRequired.tr,
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _filterApplied,
            builder: (context, isActive, _) => CustomIconButton(
              image: AppIcons.filter,
              color: isActive ? context.color.primary : null,
              onTap: _onTapFilter,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
