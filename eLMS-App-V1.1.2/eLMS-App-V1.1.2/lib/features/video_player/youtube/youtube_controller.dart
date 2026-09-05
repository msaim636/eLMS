import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

enum YoutubePlayerState {
  unstarted(-1),
  ended(0),
  playing(1),
  paused(2),
  buffering(3),
  cued(5);

  final int value;
  const YoutubePlayerState(this.value);

  static YoutubePlayerState fromInt(int state) {
    return YoutubePlayerState.values.firstWhere(
      (e) => e.value == state,
      orElse: () => YoutubePlayerState.unstarted,
    );
  }
}

/// Available playback speeds for YouTube player.
enum YoutubePlaybackRate {
  quarter(0.25),
  half(0.5),
  threeQuarter(0.75),
  normal(1.0),
  oneAndQuarter(1.25),
  oneAndHalf(1.5),
  oneAndThreeQuarter(1.75),
  double_(2.0);

  final double value;
  const YoutubePlaybackRate(this.value);
}

/// Thumbnail quality options for YouTube videos.
enum YoutubeThumbnailQuality {
  /// 120×90
  defaultQuality('default'),

  /// 320×180
  medium('mqdefault'),

  /// 480×360
  high('hqdefault'),

  /// 640×480
  standard('sddefault'),

  /// 1280×720 (may not exist for all videos)
  maxRes('maxresdefault');

  final String key;
  const YoutubeThumbnailQuality(this.key);
}

/// Reactive controller for a headless YouTube player.
///
/// Usage:
/// ```dart
/// final controller = YoutubeController(
///   videoId: 'dQw4w9WgXcQ',
///   onStateChanged: (state) => print('State: $state'),
///   onReady: () => print('Ready!'),
///   onEnded: () => print('Video ended'),
/// );
///
/// // Control playback
/// controller.play();
/// controller.pause();
/// controller.togglePlayPause();
/// controller.seekTo(30);
/// controller.forward();       // +10s
/// controller.rewind();        // -10s
/// controller.replay();        // restart from 0
///
/// // Volume
/// controller.setVolume(50);   // 0–100
/// controller.mute();
/// controller.unmute();
///
/// // Speed
/// controller.setPlaybackRate(YoutubePlaybackRate.oneAndHalf);
///
/// // Read state
/// controller.currentTime;     // double
/// controller.duration;        // double
/// controller.progress;        // 0.0 → 1.0
/// controller.isPlaying;       // bool
/// controller.isMuted;         // bool
/// controller.volume;          // int (0–100)
/// controller.playbackRate;    // YoutubePlaybackRate
/// controller.playerState;     // YoutubePlayerState
///
/// // Helpers
/// controller.thumbnailUrl();  // max-res thumbnail URL
/// controller.formattedCurrentTime; // "02:30"
/// controller.formattedDuration;    // "05:12"
///
/// controller.dispose();
/// ```
class YoutubeController extends ChangeNotifier {
  YoutubeController({
    required String videoId,
    bool autoPlay = true,
    this.onStateChanged,
    this.onReady,
    this.onEnded,
    this.onError,
  })  : _videoId = videoId,
        _autoPlay = autoPlay {
    _initWebView();
  }

  final String _videoId;
  final bool _autoPlay;

  // ── Callbacks ─────────────────────────────────────────────────────────
  /// Called whenever the player state changes.
  final ValueChanged<YoutubePlayerState>? onStateChanged;

  /// Called once when the player is ready to play.
  final VoidCallback? onReady;

  /// Called when the video finishes playing.
  final VoidCallback? onEnded;

  /// Called on YouTube player errors. Error codes:
  /// 2 = invalid videoId, 5 = HTML5 error, 100 = not found,
  /// 101/150 = embedding not allowed
  final ValueChanged<int>? onError;

  // ── Public state ──────────────────────────────────────────────────────
  double _currentTime = 0;
  double get currentTime => _currentTime;

  double _duration = 0;
  double get duration => _duration;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _isReady = false;
  bool get isReady => _isReady;

  bool _isBuffering = false;
  bool get isBuffering => _isBuffering;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  int _volume = 100;
  int get volume => _volume;

  YoutubePlaybackRate _playbackRate = YoutubePlaybackRate.normal;
  YoutubePlaybackRate get playbackRate => _playbackRate;

  YoutubePlayerState _playerState = YoutubePlayerState.unstarted;
  YoutubePlayerState get playerState => _playerState;

  String get videoId => _videoId;

  /// Progress as a value between 0.0 and 1.0.
  double get progress => _duration > 0 ? (_currentTime / _duration).clamp(0, 1) : 0;

