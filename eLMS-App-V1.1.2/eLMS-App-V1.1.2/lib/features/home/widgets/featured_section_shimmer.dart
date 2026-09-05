import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/utils/local_storage.dart';
import 'package:flutter/material.dart';

class FeaturedSectionShimmer extends StatelessWidget {
  const FeaturedSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> sectionTypes = LocalStorage.getCachedSectionTypes();

    /// If no cached types, show default shimmers
    if (sectionTypes.isEmpty) {
      return Column(
        children: [
          _SectionShimmerWrapper(
            height: 154,
            itemBuilder: (index) => const _HorizontalCourseCardShimmer(),
          ),
          _SectionShimmerWrapper(
            height: 318,
            itemWidth: 300,
            itemBuilder: (index) => const _VerticalCourseCardShimmer(),
          ),
          _SectionShimmerWrapper(
            height: 154,
            itemBuilder: (index) => const _HorizontalCourseCardShimmer(),
          ),
        ],
      );
    }

    return Column(
      children: sectionTypes.map((type) {
        return _buildShimmerForType(type);
      }).toList(),
    );
  }

  Widget _buildShimmerForType(String type) {
    if (type == 'newly_added_courses') {
      return _SectionShimmerWrapper(
        height: 154,
        itemBuilder: (index) => const _HorizontalCourseCardShimmer(),
      );
    }
    if (type == 'my_learning') {
      return _SectionShimmerWrapper(
        height: 128,
        itemWidth: 330,
        itemBuilder: (index) => const _LearningCourseCardShimmer(),
      );
    }
    if (type == 'top_rated_instructors') {
      return _SectionShimmerWrapper(
        height: 240,
        itemWidth: 162,
        itemBuilder: (index) => const _InstructorCardShimmer(),
      );
    }

    /// Default: vertical course card sections
    return _SectionShimmerWrapper(
      height: 318,
      itemWidth: 300,
      itemBuilder: (index) => const _VerticalCourseCardShimmer(),
    );
  }
}

class _SectionShimmerWrapper extends StatelessWidget {
  final double height;
  final double? itemWidth;
  final Widget Function(int index) itemBuilder;

  const _SectionShimmerWrapper({
    required this.height,
    required this.itemBuilder,
    this.itemWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 8,
        children: [
          /// Title shimmer row
          const Padding(
            padding: .symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                CustomShimmer(height: 14, width: 120, borderRadius: 4),
                CustomShimmer(height: 12, width: 50, borderRadius: 4),
              ],
            ),
          ),

          /// Cards shimmer
          SizedBox(
            height: height,
            child: ListView.separated(
              scrollDirection: .horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const .symmetric(horizontal: 16),
              itemCount: AppConstant.kShimmerCount,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return SizedBox(width: itemWidth, child: itemBuilder(index));
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer for CourseCard.horizontal (height: 154, width: 350)
class _HorizontalCourseCardShimmer extends StatelessWidget {
  const _HorizontalCourseCardShimmer();

  @override
  Widget build(BuildContext context) {
    return const CustomCard(
      width: 350,
      padding: .all(12),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                CustomShimmer(height: 20, width: 70, borderRadius: 20),
                SizedBox(height: 8),
                CustomShimmer(height: 12, width: 180, borderRadius: 4),
                SizedBox(height: 6),
                CustomShimmer(height: 12, width: 140, borderRadius: 4),
                SizedBox(height: 8),
                CustomShimmer(height: 10, width: 100, borderRadius: 4),
                Spacer(),
                CustomShimmer(height: 1, borderRadius: 0),
                SizedBox(height: 8),
                CustomShimmer(height: 14, width: 80, borderRadius: 4),
              ],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: CustomShimmer(height: double.maxFinite, borderRadius: 8),
          ),
        ],
      ),
    );
  }
}

/// Shimmer for CourseCard.vertical (height: 318, width: 300)
class _VerticalCourseCardShimmer extends StatelessWidget {
  const _VerticalCourseCardShimmer();

  @override
  Widget build(BuildContext context) {
    return const CustomCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          /// Image placeholder
          CustomShimmer(height: 152, borderRadius: 0),

          /// Content
          Expanded(
            child: Padding(
              padding: .all(8),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      CustomShimmer(height: 20, width: 70, borderRadius: 20),
                      CustomShimmer(height: 12, width: 50, borderRadius: 4),
                    ],
                  ),
                  SizedBox(height: 8),
                  CustomShimmer(height: 12, width: 200, borderRadius: 4),
                  SizedBox(height: 6),
                  CustomShimmer(height: 12, width: 160, borderRadius: 4),
                  SizedBox(height: 8),
                  CustomShimmer(height: 10, width: 120, borderRadius: 4),
                  SizedBox(height: 8),
                  CustomShimmer(height: 1, borderRadius: 0),
                  SizedBox(height: 8),
                  CustomShimmer(height: 14, width: 80, borderRadius: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer for CourseCard.learning (height: 128, width: 330)
class _LearningCourseCardShimmer extends StatelessWidget {
  const _LearningCourseCardShimmer();

  @override
  Widget build(BuildContext context) {
    return const CustomCard(
      padding: .all(8),
      borderRadius: 10,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: 8),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  CustomShimmer(height: 18, width: 70, borderRadius: 20),
                  SizedBox(height: 6),
                  CustomShimmer(height: 10, width: 140, borderRadius: 4),
                  SizedBox(height: 4),
                  CustomShimmer(height: 12, width: 180, borderRadius: 4),
                  Spacer(),
                  CustomShimmer(height: 9, borderRadius: 8),
                ],
              ),
            ),
          ),
          CustomShimmer(width: 108, height: 112, borderRadius: 6),
        ],
      ),
    );
  }
}

/// Shimmer for InstructorCard.small (height: 240, width: 162)
class _InstructorCardShimmer extends StatelessWidget {
  const _InstructorCardShimmer();

  @override
  Widget build(BuildContext context) {
    return const CustomCard(
      borderColor: Colors.transparent,
      child: Padding(
        padding: .symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: .spaceEvenly,
          children: [
            /// Profile image
            CustomShimmer(width: 64, height: 64, borderRadius: 32),
            SizedBox(height: 8),

            /// Name
            CustomShimmer(height: 12, width: 100, borderRadius: 4),
            SizedBox(height: 4),

            /// Qualification
            CustomShimmer(height: 10, width: 80, borderRadius: 4),
            SizedBox(height: 4),

            /// Rating
            CustomShimmer(height: 10, width: 60, borderRadius: 4),
            SizedBox(height: 8),

            /// Divider
            CustomShimmer(height: 1, borderRadius: 0),
            SizedBox(height: 8),

            /// Stats
            CustomShimmer(height: 10, width: 100, borderRadius: 4),
            SizedBox(height: 6),
            CustomShimmer(height: 10, width: 90, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}
