import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/cart/cubit/cart_cubit.dart';
import 'package:elms/features/cart/models/cart_response_model.dart';
import 'package:elms/utils/extensions/color_extension.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:elms/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class FloatingCartBar extends StatelessWidget {
  const FloatingCartBar({super.key, required this.onCheckout});

  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state is! CartSuccess || state.cart.courses.isEmpty) {
          return const SizedBox.shrink();
        }
        return _CartBarContent(
          cart: state.cart,
          onCheckout: onCheckout,
          onClear: () => context.read<CartCubit>().clearCart(),
        );
      },
    );
  }
}

class _CartBarContent extends StatelessWidget {
  const _CartBarContent({
    required this.cart,
    required this.onCheckout,
    required this.onClear,
  });

  final CartResponseModel cart;
  final VoidCallback onCheckout;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final courseCount = cart.courses.length;
    final savings = cart.originalPrice - cart.subtotal;
    final showSavings = savings > 0;

    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: context.color.outline.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        spacing: 10,
        children: [
          _StackedThumbnails(courses: cart.courses),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: .start,
              spacing: 2,
              children: [
                CustomText(
                  Utils.pluralize(
                    courseCount,
                    singular: AppLabels.course,
                    plural: AppLabels.courses,
                  ),
                  fontSize: context.font.small,
                  fontWeight: .w600,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    CustomText(
                      cart.subtotal.toString().currency,
                      fontSize: context.font.xSmall,
                      fontWeight: .w600,
                      color: context.color.primary,
                    ),
                    if (showSavings) ...[
                      SizedBox(
                        height: 12,
                        child: VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: context.color.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      Flexible(
                        child: CustomText(
                          '${AppLabels.save.tr}: ${savings.toString().currency}',
                          fontSize: context.font.xxSmall,
                          color: context.color.success,
                          maxLines: 1,
                          ellipsis: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCheckout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: context.color.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: CustomText(
                AppLabels.checkout.tr,
                fontSize: context.font.small,
                fontWeight: .w600,
                color: context.color.onPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.close,
                size: 18,
                color: context.color.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedThumbnails extends StatelessWidget {
  const _StackedThumbnails({required this.courses});

  final List<CartCourseModel> courses;

  static const double _size = 36;
  static const double _overlap = 14;

  @override
  Widget build(BuildContext context) {
    final visible = courses.take(3).toList();
    final width = _size + (visible.length - 1) * (_size - _overlap);

    return SizedBox(
      width: width,
      height: _size,
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * (_size - _overlap),
              child: Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.color.surface.darken(0.04),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CustomImage(
                    visible[i].thumbnail,
                    width: _size,
                    height: _size,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
