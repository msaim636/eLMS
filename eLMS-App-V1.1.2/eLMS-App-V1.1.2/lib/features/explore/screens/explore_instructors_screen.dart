import 'package:elms/common/cubits/paginated_api_states.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_icon_button.dart';
import 'package:elms/common/widgets/custom_no_data_widget.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/category/cubits/fetch_category_cubit.dart';
import 'package:elms/features/category/repositories/category_repository.dart';
import 'package:elms/features/course/models/filter.dart';
import 'package:elms/features/explore/cubit/explore_instructors_cubit.dart';
import 'package:elms/features/instructor/widgets/instructor_card.dart';
import 'package:elms/common/models/instructor_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/scroll_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ExploreInstructorsScreen extends StatefulWidget {
  const ExploreInstructorsScreen({super.key});

  static Widget route() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ExploreInstructorsCubit()),
        BlocProvider(
          create: (context) => FetchCategoryCubit(CategoryRepository(), isTree: true),
        ),
      ],
      child: const ExploreInstructorsScreen(),
    );
  }

  @override
  State<ExploreInstructorsScreen> createState() =>
      _ExploreInstructorsScreenState();
}

class _ExploreInstructorsScreenState extends State<ExploreInstructorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> _filterApplied = ValueNotifier(false);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ExploreInstructorsCubit>().fetchData();
    _searchController.addDebouncedListener(() {
      context.read<ExploreInstructorsCubit>().search(_searchController.text);
    });
    _scrollController.addEndListener(() {
      context.read<ExploreInstructorsCubit>().fetchMoreData();
    });
  }

  @override
  void dispose() {
    _searchController.removeDebouncedListener();
    _searchController.dispose();
    _filterApplied.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTapFilter() {
    final cubit = context.read<ExploreInstructorsCubit>();
    Get.toNamed(
      AppRoutes.filterScreen,
      arguments: cubit.instructorFilters,
    )?.then((value) {
      if (value is List<Filter> && context.mounted) {
        cubit.applyFilters(value);
        _filterApplied.value = cubit.instructorFilters.hasAppliedFilters;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchCategoryCubit, FetchCategoryState>(
      listener: (context, state) {
        if (state is FetchCategorySuccess) {
          context.read<ExploreInstructorsCubit>().updateCategoryValues(
            state.data,
          );
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: AppLabels.instructors.tr,
          showBackButton: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async =>
              context.read<ExploreInstructorsCubit>().fetchData(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildSearchRow(context)),
              BlocBuilder<ExploreInstructorsCubit, PaginatedApiState>(
                builder: (context, state) {
                  if (state is PaginatedApiLoadingState) {
                    return SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList.separated(
                        itemCount: 3,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) =>
                            const InstructorCardShimmer(),
                      ),
                    );
                  }
                  if (state is PaginatedApiSuccessState) {
                    if (state.data.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: CustomNoDataWidget(),
                      );
                    }
                    return SliverMainAxisGroup(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            16,
                            0,
                            16,
                            16,
                          ),
                          sliver: SliverList.separated(
                            itemCount: state.data.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final instructor =
                                  state.data[index] as InstructorModel;
                              return InstructorCard.detailed(
                                instructor: instructor,
                                onTap: () {
                                  Get.toNamed(
                                    AppRoutes.instructorDetailsScreen,
                                    arguments: instructor,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        if (state is PaginatedApiLoadingMore)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                      ],
                    );
                  }
                  if (state is PaginatedApiFailureState) {
                    return SliverToBoxAdapter(
                      child: CustomErrorWidget(
                        error: state.exception,
                        onRetry: () =>
                            context.read<ExploreInstructorsCubit>().fetchData(),
                      ),
                    );
                  }
                  return const SliverFillRemaining();
                },
              ),
            ],
          ),
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
              hintText: AppLabels.searchInstructors.tr,
              radius: 8,
              controller: _searchController,
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
}