  /// Formatted current time as "MM:SS" or "HH:MM:SS" for long videos.
  String get formattedCurrentTime => _formatTime(_currentTime);

  /// Formatted total duration as "MM:SS" or "HH:MM:SS" for long videos.
  String get formattedDuration => _formatTime(_duration);

  // ── Internal WebView ──────────────────────────────────────────────────
  late final WebViewController _webViewController;

  /// The WebViewController backing this player.
  /// Only [YoutubePlayerView] should use this.
  WebViewController get webViewController => _webViewController;

  // ── Playback Controls ─────────────────────────────────────────────────
  void play() => _js('playVideo()');

  void pause() => _js('pauseVideo()');

  void togglePlayPause() {
    if (!_isReady) return;
    _js(_isPlaying ? 'pauseVideo()' : 'playVideo()');
  }

  void seekTo(double seconds) {
    if (!_isReady) return;
    _js('seekTo(${seconds.clamp(0, _duration)})');
  }

  /// Skip forward by [seconds] (default 10).
  void forward([double seconds = 10]) {
    seekTo(_currentTime + seconds);
  }

  /// Skip backward by [seconds] (default 10).
  void rewind([double seconds = 10]) {
    seekTo(_currentTime - seconds);
  }

  /// Restart the video from the beginning.
  void replay() {
    seekTo(0);
    play();
  }

  /// Load a different video without creating a new controller.
  void loadVideo(String videoId) {
    _js("player.loadVideoById('$videoId')");
  }

  /// Cue a video without auto-playing it.
  void cueVideo(String videoId) {
    _js("player.cueVideoById('$videoId')");
  }

  // ── Volume Controls ───────────────────────────────────────────────────
  /// Set volume (0–100).
  void setVolume(int vol) {
    final clamped = vol.clamp(0, 100);
    _js('player.setVolume($clamped)');
    _volume = clamped;
    _isMuted = clamped == 0;
    notifyListeners();
  }

  void mute() {
    _js('player.mute()');
    _isMuted = true;
    notifyListeners();
  }

  void unmute() {
    _js('player.unMute()');
    _isMuted = false;
    notifyListeners();
  }

  void toggleMute() => _isMuted ? unmute() : mute();

  // ── Playback Rate ─────────────────────────────────────────────────────
  void setPlaybackRate(YoutubePlaybackRate rate) {
    _js('player.setPlaybackRate(${rate.value})');
    _playbackRate = rate;
    notifyListeners();
  }

  // ── Loop ──────────────────────────────────────────────────────────────
  /// Enable or disable looping for the current video.
  void setLoop(bool loop) {
    _js('player.setLoop($loop)');
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  /// Returns the YouTube thumbnail URL for this video.
  String thumbnailUrl([
    YoutubeThumbnailQuality quality = YoutubeThumbnailQuality.maxRes,
  ]) {
    return 'https://img.youtube.com/vi/$_videoId/${quality.key}.jpg';
  }

  String _formatTime(double seconds) {
    final d = Duration(seconds: seconds.toInt());
    if (d.inHours > 0) {
      final h = d.inHours.toString().padLeft(2, '0');
      final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$h:$m:$s';
    }
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Internals ─────────────────────────────────────────────────────────
  void _initWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const {},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
      )
      ..addJavaScriptChannel('YoutubePlayer', onMessageReceived: _onMessage)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (e) =>
              debugPrint('[YT] error: ${e.errorCode} ${e.description}'),
        ),
      )
      ..loadHtmlString(
        _buildHtml(_videoId),
        baseUrl: 'https://www.youtube-nocookie.com',
      );

    if (_webViewController.platform is AndroidWebViewController) {
      (_webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  void _onMessage(JavaScriptMessage msg) {
    final parts = msg.message.split(':');
    if (parts.length < 2) return;
    final type = parts[0];
    final value = parts[1];

    switch (type) {
      case 'duration':
        final wasReady = _isReady;
        _duration = double.tryParse(value) ?? 0;
        _isReady = _duration > 0;
        if (_isReady && !wasReady) onReady?.call();
        break;
      case 'current':
        _currentTime = double.tryParse(value) ?? 0;
        break;
      case 'state':
        _playerState = YoutubePlayerState.fromInt(int.tryParse(value) ?? -1);
        _isPlaying = _playerState == YoutubePlayerState.playing;
        _isBuffering = _playerState == YoutubePlayerState.buffering;
        onStateChanged?.call(_playerState);
        if (_playerState == YoutubePlayerState.ended) onEnded?.call();
        break;
      case 'error':
        onError?.call(int.tryParse(value) ?? -1);
        break;
      case 'volume':
        _volume = int.tryParse(value) ?? 100;
        break;
      case 'muted':
        _isMuted = value == '1' || value == 'true';
        break;
    }
    notifyListeners();
  }

  void _js(String script) {
    _webViewController
        .runJavaScript(
          'try { $script } catch(e) { YoutubePlayer.postMessage("jserror:"+e); }',
        )
        .catchError((e) => debugPrint('[YT] js error: $e'));
  }

  String _buildHtml(String videoId) =>
      '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { background: #000; width: 100%; height: 100%; overflow: hidden; }

    #player-wrap {
      position: absolute;
      top: 0; left: 0; right: 0; bottom: 0;
      overflow: hidden;
    }

    #player-wrap iframe, #player {
      position: absolute;
      top: -60px;
      left: 0;
      width: 100%;
      height: calc(100% + 120px);
      border: none;
      pointer-events: none;
    }

    #blocker {
      position: absolute;
      top: 0; left: 0; right: 0; bottom: 0;
      z-index: 9999;
      background: transparent;
    }

    .ytmCuedOverlayPlayButton { display: none !important; }
  </style>
