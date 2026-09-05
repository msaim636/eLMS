import 'package:elms/utils/video/player_manager.dart';
import 'package:elms/utils/video/widget_bonds.dart';
import 'package:flutter/material.dart';

class PlaceHolderTarget extends StatefulWidget {
  final double width, height;
  const PlaceHolderTarget({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<PlaceHolderTarget> createState() => _PlaceHolderTargetState();
}

class _PlaceHolderTargetState extends State<PlaceHolderTarget> {
  final key = GlobalKey();
  late final int _token;

  @override
  void initState() {
    super.initState();
    // Register with PlayerManager – only the latest registered placeholder
    // will render the CompositedTransformTarget (prevents duplicate leaders
    // when the same screen is pushed while the old route is still in the stack).
    _token = PlayerManager.instance.registerPlaceholder();
    PlayerManager.instance.addListener(_onManagerChanged);
    _measureBounds();
  }

  void _measureBounds() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!PlayerManager.instance.isActivePlaceholder(_token)) return;
      final bounds = getWidgetBounds(key);
      if (bounds != null) {
        PlayerManager.instance.updatePlaceHolderCordinates(bounds);
      }
    });
  }

  void _onManagerChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    PlayerManager.instance.removeListener(_onManagerChanged);
    PlayerManager.instance.unregisterPlaceholder(_token);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = PlayerManager.instance.isActivePlaceholder(_token);

    // Only the active placeholder renders the CompositedTransformTarget
    // to avoid duplicate leaders on the same LayerLink.
    if (!isActive) {
      return SizedBox(width: widget.width, height: widget.height);
    }

    return CompositedTransformTarget(
      link: PlayerManager.instance.link,
      child: Container(
        key: key,
        width: widget.width,
        height: widget.height,
        color: PlayerManager.debugMode
            ? const Color.fromARGB(255, 7, 255, 73)
            : Colors.transparent,
      ),
    );
  }
}
