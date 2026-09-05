import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elms/common/models/category_model.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/utils/extensions/context_extension.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;
  final bool isFullCard;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.isFullCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CustomCard(
        child: Container(
          width: isFullCard ? double.infinity : null,
          constraints: isFullCard
              ? null
              : const BoxConstraints(minWidth: 155, maxWidth: 220),
          padding: const .all(8),
          child: Row(
            mainAxisSize: .min,
            children: [
              Container(
                width: 52,
                height: 52,
                margin: const EdgeInsetsDirectional.only(end: 16),
                child: CustomImage(
                  category.image,
                  width: 52,
                  height: 52,
                  radius: 6,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    CustomText(
                      category.name,
                      maxLines: 1,
                      ellipsis: true,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.copyWith(fontWeight: .w500),
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      category.courseCount == 0
                          ? AppLabels.noCourses.tr
                          : '${AppLabels.courses.formatCountRounded(category.courseCount)} ${category.courseCount == 1 ? AppLabels.course.tr : AppLabels.courses.tr}',
                      style: TextStyle(
                        fontSize: context.font.small,
                        color: context.color.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isFullCard)
                CustomImage(AppIcons.right, color: context.color.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}
