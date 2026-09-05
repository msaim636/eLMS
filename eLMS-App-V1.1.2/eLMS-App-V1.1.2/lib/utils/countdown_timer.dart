import 'dart:async';

typedef OnTimerComplete = void Function();
typedef OnTimerTick = void Function(int remainingSeconds);

class CountdownTimer {
  Timer? _timer;
  final int durationInSeconds;
  final OnTimerComplete? onComplete;
  final OnTimerTick? onTick;

  bool _isActive = false;
  int _remainingSeconds = 0;

  CountdownTimer({
    required this.durationInSeconds,
    this.onComplete,
    this.onTick,
  });

  bool get isActive => _isActive;
  int get remainingSeconds => _remainingSeconds;

  String get formattedTime {
    final int minutes = _remainingSeconds ~/ 60;
    final int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void start() {
    if (_isActive) return;

    _isActive = true;
    _remainingSeconds = durationInSeconds;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        onTick?.call(_remainingSeconds);
      } else {
        _isActive = false;
        timer.cancel();
        onComplete?.call();
      }
    });
  }

  void reset() {
    _timer?.cancel();
    _isActive = false;
    _remainingSeconds = durationInSeconds;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
