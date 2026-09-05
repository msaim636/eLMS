import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class SupportInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;
  final VoidCallback? onTap;

  const SupportInfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        borderColor: Colors.transparent,
        child: CustomCard(
          padding: const .symmetric(vertical: 12, horizontal: 6),
          color: context.color.outline.withValues(alpha: 0.25),
          border: 0,
          child: Column(
            children: [
              // Icon container
              Container(
                width: 72,
                height: 72,
                padding: const .all(12),
                decoration: BoxDecoration(
                  color: context.color.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomImage(
                    iconPath,
                    width: 40,
                    height: 40,
                    color: context.color.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Text content
              Column(
                crossAxisAlignment: .stretch,
                children: [
                  CustomText(
                    title,
                    style: const TextStyle(fontWeight: .w500, fontSize: 14),
                    textAlign: .center,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.color.textSecondary,
                    ),
                    textAlign: .center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
