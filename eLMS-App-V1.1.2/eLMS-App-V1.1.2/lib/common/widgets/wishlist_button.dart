import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/login/guest_checker.dart';
import 'package:elms/features/wishlist/cubit/wishlist_action_cubit.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishlistButton extends StatefulWidget {
  final int courseId;
  final bool isWishlisted;
  final double size;
  final bool isCircular;
  final bool showBorder;
  final VoidCallback? onToggle;

  const WishlistButton({
    super.key,
    required this.courseId,
    required this.isWishlisted,
    this.size = 35,
    this.isCircular = true,
    this.showBorder = true,
    this.onToggle,
  });

  @override
  State<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton> {
  late bool _isWishlisted;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<WishlistActionCubit>();
    _isWishlisted = cubit.getToggledState(widget.courseId) ?? widget.isWishlisted;
  }

  @override
  void didUpdateWidget(WishlistButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isWishlisted != widget.isWishlisted) {
      _isWishlisted = widget.isWishlisted;
    }
  }

  void _onTap() {
    GuestChecker.check(
      onNotGuest: () {
        context.read<WishlistActionCubit>().toggleWishlist(
          courseId: widget.courseId,
          currentWishlistState: _isWishlisted,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WishlistActionCubit, WishlistActionState>(
      listener: (context, state) {
        if (state is WishlistActionSuccess &&
            state.courseId == widget.courseId) {
          setState(() {
            _isWishlisted = state.isWishlisted;
          });
          widget.onToggle?.call();
        } else if (state is WishlistActionError &&
            state.courseId == widget.courseId) {
          setState(() {
            _isWishlisted = state.previousState;
          });
        }
      },
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: widget.isCircular ? .circle : .rectangle,
            borderRadius: widget.isCircular ? null : BorderRadius.circular(8),
            color: context.color.surface,
            border: widget.showBorder
                ? Border.all(
                    color: widget.isCircular
                        ? context.color.textPrimary
                        : context.color.outline,
                  )
                : null,
          ),
          child: FittedBox(
            fit: .none,
            child: CustomImage(
              _isWishlisted ? AppIcons.wishlist : AppIcons.bookmark,
              width: 20,
              height: 20,
              color: _isWishlisted
                  ? context.color.primary
                  : context.color.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
