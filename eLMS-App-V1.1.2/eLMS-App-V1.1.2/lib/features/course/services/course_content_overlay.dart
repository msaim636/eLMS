import 'package:elms/core/routes/route_params.dart';
import 'package:flutter/material.dart';

/// Holds the arguments for the currently open course content overlay.
/// Set to non-null to show the overlay, null to close it.
ValueNotifier<CourseContentScreenArguments?> courseContentNavigator =
    ValueNotifier(null);

/// Controls whether the course content overlay is visible.
/// Hidden (but kept alive via Offstage) whenever the user navigates to a
/// screen on top of it, then restored when they pop back.
final ValueNotifier<bool> courseContentOverlayVisible = ValueNotifier(true);

/// Observes root-navigator route changes and auto-hides/shows the course
/// content overlay so screens pushed on top of it are not obscured.
class CourseContentRouteObserver extends NavigatorObserver {
  int _depth = 0;

  void reset() {
    _depth = 0;
    courseContentOverlayVisible.value = true;
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (courseContentNavigator.value == null) return;
    _depth++;
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_depth > 0) courseContentOverlayVisible.value = false;
    });
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (courseContentNavigator.value == null) return;
    if (_depth > 0) {
      _depth--;
      if (_depth == 0) courseContentOverlayVisible.value = true;
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (courseContentNavigator.value == null) return;
    if (_depth > 0) {
      _depth--;
      if (_depth == 0) courseContentOverlayVisible.value = true;
    }
  }
}

final courseContentRouteObserver = CourseContentRouteObserver();
