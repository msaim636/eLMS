import 'dart:ui';

import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/features/course/widgets/half_circle_shape.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CertificateWidget extends StatefulWidget {
  final double? height;
  final String certificateImage;

  const CertificateWidget({
    super.key,
    required this.certificateImage,
    this.height,
  });

  @override
  State<CertificateWidget> createState() => _CertificateWidgetState();
}

class _CertificateWidgetState extends State<CertificateWidget> {
  final double blurThreshold = 22;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.maxFinite,
      child: Stack(
        fit: .expand,
        children: [
          CustomImage(AppIcons.certificate, fit: .cover, radius: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ClipPath(
              clipper: HalfCircleClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurThreshold,
                  sigmaY: blurThreshold,
                ),
                child: _buildTitleAndSubtitleOverlay(context),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.12),
            child: _buildLockIcon(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndSubtitleOverlay(BuildContext context) {
    return Column(
      mainAxisAlignment: .end,
      spacing: 8,
      children: [
        const SizedBox(height: 8),
        CustomText(
          'to_unlock_certificate'.tr,
          style: TextStyle(
            fontSize: context.font.medium,
            fontWeight: .w500,
            color: Colors.black,
          ),
        ),
        CustomText(
          'complete_following'.tr,
          style: TextStyle(
            fontSize: context.font.small,
            fontWeight: .w400,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLockIcon(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -1),
      child: Container(
        padding: const .all(10),
        decoration: BoxDecoration(
          color: context.color.surface,
          shape: .circle,
          border: Border.all(color: context.color.onSurface, width: 2.3),
        ),
        child: CustomImage(
          AppIcons.lock,
          width: 20,
          height: 20,
          color: context.color.onSurface,
        ),
      ),
    );
  }
}
