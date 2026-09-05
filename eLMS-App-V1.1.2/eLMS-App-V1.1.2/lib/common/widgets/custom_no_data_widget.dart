import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elms/utils/extensions/context_extension.dart';

class CustomNoDataWidget extends StatelessWidget {
  final String? titleKey;
  final String? illustrator;
  final double? illustratorSize;

  const CustomNoDataWidget({
    super.key,
    this.titleKey,
    this.illustrator,
    this.illustratorSize = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          CustomImage(
            AppIcons.noDataIllustrator,
            height: illustratorSize,
            width: illustratorSize,
          ),
          const SizedBox(height: 24),
          Text(
            (titleKey ?? AppLabels.noDataFound).tr,
            style: TextStyle(fontSize: context.font.medium),
          ),
        ],
      ),
    );
  }
}
