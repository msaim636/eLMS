// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:elms/common/enums.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/video_player/video_source.dart';

abstract class VideoPlayerState {}

class VideoPlayerInitial extends VideoPlayerState {}

class VideoPlayerLoading extends VideoPlayerState {}

class VideoPlayerLoaded extends VideoPlayerState {
  final VideoSource? source;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final double volume;
  final PlaybackSpeed speed;
  final bool isMuted;
  final bool isFullScreen;
  final bool uiVisible;
  final bool loop;
  final Quality quality;
  final bool isYoutube;

  VideoPlayerLoaded({
    this.source,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.volume,
    required this.speed,
    required this.isMuted,
    required this.isFullScreen,
    required this.quality,
    required this.uiVisible,
    required this.loop,
    this.isYoutube = false,
  });

  VideoPlayerLoaded copyWith({
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    double? volume,
    PlaybackSpeed? speed,
    bool? isMuted,
    bool? isFullScreen,
    Quality? quality,
    bool? uiVisible,
    bool? loop,
    VideoSource? source,
    bool? isYoutube,
  }) {
    return VideoPlayerLoaded(
      source: source ?? this.source,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      isMuted: isMuted ?? this.isMuted,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      quality: quality ?? this.quality,
      uiVisible: uiVisible ?? this.uiVisible,
      loop: loop ?? this.loop,
      isYoutube: isYoutube ?? this.isYoutube,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideoPlayerLoaded &&
        other.position == position &&
        other.duration == duration &&
        other.isPlaying == isPlaying &&
        other.volume == volume &&
        other.speed == speed &&
        other.isMuted == isMuted &&
        other.isFullScreen == isFullScreen &&
        other.uiVisible == uiVisible &&
        other.quality == quality &&
        other.loop == loop &&
        other.isYoutube == isYoutube;
  }

  @override
  int get hashCode {
    return position.hashCode ^
        duration.hashCode ^
        isPlaying.hashCode ^
        volume.hashCode ^
        speed.hashCode ^
        isMuted.hashCode ^
        isFullScreen.hashCode ^
        uiVisible.hashCode ^
        quality.hashCode ^
        loop.hashCode ^
        isYoutube.hashCode;
  }
}

enum VideoErrorType { unsupported, network, unknown }

class VideoPlayerError extends VideoPlayerState {
  final String message;
  final VideoErrorType errorType;

  VideoPlayerError(this.message, {this.errorType = VideoErrorType.unknown});
}
