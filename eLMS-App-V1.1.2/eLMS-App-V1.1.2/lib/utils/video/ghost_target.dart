import 'package:elms/utils/video/player_manager.dart';
import 'package:flutter/material.dart';

class GhostTarget extends StatefulWidget {
  const GhostTarget({super.key});

  @override
  State<GhostTarget> createState() => _GhostTargetState();
}

class _GhostTargetState extends State<GhostTarget> {
  double positionY = 0;
  bool isAttached = false;

  @override
  void initState() {
    super.initState();
    final pm = PlayerManager.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      positionY = pm.placeHolderBounds?.top ?? 0;
    });
    pm.addListener(_onPlayerManagerUpdate);
  }

  void _onPlayerManagerUpdate() {
    final pm = PlayerManager.instance;
    isAttached = pm.isDragging;
    if (isAttached) {
      positionY += pm.dragDetails?.delta.dy ?? 0;
    } else {
      positionY = pm.thresoldReached
          ? pm.miniPlayerBonds?.top ?? 0
          : pm.placeHolderBounds?.top ?? 0;
    }
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    PlayerManager.instance.removeListener(_onPlayerManagerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isAttached) return const SizedBox();
    final pm = PlayerManager.instance;
    final wrapperSize = pm.wrapperSize;
    // When coming from a free-drag position, anchor the right edge at
    // freeMoveOffset.dx + miniWidth so the player grows leftward during animation.
    final double anchoredRight = pm.freeMoveOffset != null && pm.miniPlayerBonds != null
        ? pm.freeMoveOffset!.dx + pm.miniPlayerBonds!.size.width
        : (pm.wasMinimized == true
            ? pm.miniPlayerBonds!.right
            : pm.placeHolderBounds!.right);
    final double left = anchoredRight - wrapperSize.width;
    // artificialPositionY is initialized from freeMoveOffset.dy in maximize()
    // and then animated toward placeholderTop — don't override it here.
    final double top = pm.artificialPositionY ?? positionY;
    return Positioned(
      top: top,
      left: left,
      child: CompositedTransformTarget(
        link: PlayerManager.instance.dragLink,
        child: Container(
          height: wrapperSize.height,
          width: wrapperSize.width,
          color: PlayerManager.debugMode ? Colors.red : Colors.transparent,
        ),
      ),
    );
  }
}
