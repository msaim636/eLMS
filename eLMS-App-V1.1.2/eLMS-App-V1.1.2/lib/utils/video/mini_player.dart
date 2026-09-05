import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/video/player_manager.dart';
import 'package:elms/utils/video/widget_bonds.dart';
import 'package:flutter/material.dart';

class MiniPlayerTarget extends StatefulWidget {
  const MiniPlayerTarget({super.key});

  @override
  State<MiniPlayerTarget> createState() => _MiniPlayerTargetState();
}

class _MiniPlayerTargetState extends State<MiniPlayerTarget> {
  GlobalKey miniPlayerKey = GlobalKey();
  static const double _miniHeight = 100.0;
  Size? _lastPlaceholderSize;

  void _measureBounds() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bounds = getWidgetBounds(miniPlayerKey);
      if (bounds != null) {
        PlayerManager.instance.updateMiniPlayerCordinates(bounds);
      }
    });
  }

  // Only rebuilds when the placeholder size changes (rare). The per-tick
  // free-drag offset is consumed by an inner AnimatedBuilder listening to
  // `PlayerManager.freeMoveOffsetListenable`, so this state never rebuilds
  // during a drag.
  void _onPlayerManagerUpdate() {
    final pm = PlayerManager.instance;
    final placeholder = pm.placeHolderBounds?.size;
    if (placeholder != null && placeholder != _lastPlaceholderSize) {
      _lastPlaceholderSize = placeholder;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {});
        _measureBounds();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _measureBounds();
    PlayerManager.instance.addListener(_onPlayerManagerUpdate);
  }

  @override
  void dispose() {
    PlayerManager.instance.removeListener(_onPlayerManagerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pm = PlayerManager.instance;
    final double miniWidth = _lastPlaceholderSize != null
        ? _miniHeight *
              (_lastPlaceholderSize!.width / _lastPlaceholderSize!.height)
        : _miniHeight * (16 / 9);

    final double baseLeft = context.screenWidth - miniWidth - 8;
    final double baseTop = context.screenHeight -
        AppConstant.calculatedBottomNavigationHight -
        _miniHeight -
        8;
    final double maxX = context.screenWidth - miniWidth;
    final double maxY = context.screenHeight - _miniHeight;

    // Positioned stays anchored at (0,0); the leader is moved by a
    // Transform.translate inside an AnimatedBuilder. Transform.translate is
    // paint-only (no layout pass), and CompositedTransformFollower tracks
    // the LeaderLayer's compositor offset automatically — neither the
    // follower nor the rest of this widget rebuild during a drag tick.
    return Positioned(
      top: 0,
      left: 0,
      child: AnimatedBuilder(
        animation: pm.freeMoveOffsetListenable,
        builder: (context, _) {
          final Offset? off = pm.freeMoveOffsetListenable.value;
          final double x = off != null
              ? off.dx.clamp(0.0, maxX)
              : baseLeft;
          final double y = off != null
              ? off.dy.clamp(0.0, maxY)
              : baseTop;
          return Transform.translate(
            offset: Offset(x, y),
            child: CompositedTransformTarget(
              link: pm.miniPlayer,
              child: IgnorePointer(
                child: Container(
                  key: miniPlayerKey,
                  height: _miniHeight,
                  width: miniWidth,
                  color: PlayerManager.debugMode
                      ? Colors.green
                      : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
