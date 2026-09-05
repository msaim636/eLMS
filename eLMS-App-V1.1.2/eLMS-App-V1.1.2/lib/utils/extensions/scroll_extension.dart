import 'dart:async';
import 'package:flutter/material.dart';

extension ScrollEndListen on ScrollController {
  ///It will check if scroll is at the bottom or not
  bool get isEndReached {
    if (offset >= position.maxScrollExtent) {
      return true;
    }
    return false;
  }

  void addEndListener(VoidCallback onEndReached, {double threshold = 0.0}) {
    addListener(() {
      final maxScroll = position.maxScrollExtent - threshold;
      if (offset >= maxScroll && !position.outOfRange) {
        onEndReached();
      }
    });
  }
}

extension SearchListener on TextEditingController {
  static final Map<TextEditingController, Timer?> _timers = {};

  /// Adds a debounced listener to the TextEditingController
  /// [onChanged] callback will be called after [duration] has passed since the last text change
  /// [duration] defaults to 500 milliseconds

  void addDebouncedListener(
    VoidCallback onChanged, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    String previousText = "";

    addListener(() {
      if (previousText == text) return;
      previousText = text;
      _timers[this]?.cancel();
      _timers[this] = Timer(duration, onChanged);
    });
  }

  /// Removes the debounced listener and cancels any pending timer
  void removeDebouncedListener() {
    _timers[this]?.cancel();
    _timers.remove(this);
  }
}
