import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

class DoubleTapAnimation extends StatefulWidget {
  final bool show;
  final VoidCallback? onEnd;
  final bool isRewind; // true = rewind (left), false = forward (right)

  const DoubleTapAnimation({
    super.key,
    required this.show,
    this.onEnd,
    this.isRewind = false,
  });

  @override
  State<DoubleTapAnimation> createState() => _DoubleTapAnimationState();
}

class _DoubleTapAnimationState extends State<DoubleTapAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final int _arrowCount = 3;
  final int _stepDelay = 100; // ms between each arrow
  final List<double> _delays = [];

  @override
  void initState() {
    super.initState();

    // Single controller for the entire animation sequence
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Calculate delays for each arrow
    for (int i = 0; i < _arrowCount; i++) {
      _delays.add(i * _stepDelay / _controller.duration!.inMilliseconds);
    }

    if (widget.show) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant DoubleTapAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _startAnimation();
    }
  }

  Future<void> _startAnimation() async {
    // Wait for animation to complete before calling onEnd
    _controller.addStatusListener(_handleAnimationStatus);
    await _controller.forward(from: 0.0);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == .completed) {
      _controller.removeStatusListener(_handleAnimationStatus);
      if (widget.onEnd != null) widget.onEnd!();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FittedBox(
        fit: .scaleDown,
        child: Row(
          mainAxisSize: .min,
          children: List.generate(
            _arrowCount,
            (index) => _buildArrow(context, index),
          ),
        ),
      ),
    );
  }

  Widget _buildArrow(BuildContext context, int index) {
    // Create staggered animations for each arrow
    final Animation<double> opacityAnim = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        _delays[index], // start
        _delays[index] + 0.5, // end (50% of total duration)
        curve: Curves.easeOut,
      ),
    );

    final Animation<double> scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        _delays[index], // start
        _delays[index] + 0.5, // end (50% of total duration)
        curve: Curves.easeOutBack,
      ),
    );

    final Animation<double> fadeOutAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.5, // start at 50% of total duration
        1.0, // end at 100%
        curve: Curves.easeIn,
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Composite animation: scale up and fade in, then fade out
        final double opacity = opacityAnim.value * (1.0 - fadeOutAnim.value);
        final double scale = 0.4 + (0.6 * scaleAnim.value);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: CustomImage(
        widget.isRewind ? AppIcons.pointLeft : AppIcons.pointRight,
        color: Theme.of(context).colorScheme.onPrimary, // Using theme color

        width: 36,
        height: 36,
      ),
    );
  }
}
