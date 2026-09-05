import 'package:elms/utils/video/widget_bonds.dart';
import 'package:flutter/material.dart';

class PlayerManager extends ChangeNotifier {
  static bool debugMode = false;
  static final PlayerManager instance = PlayerManager._();
  PlayerManager._() {
    currentLayerLink = link;
  }
  Uri? _uri;
  Map<String, dynamic>? _metadata;

  Uri? get videoUri => _uri;
  Map<String, dynamic>? get videoMetadata => _metadata;

  /// Reactive channel for the current video URI. The heavy player subtree is
  /// cached as `child` inside PlayerWrapper's ListenableBuilder (so it doesn't
  /// rebuild on every drag tick), which means a plain `notifyListeners` won't
  /// swap the video when the URI changes. Widgets that must rebuild on a new
  /// video (the CustomVideoPlayer subtree) listen here instead — fires only on
  /// the rare video change, never per drag tick.
  final ValueNotifier<Uri?> videoUriListenable = ValueNotifier(null);

  void setVideo(Uri uri, {Map<String, dynamic>? metadata}) {
    debugPrint('PlayerManager.setVideo -> $uri (old: $_uri)');
    _uri = uri;
    _metadata = metadata;
    videoUriListenable.value = uri;

    notifyListeners();
  }

  void maximize() {
    isMinimized = false;
    isMaximizing = true;
    wasMinimized = true;
    isDragging = true;
    // freeMoveOffset is set synchronously on each drag update — use it directly
    // instead of miniPlayerBonds which is 2 frames stale from async _measureBounds
    artificialPositionY = freeMoveOffset?.dy ?? miniPlayerBonds?.top ?? 0;
    currentLayerLink = dragLink;
    notifyListeners();
  }

  void updateMaximizeAnimation(double t) {
    final double miniTop = freeMoveOffset?.dy ?? miniPlayerBonds?.top ?? 0;
    final double placeholderTop = placeHolderBounds?.top ?? 0;
    artificialPositionY = miniTop + (placeholderTop - miniTop) * t;
    normalized = (1 - t).clamp(0.0, 1.0);
    notifyListeners();
  }

  void completeMaximize() {
    isMaximizing = false;
    isDragging = false;
    wasMinimized = false;
    artificialPositionY = null;
    normalized = 0;
    currentLayerLink = link;
    freeMoveOffset = null;
    canFreelyMove = false;
    notifyListeners();
  }

  LayerLink link = LayerLink();
  LayerLink dragLink = LayerLink();
  LayerLink miniPlayer = LayerLink();

