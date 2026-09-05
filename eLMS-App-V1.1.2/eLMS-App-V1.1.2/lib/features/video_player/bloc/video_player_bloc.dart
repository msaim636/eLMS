import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:elms/common/enums.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/features/video_player/bloc/video_player_event.dart';
import 'package:elms/features/video_player/bloc/video_player_state.dart';
import 'package:elms/features/video_player/video_source.dart';
import 'package:elms/features/video_player/youtube/youtube_controller.dart';
import 'package:elms/utils/convert_number.dart';
import 'package:elms/utils/extensions/duration_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerController? _videoPlayerController;
  YoutubeController? _youtubeController;
  VoidCallback? _onVideoCompletion;
  bool _hasTriggeredCompletion = false;
  Timer? _hlsTokenRefreshTimer;
  VideoSource? _currentVideoSource;

  VideoPlayerController? get videoPlayerController => _videoPlayerController;
  YoutubeController? get youtubeController => _youtubeController;
  bool get isYoutube => _youtubeController != null;

  Duration get duration {
    if (_youtubeController != null) {
      return Duration(milliseconds: (_youtubeController!.duration * 1000).toInt());
    }
    return _videoPlayerController?.value.duration ?? Duration.zero;
  }

  Duration get position {
    if (_youtubeController != null) {
      return Duration(milliseconds: (_youtubeController!.currentTime * 1000).toInt());
    }
    return _videoPlayerController?.value.position ?? Duration.zero;
  }

  String get durationString => duration.toString();

  final ValueNotifier<double> minifiedPosition = ValueNotifier<double>(0);
  bool isSeeking = false;

  VideoPlayerBloc() : super(VideoPlayerInitial()) {
    on<LoadVideo>(_onLoadVideo);
    on<PlayVideo>(_onPlayVideo);
    on<TriggerControlsVisibility>(_onTriggerControlsVisibility);
    on<PauseVideo>(_onPauseVideo);
    on<SeekVideo>(_onSeekVideo);
    on<DoubleTapSeek>(_doubleTapSeekVideo);
    on<SetVolume>(_onSetVolume);
    on<SetSpeed>(_onSetSpeed);
    on<SetQuality>(_onSetQuality);
    on<TriggerFullScreen>(_onSetFullScreen);
    on<SetLoop>(_onSetLoop);
    on<RefreshHLSToken>(_onRefreshHLSToken);
    on<VideoPlaybackError>(_onVideoPlaybackError);
    on<YoutubeReadyInternal>(_onYoutubeReadyInternal);
    on<YoutubeErrorInternal>(_onYoutubeErrorInternal);
  }

  void _onYoutubeReadyInternal(
    YoutubeReadyInternal event,
    Emitter<VideoPlayerState> emit,
  ) {
    if (_youtubeController == null) return;
    if (state is! VideoPlayerLoading && state is! VideoPlayerLoaded) return;
    final ytDuration = Duration(
      milliseconds: (_youtubeController!.duration * 1000).toInt(),
    );
    emit(
      VideoPlayerLoaded(
        position: Duration.zero,
        duration: ytDuration,
        isPlaying: event.autoPlay,
        volume: 1.0,
        speed: PlaybackSpeed.normal,
        isMuted: false,
        isFullScreen: false,
        uiVisible: false,
        loop: false,
        quality: Quality.notSpecified(),
        isYoutube: true,
      ),
    );
  }

  void _onYoutubeErrorInternal(
    YoutubeErrorInternal event,
    Emitter<VideoPlayerState> emit,
  ) {
    emit(VideoPlayerError('YouTube player error (code: ${event.errorCode})'));
  }
  Timer? _uiControlsVisibilityTimer;
  Completer _triggerCompleter = Completer();

  ///This will trigger UI controls
  void _onTriggerControlsVisibility(
    TriggerControlsVisibility event,
    Emitter<VideoPlayerState> emit,
  ) async {
    ///If the completer is completed then assign new one because we are using the Timer,
    ///and if we use timer or any task which will be called on future then event will not wait if the
    /// task is not async. There after you will not be able to emit new state. So we are virtually
    ///  creating empty future which will do nothing but trick event handler
    if (_triggerCompleter.isCompleted) {
      _triggerCompleter = Completer();
    }
    _uiControlsVisibilityTimer?.cancel();

    if (state is! VideoPlayerLoaded) {
      return;
    }

    final currentState = state as VideoPlayerLoaded;

    ///Here is Timer is used because if the user leaves after seeking. this should trigger and ui will be hide after delay not instantly
    if (currentState.uiVisible && !event.isTimer) {
      ///If the UI is visible then we need to hide it
      emit(currentState.copyWith(uiVisible: false));
      return;
    }

    emit(currentState.copyWith(uiVisible: true));
    _uiControlsVisibilityTimer = Timer(const Duration(seconds: 3), () {
      if (state is VideoPlayerLoaded) {
        final VideoPlayerLoaded currentState = state as VideoPlayerLoaded;

        ///If the user is not seeking then complete the future
        if (!isSeeking) {
          if (currentState.isPlaying) {
            emit(currentState.copyWith(uiVisible: false));
            _triggerCompleter.complete();
          }
        }
      }
    });

    ///wait until the timer completes the future
    await _triggerCompleter.future;
  }

  void _listener() {
    if (isSeeking) {
      return;
    }

    // Detect runtime playback errors (e.g. ExoPlayer MediaCodecVideoRenderer crash)
    if (_videoPlayerController?.value.hasError == true) {
      final errorDesc =
          _videoPlayerController?.value.errorDescription ?? 'Playback error';
      add(VideoPlaybackError(errorDesc));
      return;
    }

    if ((position.inSeconds / duration.inSeconds).isNaN) {
      return;
    }
    final double progress = position.inSeconds / duration.inSeconds;
    minifiedPosition.value = progress;

    // Check if video reached 90% completion
    if (progress >= 0.9 &&
        !_hasTriggeredCompletion &&
        _onVideoCompletion != null) {
      _hasTriggeredCompletion = true;
      _onVideoCompletion?.call();
    }
  }

  /// Listener for YoutubeController state changes
  void _youtubeListener() {
    if (isSeeking || _youtubeController == null) return;

    final ytDuration = _youtubeController!.duration;
    final ytCurrentTime = _youtubeController!.currentTime;

    if (ytDuration <= 0) return;

    final double progress = ytCurrentTime / ytDuration;
    minifiedPosition.value = progress.clamp(0.0, 1.0);

    // Check if video reached 90% completion
    if (progress >= 0.9 &&
        !_hasTriggeredCompletion &&
        _onVideoCompletion != null) {
      _hasTriggeredCompletion = true;
      _onVideoCompletion?.call();
    }

    // Update playing state if it changed
    if (state is VideoPlayerLoaded) {
      final currentState = state as VideoPlayerLoaded;
      final ytIsPlaying = _youtubeController!.isPlaying;
      if (currentState.isPlaying != ytIsPlaying) {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(currentState.copyWith(isPlaying: ytIsPlaying));
      }
    }
  }

  Future<void> _onLoadVideo(
    LoadVideo event,
    Emitter<VideoPlayerState> emit,
  ) async {
    emit(VideoPlayerLoading());
    try {
      // Store the completion callback
      _onVideoCompletion = event.onCompletion;
      _hasTriggeredCompletion = false;

      if (event.isYoutube && event.youtubeVideoId != null) {
        // ── YouTube: use WebView-based YoutubeController ──
        _disposeControllers();

        _youtubeController = YoutubeController(
          videoId: event.youtubeVideoId!,
          autoPlay: event.autoPlay,
          onReady: () {
            // Fires asynchronously from the WebView channel after this event
            // handler has completed — must NOT call the captured `emit` here.
            // Dispatch an internal event so the bloc emits through a fresh
            // event-handler emitter.
            if (isClosed) return;
            add(YoutubeReadyInternal(autoPlay: event.autoPlay));
          },
          onEnded: () {
            if (!_hasTriggeredCompletion && _onVideoCompletion != null) {
              _hasTriggeredCompletion = true;
              _onVideoCompletion?.call();
            }
          },
          onError: (errorCode) {
            if (isClosed) return;
            add(YoutubeErrorInternal(errorCode));
          },
        );

        _youtubeController!.addListener(_youtubeListener);

        // Emit initial loaded state (will be updated when onReady fires)
        emit(
          VideoPlayerLoaded(
            position: Duration.zero,
            duration: Duration.zero,
            isPlaying: event.autoPlay,
            volume: 1.0,
            speed: PlaybackSpeed.normal,
            isMuted: false,
            isFullScreen: false,
            uiVisible: false,
            loop: false,
            quality: Quality.notSpecified(),
            isYoutube: true,
          ),
        );
      } else {
        // ── Non-YouTube: use native VideoPlayerController ──
        // Tear down any previously loaded controller first; otherwise loading a
        // second video into the same bloc leaks the old controller and keeps the
        // previous video on screen. (Mirrors the YouTube branch above.)
        _disposeControllers();
        _hlsTokenRefreshTimer?.cancel();
        _currentVideoSource = event.source;

        final String url = await event.source!.getSource();
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(url),
          // HLS manifest URLs are often signed and lack a `.m3u8` extension, so
          // ExoPlayer (Android) can't infer the format and treats it as a
          // progressive source. The hint forces the HLS media source.
          formatHint: event.source is HLSVideo ? VideoFormat.hls : null,
        );
        await _videoPlayerController?.initialize();
        _videoPlayerController?.addListener(_listener);

        if (event.autoPlay) {
          await _videoPlayerController?.play();
        }

        emit(
          VideoPlayerLoaded(
            source: event.source,
            position: Duration.zero,
            duration: _videoPlayerController!.value.duration,
            isPlaying: event.autoPlay || (_videoPlayerController?.value.isPlaying ?? false),
            volume: 1.0,
            speed: PlaybackSpeed.normal,
            isMuted: false,
            isFullScreen: false,
            uiVisible: false,
            loop: false,
            quality: event.source!.currentQuality,
          ),
        );

        // Schedule HLS token refresh if this is an HLS video
        if (_currentVideoSource is HLSVideo) {
          _scheduleHLSTokenRefresh();
        }
      }
    } on PlatformException catch (e) {
      // PlatformException with code 'VideoError' indicates unsupported format
      if (e.code == 'VideoError' || _isUnsupportedError(e.message ?? '')) {
        emit(
          VideoPlayerError(
            e.message ?? 'Unsupported video format',
            errorType: VideoErrorType.unsupported,
          ),
        );
      } else {
        emit(VideoPlayerError(e.message ?? 'Failed to load video'));
      }
    } catch (e) {
      final msg = e.toString();
      emit(
        VideoPlayerError(
          'Failed to load video',
          errorType: _isUnsupportedError(msg)
              ? VideoErrorType.unsupported
              : VideoErrorType.unknown,
        ),
      );
    }
  }

  void _onPlayVideo(PlayVideo event, Emitter<VideoPlayerState> emit) {
    if (state is VideoPlayerLoaded) {
      if (_youtubeController != null) {
        _youtubeController!.play();
      } else {
        _videoPlayerController?.play();
      }
      emit((state as VideoPlayerLoaded).copyWith(isPlaying: true));
    }
  }

  void _onPauseVideo(PauseVideo event, Emitter<VideoPlayerState> emit) {
    if (state is VideoPlayerLoaded) {
      if (_youtubeController != null) {
        _youtubeController!.pause();
      } else {
        _videoPlayerController?.pause();
      }
      emit((state as VideoPlayerLoaded).copyWith(isPlaying: false));
    }
  }

  void _onSeekVideo(SeekVideo event, Emitter<VideoPlayerState> emit) async {
    isSeeking = true;
    minifiedPosition.value = event.position;
    if (!event.updateVisuallyOnly) {
      if (_youtubeController != null) {
        final double seekSeconds = ConvertNumber.inRange(
          currentValue: event.position,
          minValue: 0,
          maxValue: 1,
          newMaxValue: _youtubeController!.duration,
          newMinValue: 0,
        );
        _youtubeController!.seekTo(seekSeconds);
        isSeeking = false;
        add(TriggerControlsVisibility(isTimer: true));
      } else {
        final double pos = ConvertNumber.inRange(
          currentValue: event.position,
          minValue: 0,
          maxValue: 1,
          newMaxValue: (state as VideoPlayerLoaded).duration.inSeconds.toDouble(),
          newMinValue: 0,
        );
        await _videoPlayerController?.seekTo(Duration(seconds: pos.toInt()));
        isSeeking = false;
        add(TriggerControlsVisibility(isTimer: true));
      }
    }
  }

  FutureOr<void> _doubleTapSeekVideo(
    DoubleTapSeek event,
    Emitter<VideoPlayerState> emit,
  ) {
    if (_youtubeController != null) {
      if (event.direction == DoubleTapDirection.left) {
        _youtubeController!.rewind(AppConstant.kDoubleTapSeekDuration.toDouble());
      } else {
        _youtubeController!.forward(AppConstant.kDoubleTapSeekDuration.toDouble());
      }
    } else {
      if (event.direction == DoubleTapDirection.left) {
        _videoPlayerController?.seekTo(
          position - const Duration(seconds: AppConstant.kDoubleTapSeekDuration),
        );
      } else {
        _videoPlayerController?.seekTo(
          position + const Duration(seconds: AppConstant.kDoubleTapSeekDuration),
        );
      }
    }
  }

  void _onSetVolume(SetVolume event, Emitter<VideoPlayerState> emit) {
    if (state is VideoPlayerLoaded) {
      if (_youtubeController != null) {
        _youtubeController!.setVolume((event.volume * 100).toInt());
      } else {
        _videoPlayerController?.setVolume(event.volume);
      }
      emit((state as VideoPlayerLoaded).copyWith(volume: event.volume));
    }
  }

  void _onSetSpeed(SetSpeed event, Emitter<VideoPlayerState> emit) {
    if (state is VideoPlayerLoaded) {
      if (_youtubeController != null) {
        // Map PlaybackSpeed to YoutubePlaybackRate
        final ytRate = YoutubePlaybackRate.values.firstWhere(
          (r) => r.value == event.speed.value,
          orElse: () => YoutubePlaybackRate.normal,
        );
        _youtubeController!.setPlaybackRate(ytRate);
      } else {
        _videoPlayerController?.setPlaybackSpeed(event.speed.value);
      }
      emit((state as VideoPlayerLoaded).copyWith(speed: event.speed));
    }
  }

  void _onSetQuality(SetQuality event, Emitter<VideoPlayerState> emit) async {
    if (state is VideoPlayerLoaded) {
      // Quality switching is only supported for non-YouTube videos
      if (_youtubeController != null) return;

      final bool wasPlaying = _videoPlayerController?.value.isPlaying ?? false;

      ///We are storing current position here because the [position] variable will be changed after we initialize new video controller because it is getter so it will give us position of new player controller
      final Duration currentPosition = position;

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(event.quality.url),
        formatHint: _currentVideoSource is HLSVideo ? VideoFormat.hls : null,
      );

      await _videoPlayerController?.initialize();
      _videoPlayerController?.addListener(_listener);
      await _videoPlayerController?.seekTo(currentPosition);

      if (wasPlaying) {
        await _videoPlayerController!.play();
      }

      emit(
        (state as VideoPlayerLoaded).copyWith(
          quality: event.quality,

          ///Updating quality here as well this is optional but needed if want to check video quality from the [source]
          source: (state as VideoPlayerLoaded).source
            ?..currentQuality = event.quality,
        ),
      );
    }
  }

  void _onSetFullScreen(
    TriggerFullScreen event,
    Emitter<VideoPlayerState> emit,
  ) {
    if (state is VideoPlayerLoaded) {
      final bool isFullscreen = !(state as VideoPlayerLoaded).isFullScreen;
      SystemChrome.setPreferredOrientations(
        isFullscreen ? [.landscapeLeft] : [.portraitUp],
      );
      emit((state as VideoPlayerLoaded).copyWith(isFullScreen: isFullscreen));
    }
  }

  FutureOr<void> _onSetLoop(SetLoop event, Emitter<VideoPlayerState> emit) {
    if (state is VideoPlayerLoaded) {
      if (_youtubeController != null) {
        _youtubeController!.setLoop(event.loop);
      } else {
        _videoPlayerController?.setLooping(event.loop);
      }
      emit((state as VideoPlayerLoaded).copyWith(loop: event.loop));
    }
  }

  void _scheduleHLSTokenRefresh() {
    if (_currentVideoSource is! HLSVideo) return;

    final hlsVideo = _currentVideoSource as HLSVideo;
    final refreshDuration = hlsVideo.getRefreshDuration();

    if (refreshDuration == null) return;

    _hlsTokenRefreshTimer?.cancel();
    _hlsTokenRefreshTimer = Timer(refreshDuration, () {
      add(RefreshHLSToken());
    });
  }

  Future<void> _onRefreshHLSToken(
    RefreshHLSToken event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (_currentVideoSource is! HLSVideo) return;
    if (state is! VideoPlayerLoaded) return;

    try {
      final hlsVideo = _currentVideoSource as HLSVideo;
      final currentPosition = _videoPlayerController?.value.position;
      final wasPlaying = _videoPlayerController?.value.isPlaying ?? false;

      // Get new token and manifest URL
      final newManifestUrl = await hlsVideo.refreshToken();

      // Dispose old controller
      _videoPlayerController?.removeListener(_listener);
      await _videoPlayerController?.dispose();

      // Initialize new controller with new manifest URL
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(newManifestUrl),
        formatHint: VideoFormat.hls,
      );

      await _videoPlayerController!.initialize();
      _videoPlayerController!.addListener(_listener);

      // Seek to previous position
      if (currentPosition != null) {
        await _videoPlayerController!.seekTo(currentPosition);
      }

      // Resume playback if it was playing
      if (wasPlaying) {
        await _videoPlayerController!.play();
      }

      // Schedule next refresh
      _scheduleHLSTokenRefresh();
    } catch (e) {
      emit(VideoPlayerError('Failed to refresh video token: $e'));
    }
  }

  String progressDuration(double progress) {
    final bool seeking = isSeeking;
    if (seeking) {
      if (_youtubeController != null) {
        final double pos = ConvertNumber.inRange(
          currentValue: progress,
          minValue: 0,
          maxValue: 1,
          newMaxValue: _youtubeController!.duration,
          newMinValue: 0,
        );
        return '${Duration(seconds: pos.toInt()).toFormattedDuration()} / ${duration.toFormattedDuration()}';
      }
      final double pos = ConvertNumber.inRange(
        currentValue: progress,
        minValue: 0,
        maxValue: 1,
        newMaxValue:
            _videoPlayerController?.value.duration.inSeconds.toDouble() ?? 0,
        newMinValue: 0,
      );
      return '${Duration(seconds: pos.toInt()).toFormattedDuration()} / ${duration.toFormattedDuration()}';
    }
    return '${position.toFormattedDuration()} / ${duration.toFormattedDuration()}';
  }

  void _onVideoPlaybackError(
    VideoPlaybackError event,
    Emitter<VideoPlayerState> emit,
  ) {
    _videoPlayerController?.removeListener(_listener);
    emit(
      VideoPlayerError(
        event.message,
        errorType: _isUnsupportedError(event.message)
            ? VideoErrorType.unsupported
            : VideoErrorType.unknown,
      ),
    );
  }

  /// Returns true if the error message suggests an unsupported video format.
  bool _isUnsupportedError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('unsupported') ||
        lower.contains('format') ||
        lower.contains('codec') ||
        lower.contains('not supported') ||
        lower.contains('mediaplayer') ||
        lower.contains('exoplayer') ||
        lower.contains('source error') ||
        lower.contains('cannot play');
  }

  VideoPlayerLoaded? getState() {
    if (state is VideoPlayerLoaded) {
      return (state as VideoPlayerLoaded);
    }
    return null;
  }

  /// Dispose both controllers safely
  void _disposeControllers() {
    _videoPlayerController?.removeListener(_listener);
    _videoPlayerController?.pause();
    _videoPlayerController?.dispose();
    _videoPlayerController = null;

    _youtubeController?.removeListener(_youtubeListener);
    _youtubeController?.dispose();
    _youtubeController = null;
  }

  @override
  Future<void> close() {
    // Cancel any active timers
    _uiControlsVisibilityTimer?.cancel();
    _hlsTokenRefreshTimer?.cancel();

    // Complete any pending futures
    if (!_triggerCompleter.isCompleted) {
      _triggerCompleter.complete();
    }

    // Properly stop and dispose both controllers
    _disposeControllers();

    // Dispose value notifier
    minifiedPosition.dispose();

    return super.close();
  }
}
