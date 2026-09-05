import 'dart:math';

import 'package:elms/utils/video/player_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PlayerWrapper extends StatefulWidget {
  final WidgetBuilder builder;

  const PlayerWrapper({super.key, required this.builder});

  @override
  State<PlayerWrapper> createState() => _PlayerWrapperState();
}

class _PlayerWrapperState extends State<PlayerWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isRunningMaximize = false;

  // Allocated once in initState — recreating these on every drag-tick
  // rebuild used to add measurable per-frame cost on Android.
  late final Map<Type, GestureRecognizerFactory> _gestureFactories;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.addListener(_onAnimationTick);
    PlayerManager.instance.addListener(_onManagerChange);

    final pm = PlayerManager.instance;
    _gestureFactories = <Type, GestureRecognizerFactory>{
      VerticalDragGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
        () => VerticalDragGestureRecognizer(),
        (detector) {
          detector.onStart = (details) {
            if (pm.isMinimized) {
              pm.startFreeDrag(details.localPosition);
            } else {
              pm.setDragState(true);
            }
          };
          detector.onEnd = (_) {
            if (pm.isMinimized) {
              pm.setFreelyMove(false);
              return;
            }
            if (pm.wasMinimized != true) {
              pm.resetNormalization();
            }
            pm.setDragState(false);
          };
          detector.onCancel = () {
            if (pm.isMinimized) {
              pm.setFreelyMove(false);
              // Do NOT clear freeMoveOffset here — a tap on the mini
              // player also triggers onCancel (drag loses the gesture
              // arena to the tap recognizer), and maximize() reads
              // freeMoveOffset to know where to start the animation.
              return;
            }
            if (pm.wasMinimized != true) {
              pm.resetNormalization();
            }
            pm.setDragState(false);
          };
          detector.onUpdate = pm.updateDragDetails;
        },
      ),
    };
  }

  void _onManagerChange() {
    final pm = PlayerManager.instance;
    if (pm.isMaximizing && !_isRunningMaximize) {
      _isRunningMaximize = true;
      _controller.value = 0;
      _controller.animateTo(1, curve: Curves.easeInOut).then((_) {
        _isRunningMaximize = false;
        pm.completeMaximize();
      });
    }
  }

  void _onAnimationTick() {
    if (!_isRunningMaximize) return;
    PlayerManager.instance.updateMaximizeAnimation(_controller.value);
  }

  @override
  void dispose() {
    _controller.removeListener(_onAnimationTick);
    PlayerManager.instance.removeListener(_onManagerChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pm = PlayerManager.instance;
    return SizedBox.expand(
      child: UnconstrainedBox(
        child: ListenableBuilder(
          listenable: pm,
          // Build the actual video widget once and reuse via `child` so it
          // doesn't get rebuilt on every drag-tick notify from PlayerManager.
          // The follower/transform above it still rebuilds, but the heavy
          // video subtree stays intact — major win for drag smoothness on
          // Android.
          child: Builder(builder: widget.builder),
          builder: (context, child) {
            final placeholderSize = pm.placeHolderBounds?.size;

            // When minimized and the placeholder route has been popped,
            // use the mini player size as the reference size so the
            // wrapper doesn't vanish.
            final Size? referenceSize =
                placeholderSize ??
                (pm.isMinimized ? pm.miniPlayerBonds?.size : null);

            if (referenceSize == null) return const SizedBox.shrink();

            // Single read of `wrapperSize` per build — used both for the
            // wrapper SizedBox and to derive the Transform.scale factor.
            // Previously the getter was called twice and ran heavy math
            // (inRange + Size.lerp) on each read.
            final Size wrapperSize = pm.wrapperSize;
            final double scale = (placeholderSize == null ||
                    placeholderSize.isEmpty)
                ? 1.0
                : min(
                    wrapperSize.width / placeholderSize.width,
                    wrapperSize.height / placeholderSize.height,
                  );

            return CompositedTransformFollower(
              link: pm.currentLayerLink,
              followerAnchor: Alignment.topRight,
              showWhenUnlinked: false,
              targetAnchor: Alignment.topRight,
              child: RawGestureDetector(
                gestures: _gestureFactories,
                child: SizedBox(
                  height: wrapperSize.height,
                  width: wrapperSize.width,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.bottomRight,
                      maxWidth: referenceSize.width,
                      maxHeight: referenceSize.height,
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: referenceSize.width,
                          height: referenceSize.height,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