</head>
<body>
  <div id="player-wrap">
    <div id="player"></div>
  </div>
  <div id="blocker"></div>
  <script>
    var tag = document.createElement('script');
    tag.src = 'https://www.youtube.com/iframe_api';
    document.head.appendChild(tag);

    var player;

    function onYouTubeIframeAPIReady() {
      player = new YT.Player('player', {
        videoId: '$videoId',
        host: 'https://www.youtube-nocookie.com',
        playerVars: {
          autoplay: ${_autoPlay ? 1 : 0},
          controls: 0,
          enablejsapi: 1,
          playsinline: 1,
          rel: 0,
          origin: 'https://www.youtube-nocookie.com',
          modestbranding: 1,
          iv_load_policy: 3,
          disablekb: 1,
          fs: 0,
          showinfo: 0,
          cc_load_policy: 0,
          autohide: 1,
        },
        events: {
          onReady: function(e) {
            var iframe = document.querySelector('#player-wrap iframe');
            if (iframe) {
              iframe.style.position = 'absolute';
              iframe.style.top = '-60px';
              iframe.style.left = '0';
              iframe.style.width = '100%';
              iframe.style.height = 'calc(100% + 120px)';
              iframe.style.border = 'none';
              iframe.style.pointerEvents = 'none';

              // Try to inject CSS into iframe to hide cued play button
              try {
                var iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
                if (iframeDoc) {
                  var style = iframeDoc.createElement('style');
                  style.textContent = '.ytmCuedOverlayPlayButton { display: none !important; visibility: hidden !important; }';
                  iframeDoc.head.appendChild(style);
                }
              } catch(ex) { /* cross-origin — fallback below handles it */ }
            }

            // Fallback: periodically try to hide the button via iframe injection
            setInterval(function() {
              try {
                var iframe = document.querySelector('#player-wrap iframe');
                if (!iframe) return;
                var iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
                if (!iframeDoc) return;
                var btns = iframeDoc.querySelectorAll('.ytmCuedOverlayPlayButton');
                for (var i = 0; i < btns.length; i++) {
                  btns[i].style.display = 'none';
                  btns[i].style.visibility = 'hidden';
                }
              } catch(ex) { /* cross-origin */ }
            }, 300);

            // Report initial volume/mute state
            YoutubePlayer.postMessage('volume:' + e.target.getVolume());
            YoutubePlayer.postMessage('muted:' + (e.target.isMuted() ? '1' : '0'));

            setTimeout(function() {
              YoutubePlayer.postMessage('duration:' + e.target.getDuration());
              setInterval(function() {
                if (!player || !player.getCurrentTime) return;
                var state = player.getPlayerState();
                if (state !== 1) return; // only report while playing
                YoutubePlayer.postMessage('current:' + player.getCurrentTime());
                YoutubePlayer.postMessage('duration:' + player.getDuration());
              }, 500);
            }, 500);
          },
          onStateChange: function(e) {
            YoutubePlayer.postMessage('state:' + e.data);
          },
          onError: function(e) {
            YoutubePlayer.postMessage('error:' + e.data);
          },
        },
      });
    }

    function playVideo()  { if (player) player.playVideo(); }
    function pauseVideo() { if (player) player.pauseVideo(); }
    function seekTo(s)    { if (player) player.seekTo(s, true); }
  </script>
</body>
</html>
''';
}
