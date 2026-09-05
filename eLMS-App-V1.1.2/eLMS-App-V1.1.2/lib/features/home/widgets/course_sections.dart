// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:elms/common/models/instructor_model.dart';
import 'package:elms/features/instructor/models/instructor_list_arguments.dart';
import 'package:elms/features/instructor/widgets/instructor_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/course_list_dataclass.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/widgets/course_card.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/home/models/featured_section_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/course_navigation_helper.dart';

class HorizontalCourseSection extends FeaturedSection<Model> {
  final FeaturedSectionModel section;
  HorizontalCourseSection(this.section);

  @override
  String get name => section.type.tr;

  @override
  String get type => section.type;

  @override
  double get height => 154;

  @override
  double? get width => null;

  @override
  VoidCallback get onTapSeeAll => () {
    Get.toNamed(
      AppRoutes.courseListScreen,
      arguments: CourseList(
        screenTitle: section.title,
        featureSectionType: section.type,
      ),
    );
  };

  @override
  Widget itemBuilder(BuildContext context, Model data) {
    final course = data as CourseModel;
    return CourseCard.horizontal(
      course: course,
      width: 350,
      onTap: () async {
        await CourseNavigationHelper.navigateToCourse(course, context: context);
      },
    );
  }

  @override
  List<Model> get items => section.data.whereType<Model>().toList();
}

class VerticalCourseSection extends FeaturedSection<Model> {
  final FeaturedSectionModel section;

  VerticalCourseSection(this.section);

  @override
  String get name => section.type.tr;

  @override
  String get type => section.type;

  @override
  double get height => 318;

  @override
  double? get width => 300;

  @override
  VoidCallback get onTapSeeAll => () {
    Get.toNamed(
      AppRoutes.courseListScreen,
      arguments: CourseList(
        screenTitle: section.title,
        featureSectionType: section.type,
      ),
    );
  };

  @override
  Widget itemBuilder(BuildContext context, Model data) {
    final course = data as CourseModel;
    return CourseCard.vertical(
      course: course,
      onTap: () async {
        await CourseNavigationHelper.navigateToCourse(course, context: context);
      },
    );
  }

  @override
  List<Model> get items => section.data.whereType<Model>().toList();
}

class InstructorListSection extends FeaturedSection<Model> {
  final FeaturedSectionModel section;

  InstructorListSection({required this.section});

  @override
  double get height => 240;

  @override
  VoidCallback get onTapSeeAll => () {
    Get.toNamed(
      AppRoutes.instructorListScreen,
      arguments: InstructorListArguments(
        title: section.title,
        featureSectionId: section.id,
      ),
    );
  };

  @override
  Widget itemBuilder(BuildContext context, Model data) {
    return InstructorCard.small(
      instructor: data as InstructorModel,
      onTap: () {
        Get.toNamed(AppRoutes.instructorDetailsScreen, arguments: data);
      },
    );
  }

  @override
  List<Model> get items => section.data.whereType<Model>().toList();

  @override
  String get name => section.type.tr;

  @override
  String get type => section.type;

  @override
  double? get width => null;
}

class MyLearningSection extends FeaturedSection<Model> {
  final FeaturedSectionModel section;

  MyLearningSection({required this.section});

  @override
  String get name => section.type.tr;

  @override
  String get type => section.type;

  @override
  double get height => 128;

  @override
  double? get width => 330;

  @override
  VoidCallback get onTapSeeAll => () {
    Get.toNamed(AppRoutes.myLearningScreen);
  };

  @override
  Widget itemBuilder(BuildContext context, Model data) {
    final course = data as CourseModel;
    return CourseCard.learning(
      course: course,
      onTap: () async {
        await CourseNavigationHelper.navigateToCourse(course, context: context);
      },
    );
  }

  @override
  List<Model> get items => section.data.whereType<Model>().toList();
}

class Sections extends StatelessWidget {
  final List<FeaturedSection> sections;
  const Sections({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    const Widget emptyWidget = SizedBox.shrink();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: sections.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final FeaturedSection<Model> section = sections[index];

        /// hide if the section is not supported in app
        if (section.dataType is UnsupportedSection) {
          return emptyWidget;
        }

        ///hide if no data
        if (section.items.isEmpty) {
          return emptyWidget;
        }

        return _buildSection<Model>(
          context,
          title: section.name,
          height: section.height,
          itemWidth: section.width,
          onTapSeeAll: section.onTapSeeAll,
          itemBuilder: (Model item) {
            return section.itemBuilder(context, item);
          },
          items: section.items,
        );
      },
    );
  }

  Widget _buildSection<T extends Model>(
    BuildContext context, {
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
    return Padding(
      padding: const .symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: .start,
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
          SizedBox(height: spacing ?? 8),
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
      ),
    );
  }
}
