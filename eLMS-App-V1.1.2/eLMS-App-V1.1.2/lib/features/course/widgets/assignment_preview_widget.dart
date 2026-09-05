import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/video_banner_container.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/utils/course_navigation_helper.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssignmentPreviewWidget extends StatelessWidget {
  final CurriculumModel curriculum;
  final String courseImage;
  final int courseId;
  final int? chapterId;
  final double height;
  final VoidCallback onSkipToNext;

  const AssignmentPreviewWidget({
    super.key,
    required this.curriculum,
    required this.courseImage,
    required this.courseId,
    this.chapterId,
    required this.height,
    required this.onSkipToNext,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.color.surface,
          border: Border.all(color: context.color.outline),
        ),
        child: Stack(
          children: [
            // Background thumbnail if available
            if (courseImage.isNotEmpty) ...[
              Positioned.fill(
                child: VideoBannerContainer(
                  url: courseImage,
                  height: height,
                  width: context.screenWidth,
                  hideControlIcons: true,
                  blackFilmAlpha: 0.6,
                ),
              ),
            ] else ...[
              Positioned.fill(child: Container(color: context.color.primary)),
            ],
            Center(
              child: Column(
                mainAxisAlignment: .center,
                spacing: 10,
                children: [
                  CustomButton(
                    title: AppLabels.openAssignment.tr,
                    radius: 100,
                    backgroundColor: Colors.transparent,
                    borderColor: context.color.textPrimary,

                    onPressed: () {
                      CourseNavigationHelper.navigateToCourseContentRoute(
                        nestedRoute: CourseContentRoute.assignment,
                        arguments: {
                          'courseId': courseId,
                          'chapterId': chapterId,
                        },
                      );
                    },
                  ),
                  if (curriculum.canSkip ?? false)
                    InkWell(
                      onTap: onSkipToNext,
                      child: CustomText(
                        AppLabels.skipToNextLecture.tr,
                        style: TextStyle(fontSize: context.font.small),
                        color: context.color.textPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
