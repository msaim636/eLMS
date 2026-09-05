import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/deep_linking/deep_link_manager.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/course/cubit/course_details_cubit.dart';
import 'package:elms/utils/course_navigation_helper.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:elms/utils/share_helper.dart';

class MoreContentSection extends StatelessWidget {
  final CourseModel course;
  final int? currentLectureId;
  final int? chapterId;
  const MoreContentSection({
    super.key,
    required this.course,
    this.currentLectureId,
    this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      _buildMoreContentTile(
        context,
        name: AppLabels.aboutCourse.tr,
        icon: AppIcons.edit,
        onTap: (_) {
          CourseNavigationHelper.navigateToCourseContentRoute(
            nestedRoute: CourseContentRoute.aboutCourse,
            arguments: CourseDetailsScreenArguments(course: course),
          );
        },
      ),
      _buildMoreContentTile(
        context,
        name: AppLabels.resources.tr,
        icon: AppIcons.questionMessage,
        onTap: (_) {
          final detailsState = context.read<CourseDetailsCubit>().state;
          if (detailsState is CourseDetailsSuccess) {
            CourseNavigationHelper.navigateToCourseContentRoute(
              nestedRoute: CourseContentRoute.courseResources,
              arguments: {
                "chapters": detailsState.data.chapters,
                "course_id": course.id,
                "lecture_id": currentLectureId,
              },
            );
          }
        },
      ),
      _buildMoreContentTile(
        context,
        name: AppLabels.courseCertificate.tr,
        icon: AppIcons.courseCertificate,
        onTap: (_) {
          CourseNavigationHelper.navigateToCourseContentRoute(
            nestedRoute: CourseContentRoute.courseCertificate,
            arguments: {'courseId': course.id},
          );
        },
      ),
      _buildMoreContentTile(
        context,
        name: AppLabels.assignment.tr,
        icon: AppIcons.ruler,
        onTap: (_) {
          CourseNavigationHelper.navigateToCourseContentRoute(
            nestedRoute: CourseContentRoute.assignment,
            arguments: {
              'courseId': course.id,
              'chapterId': chapterId,
            },
          );
        },
      ),
      _buildMoreContentTile(
        context,
        name: AppLabels.review.tr,
        icon: AppIcons.ratingsNotFilled,
        onTap: (_) {
          CourseNavigationHelper.navigateToCourseContentRoute(
            nestedRoute: CourseContentRoute.reviews,
            arguments: course.id,
          );
        },
      ),
      _buildMoreContentTile(
        context,
        name: AppLabels.shareThisCourse.tr,
        icon: AppIcons.share,
        onTap: (tileContext) async {
          await ShareHelper.shareUri(
            tileContext,
            Uri.parse(
              DeepLinkManager.instance.createDeepLink(slug: course.slug!),
            ),
          );
        },
      ),
    ];

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.paddingOf(context).bottom,
          ),
          sliver: SliverList.separated(
            itemCount: tiles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => tiles[i],
          ),
        ),
      ],
    );
  }

  Widget _buildMoreContentTile(
    BuildContext context, {
    required String name,
    required String icon,
    required Function(BuildContext tileContext) onTap,
  }) {
    return Builder(
      builder: (tileContext) => GestureDetector(
        onTap: () => onTap(tileContext),
        child: Container(
          padding: const .symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: context.color.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            spacing: 14,
            children: [
              CustomImage(
                icon,
                width: 20,
                height: 20,
                color: context.color.onSurface,
              ),
              CustomText(
                name,
                style: TextStyle(fontSize: context.font.small),
                fontWeight: .w500,
              ),
              const Spacer(),
              CustomImage(AppIcons.right, color: context.color.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}
