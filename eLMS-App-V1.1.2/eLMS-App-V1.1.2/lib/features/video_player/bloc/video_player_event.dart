import 'package:elms/common/enums.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/video_player/video_source.dart';
import 'package:elms/utils/utils.dart';
import 'package:flutter/material.dart';

abstract class VideoPlayerEvent {}

class LoadVideo extends VideoPlayerEvent {
  final String url;
  final VoidCallback? onCompletion;
  final bool isHLS;
  final bool autoPlay;

  late final bool isYoutube;
  late final String? youtubeVideoId;
  late final VideoSource? source;

  LoadVideo(
    this.url, {
    this.onCompletion,
    this.isHLS = false,
    this.autoPlay = false,
  }) {
    if (Utils.isYoutubeVideo(url)) {
      isYoutube = true;
      youtubeVideoId = Utils.extractYoutubeVideoId(url);
      source = null;
    } else if (isHLS) {
      isYoutube = false;
      youtubeVideoId = null;
      source = HLSVideo(url);
    } else {
      isYoutube = false;
      youtubeVideoId = null;
      source = HostedVideo(url);
    }
  }
}

class PlayVideo extends VideoPlayerEvent {}

class TriggerControlsVisibility extends VideoPlayerEvent {
  final bool userGesture;
  final bool isTimer;
  TriggerControlsVisibility({this.userGesture = true, this.isTimer = false});
}

class PauseVideo extends VideoPlayerEvent {}

class SeekVideo extends VideoPlayerEvent {
  double position;
  bool updateVisuallyOnly;

  SeekVideo._(this.position, {this.updateVisuallyOnly = false});
  static SeekVideo? _instance;

  static SeekVideo to(double position, {bool updateVisuallyOnly = false}) {
    if (_instance == null) {
      _instance = SeekVideo._(position, updateVisuallyOnly: updateVisuallyOnly);
    } else {
      _instance!.position = position;
      _instance!.updateVisuallyOnly = updateVisuallyOnly;
    }
    return _instance!;
  }
}

class DoubleTapSeek extends VideoPlayerEvent {
  final DoubleTapDirection direction;
  DoubleTapSeek(this.direction);
}

class SetVolume extends VideoPlayerEvent {
  final double volume;
  SetVolume(this.volume);
}

class SetSpeed extends VideoPlayerEvent {
  final PlaybackSpeed speed;
  SetSpeed(this.speed);
}

class SetQuality extends VideoPlayerEvent {
  final Quality quality;
  SetQuality(this.quality);
}

class TriggerFullScreen extends VideoPlayerEvent {
  TriggerFullScreen();
}

class SetLoop extends VideoPlayerEvent {
  final bool loop;
  SetLoop(this.loop);
}

class RefreshHLSToken extends VideoPlayerEvent {
  RefreshHLSToken();
}

class VideoPlaybackError extends VideoPlayerEvent {
  final String message;
  VideoPlaybackError(this.message);
}

/// Internal: dispatched when the YouTube WebView signals it is ready.
/// Used so the async `onReady` callback can emit a new state through a
/// fresh event-handler `emit` instead of the already-completed one from
/// `_onLoadVideo`.
class YoutubeReadyInternal extends VideoPlayerEvent {
  final bool autoPlay;
  YoutubeReadyInternal({required this.autoPlay});
}

/// Internal: dispatched when the YouTube WebView signals an error.
class YoutubeErrorInternal extends VideoPlayerEvent {
  final int errorCode;
  YoutubeErrorInternal(this.errorCode);
}
