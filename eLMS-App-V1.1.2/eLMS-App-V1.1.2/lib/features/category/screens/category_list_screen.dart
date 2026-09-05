import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/course_list_dataclass.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/category/cubits/fetch_category_cubit.dart';
import 'package:elms/features/category/widgets/category_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/models/category_model.dart';
import 'package:elms/common/widgets/category_card.dart';

class CategoryListScreen extends StatefulWidget {
  static Widget route() {
    return const CategoryListScreen();
  }

  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen>
    with Pagination<CategoryListScreen, FetchCategoryCubit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLabels.categories.tr,
        showBackButton: true,
      ),
      body: BlocBuilder<FetchCategoryCubit, FetchCategoryState>(
        builder: (context, state) {
          if (state is FetchCategoryInProgress) {
            return const ShimmerBuilder(
              padding: .all(16),
              shimmer: CategoryShimmer(),
            );
          }
          if (state is FetchCategorySuccess) {
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const .all(16),
                    itemCount: state.data.length,
                    controller: scrollController,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final CategoryModel category = state.data[index];
                      return CategoryCard(
                        category: category,
                        isFullCard: true,
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.courseListScreen,
                            arguments: CourseListForCategory(
                              category: category,
                              screenTitle: category.name,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                if (state.isLoadingMore) const CircularProgressIndicator(),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
