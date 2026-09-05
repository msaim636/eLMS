import 'dart:async';

import 'package:flutter/material.dart';

/// Represents a single step in the pattern
/// [key] - which box to tap (1, 2, 3, etc.)
/// [taps] - how many times to tap that box
class PatternStep {
  final int key;
  final int taps;

  const PatternStep(this.key, this.taps);

  @override
  String toString() => 'Key$key x$taps';
}

/// Controller for pattern gesture recognition
///
/// Example usage:
/// ```dart
/// final controller = PatternGestureController(
///   pattern: [
///     PatternStep(1, 2),  // Tap box 1 twice
///     PatternStep(2, 4),  // Tap box 2 four times
///     PatternStep(1, 4),  // Tap box 1 four times
///   ],
///   timeout: Duration(seconds: 2),
///   onPatternMatched: () => print('Debugger unlocked!'),
/// );
/// ```
class PatternGestureController {
  /// The secret pattern to match
  final List<PatternStep> pattern;

  /// Max delay between taps before reset (default: 2 seconds)
  final Duration timeout;

  /// Called when pattern is successfully matched
  final VoidCallback? onPatternMatched;

  /// Called when pattern is reset (timeout or wrong tap)
  final VoidCallback? onPatternReset;

  /// Whether debug mode is enabled (fixed at initialization)
  final bool isDebugModeEnabled;

  /// Current step index in the pattern
  int _currentStepIndex = 0;

  /// Tap count for the current step
  int _currentTapCount = 0;

  /// Timer for timeout between taps
  Timer? _timeoutTimer;

  /// Last tap timestamp
  DateTime? _lastTapTime;

  PatternGestureController({
    required this.pattern,
    this.timeout = const Duration(seconds: 2),
    this.onPatternMatched,
    this.onPatternReset,
    this.isDebugModeEnabled = false,
  });

  /// Call this when a box is tapped
  /// [key] - the key/id of the tapped box
  void onTap(int key) {
    final now = DateTime.now();

    // Check timeout since last tap
    if (_lastTapTime != null) {
      final elapsed = now.difference(_lastTapTime!);
      if (elapsed > timeout) {
        _reset();
      }
    }

    _lastTapTime = now;
    _restartTimeoutTimer();

    // Get expected step
    if (_currentStepIndex >= pattern.length) {
      _reset();
      return;
    }

    final expectedStep = pattern[_currentStepIndex];

    // Check if correct key
    if (key != expectedStep.key) {
      _reset();
      return;
    }

    // Increment tap count
    _currentTapCount++;

    // Check if step is complete
    if (_currentTapCount >= expectedStep.taps) {
      _currentStepIndex++;
      _currentTapCount = 0;

      // Check if entire pattern is complete
      if (_currentStepIndex >= pattern.length) {
        _timeoutTimer?.cancel();
        onPatternMatched?.call();
        _reset(silent: true);
      }
    }
  }

  void _restartTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(timeout, () {
      _reset();
    });
  }

  void _reset({bool silent = false}) {
    _currentStepIndex = 0;
    _currentTapCount = 0;
    _timeoutTimer?.cancel();
    _lastTapTime = null;
    if (!silent) {
      onPatternReset?.call();
    }
  }

  /// Get current progress (for debugging)
  String get progressDebug {
    if (_currentStepIndex == 0 && _currentTapCount == 0) {
      return 'Waiting...';
    }
    final step = pattern[_currentStepIndex];
    return 'Step ${_currentStepIndex + 1}/${pattern.length}: '
        'Key${step.key} $_currentTapCount/${step.taps}';
  }

  void dispose() {
    _timeoutTimer?.cancel();
  }
}

/// A invisible/debug tap box for pattern recognition
class PatternGesture extends StatefulWidget {
  final double width;
  final double height;
  final int boxKey;
  final PatternGestureController controller;

  const PatternGesture({
    super.key,
    required this.height,
    required this.width,
    required this.boxKey,
    required this.controller,
  });

  @override
  State<PatternGesture> createState() => _PatternGestureState();
}

class _PatternGestureState extends State<PatternGesture> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.controller.onTap(widget.boxKey),
      behavior: HitTestBehavior.opaque,
      child: (widget.controller.isDebugModeEnabled)
          ? Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                color: Colors.red.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  '${widget.boxKey}',
                  style: TextStyle(
                    color: Colors.red.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
              ),
            )
          : SizedBox(width: widget.width, height: widget.height),
    );
  }
}