  // Recreates all LayerLinks to prevent duplicate-leader assertions when widgets
  // are remounted after app lifecycle changes (background/foreground cycles).
  // Defers to post-frame to avoid same-frame leader conflicts.
  void resetLinks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bool wasOnMiniPlayer = currentLayerLink == miniPlayer;
      link = LayerLink();
      dragLink = LayerLink();
      miniPlayer = LayerLink();
      currentLayerLink = wasOnMiniPlayer ? miniPlayer : link;
      notifyListeners();
    });
  }

  // Token-based registration to prevent duplicate CompositedTransformTarget
  // leaders when multiple PlaceHolderTarget instances exist in the widget tree
  // (e.g. when the same CourseContentScreen is pushed while the old route is
  // still in the navigation stack).
  int _placeholderTokenCounter = 0;
  int? _activePlaceholderToken;

  /// Registers a new PlaceHolderTarget and returns its unique token.
  /// Only the holder of the latest token should render CompositedTransformTarget.
  int registerPlaceholder() {
    _placeholderTokenCounter++;
    _activePlaceholderToken = _placeholderTokenCounter;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });

    return _placeholderTokenCounter;
  }

  /// Unregisters a PlaceHolderTarget by its token.
  void unregisterPlaceholder(int token) {
    if (_activePlaceholderToken == token) {
      _activePlaceholderToken = null;
      placeHolderBounds = null;
    }
  }

  /// Returns true if the given token is the currently active placeholder.
  bool isActivePlaceholder(int token) => _activePlaceholderToken == token;

  WidgetBounds? placeHolderBounds;
  bool isDragging = false;
  DragUpdateDetails? dragDetails;
  bool _isMinimized = false;
  bool get isMinimized => _isMinimized;
  set isMinimized(bool value) {
    if (_isMinimized == value) return;
    _isMinimized = value;
    isMinimizedListenable.value = value;
  }

  /// Reactive flag for widgets that only care about minimized/full state
  /// (e.g. CustomVideoPlayer needs `isMiniPlayer` to flip without paying
  /// the full PlayerManager rebuild cost). Kept in sync with `isMinimized`
  /// via the setter above.
  final ValueNotifier<bool> isMinimizedListenable = ValueNotifier(false);
  bool isMaximizing = false;
  double? artificialPositionY;
  bool? wasMinimized;
  late LayerLink currentLayerLink;
  WidgetBounds? miniPlayerBonds;
  Size wrapperDesiredSize = const Size(0, 0);
  bool thresoldReached = false;
  bool canFreelyMove = false;
  Offset? freeMoveOffset;
  Offset _freeDragStartOffset = Offset.zero;

  /// High-frequency channel for free-drag position. Updated every pointer
  /// event without triggering a main `notifyListeners` — only widgets that
  /// actually need the new pixel position (the mini-player target) listen
  /// here. The heavy `PlayerWrapper` subtree does NOT rebuild on each tick.
  final ValueNotifier<Offset?> freeMoveOffsetListenable = ValueNotifier(null);

  void startFreeDrag(Offset localPosition) {
    _freeDragStartOffset = localPosition;
  }

  void setFreeMovePosition(Offset? offset) {
    freeMoveOffset = offset;
    freeMoveOffsetListenable.value = offset;
    notifyListeners();
  }

  void setFreelyMove(bool value) {
    canFreelyMove = value;
    notifyListeners();
  }

  void updateWrapperSize(Size size) {
    wrapperDesiredSize = size;
    notifyListeners();
  }

  double inRange({
    required double currentValue,
    required double minValue,
    required double maxValue,
    required double newMaxValue,
    required double newMinValue,
  }) {
    return (currentValue - minValue) /
            (maxValue - minValue) *
            (newMaxValue - newMinValue) +
        newMinValue;
  }

  double normalized = .00;

  void resetNormalization() {
    normalized = 0;
    notifyListeners();
  }

  /// Recompute `normalized` + `thresoldReached` from current drag details.
  /// Hoisted out of the `wrapperSize` getter (which used to perform this
  /// work AND mutate state on every read) so build-time reads stay pure
  /// and per-tick math runs exactly once per drag event.
  void _recomputeNormalizedFromDrag() {
    if (dragDetails?.globalPosition.dy == null ||
        miniPlayer.leader?.offset.dy == null) {
      thresoldReached = normalized > 0.5;
      return;
    }
    if (wasMinimized == true) {
      normalized = inRange(
        currentValue:
            (placeHolderBounds?.offset.dy ?? 0) -
            (dragDetails?.localPosition.dy ?? placeHolderBounds?.top ?? 0),
        minValue:
            (miniPlayerBonds?.top ?? 0) - (miniPlayerBonds?.size.height ?? 0),
        maxValue: placeHolderBounds?.top ?? 0.0,
        newMaxValue: 1,
        newMinValue: 0,
      ).clamp(0, 1);
    } else {
      normalized = inRange(
        currentValue:
            dragDetails?.localPosition.dy ?? placeHolderBounds?.top ?? 0,
        minValue: placeHolderBounds?.top ?? 0,
        maxValue:
            (miniPlayerBonds?.top ?? 0) - (miniPlayerBonds?.size.height ?? 0),
        newMaxValue: 1,
        newMinValue: 0,
      ).clamp(0, 1);
    }
    thresoldReached = normalized > 0.5;
  }

  ///this size is just for scaling purpose
  ///to have a ratio between height and width
  ///
  /// Pure getter — relies on `normalized` being kept current by
  /// `_recomputeNormalizedFromDrag` (drag path) or `updateMaximizeAnimation`
  /// (maximize-animation path).
  Size get wrapperSize =>
      Size.lerp(placeHolderBounds?.size, miniPlayerBonds?.size, normalized) ??
      Size.zero;

  void setDragState(bool state) {
    if (isMinimized) {
      return;
    }
    isDragging = state;
    dragDetails = null;

    if (thresoldReached && state == false) {
      currentLayerLink = miniPlayer;
      normalized = 1;
      isMinimized = true;
    } else if (!thresoldReached && state == false) {
      currentLayerLink = link;
      normalized = .0;
      isMinimized = false;
    } else if (state == true) {
      wasMinimized = isMinimized;
      currentLayerLink = dragLink;
    }

    notifyListeners();
  }

  void updateDragDetails(DragUpdateDetails? details) {
    if (isMinimized) {
      // Per-tick free-drag updates push position through the dedicated
      // ValueNotifier ONLY. The main `notifyListeners` is reserved for the
      // one-shot canFreelyMove transition at drag start so heavy listeners
      // (PlayerWrapper, etc.) don't rebuild on every pointer move.
      if (!canFreelyMove) {
        canFreelyMove = true;
        notifyListeners();
      }
      if (details != null) {
        final newOffset = details.globalPosition - _freeDragStartOffset;
        freeMoveOffset = newOffset;
        freeMoveOffsetListenable.value = newOffset;
      }
      return;
    }
    dragDetails = details;
    _recomputeNormalizedFromDrag();
    notifyListeners();
  }

  void updatePlaceHolderCordinates(WidgetBounds bounds) {
    placeHolderBounds = bounds;
    notifyListeners();
  }

  void updateMiniPlayerCordinates(WidgetBounds bounds) {
    miniPlayerBonds = bounds;
    notifyListeners();
  }
}
