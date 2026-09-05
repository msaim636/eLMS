import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/features/search/cubits/recent_searches_cubit.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentSearchItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback onTap;

  final VoidCallback onRemove;

  const RecentSearchItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.color.outline)),
        ),
        child: Padding(
          padding: const .symmetric(vertical: 10),
          child: Row(
            children: [
              // Circle avatar with icon placeholder
              CustomImage.circular(
                width: 43,
                height: 43,
                imageUrl: imageUrl ?? AppIcons.placeholder,
              ),
              const SizedBox(width: 15),

              // Course info
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    CustomText(
                      title,
                      fontSize: 16,
                      style: TextStyle(fontSize: context.font.medium),
                    ),
                    const SizedBox(height: 5),
                    CustomText(
                      subtitle,
                      fontSize: 12,
                      style: TextStyle(fontSize: context.font.xSmall),
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () {
                  _onTapRemove(context, title);
                },
                child: CustomImage(
                  AppIcons.closeCircle,
                  color: context.color.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapRemove(BuildContext context, String text) {
    context.read<RecentSearchesCubit>().removeRecentSearch(text);
  }
}
