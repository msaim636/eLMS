import 'package:elms/common/cubits/paginated_api_states.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_icon_button.dart';
import 'package:elms/common/widgets/custom_no_data_widget.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/category/cubits/fetch_category_cubit.dart';
import 'package:elms/features/category/repositories/category_repository.dart';
import 'package:elms/features/course/models/filter.dart';
import 'package:elms/features/instructor/cubit/instructor_cubit.dart';
import 'package:elms/features/instructor/models/instructor_list_arguments.dart';
import 'package:elms/features/instructor/widgets/instructor_card.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class InstructorListScreen extends StatefulWidget {
  final String title;
  final int? featureSectionId;

  const InstructorListScreen({
    super.key,
    required this.title,
    this.featureSectionId,
  });

  static Widget route() {
    final arguments = Get.arguments;
    final String title;
    final int? featureSectionId;

    if (arguments is InstructorListArguments) {
      title = arguments.title;
      featureSectionId = arguments.featureSectionId;
    } else {
      title = arguments as String;
      featureSectionId = null;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              InstructorCubit(featureSectionId: featureSectionId),
        ),
        BlocProvider(
          create: (context) =>
              FetchCategoryCubit(CategoryRepository(), isTree: true),
        ),
      ],
      child: InstructorListScreen(
        title: title,
        featureSectionId: featureSectionId,
      ),
    );
  }

  @override
  State<InstructorListScreen> createState() => _InstructorListScreenState();
}

class _InstructorListScreenState extends State<InstructorListScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _filterApplied = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    context.read<InstructorCubit>().fetchData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _filterApplied.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<InstructorCubit>().fetchMoreData();
    }
  }

  void _onTapFilter() {
    Get.toNamed(
      AppRoutes.filterScreen,
      arguments: context.read<InstructorCubit>().instructorFilters,
    )?.then((value) {
      if (value is List<Filter>) {
        if (context.mounted) {
          // ignore: use_build_context_synchronously
          context.read<InstructorCubit>().applyFilters(value);
          // ignore: use_build_context_synchronously
          _filterApplied.value = context
              .read<InstructorCubit>()
              .instructorFilters
              .hasAppliedFilters;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        showBackButton: true,
        actions: [
          ValueListenableBuilder(
            valueListenable: _filterApplied,
            builder: (context, value, _) {
              return CustomIconButton(
                image: AppIcons.filter,
                color: value ? context.color.primary : context.color.onSurface,
                onTap: _onTapFilter,
              );
            },
          ),
        ],
      ),
      body: BlocListener<FetchCategoryCubit, FetchCategoryState>(
        listener: (context, state) {
          if (state is FetchCategorySuccess) {
            context.read<InstructorCubit>().updateCategoryValues(state.data);
          }
        },
        child: BlocBuilder<InstructorCubit, PaginatedApiState>(
          builder: (context, state) {
            if (state is PaginatedApiLoadingState) {
              return const ShimmerBuilder(
                shimmer: InstructorCardShimmer(),
                spacing: 16,
                itemCount: 3,
                padding: .all(16),
              );
            }
            if (state is PaginatedApiSuccessState) {
              if (state.data.isEmpty) {
                return const CustomNoDataWidget(
                  titleKey: AppLabels.noDataFound,
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const .all(16),
                      itemCount: state.data.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return InstructorCard.detailed(
                          instructor: state.data[index],
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.instructorDetailsScreen,
                              arguments: state.data[index],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  if (state is PaginatedApiLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(),
                    ),
                ],
              );
            }
            if (state is PaginatedApiFailureState) {
              return CustomErrorWidget(
                error: state.exception,
                onRetry: () => context.read<InstructorCubit>().fetchData(),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
