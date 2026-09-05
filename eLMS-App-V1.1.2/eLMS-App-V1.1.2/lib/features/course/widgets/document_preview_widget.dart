import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/video_banner_container.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentPreviewWidget extends StatelessWidget {
  final CurriculumModel curriculum;
  final String courseImage;
  final double height;
  final VoidCallback onDocumentOpen;

  const DocumentPreviewWidget({
    super.key,
    required this.curriculum,
    required this.courseImage,
    required this.height,
    required this.onDocumentOpen,
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
              child: CustomButton(
                title: AppLabels.openDocument.tr,
                radius: 100,
                borderColor: context.color.textPrimary,
                backgroundColor: Colors.transparent,
                onPressed: onDocumentOpen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
