import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:elms/features/video_player/youtube/youtube_controller.dart';

/// A widget that renders **only** the YouTube video — no controls, no overlay.
///
/// Pair with [YoutubeController] to control playback externally.
///
/// ```dart
/// final controller = YoutubeController(videoId: 'dQw4w9WgXcQ');
///
/// // In your build:
/// YoutubePlayerView(
///   controller: controller,
///   width: 360,
///   height: 200,
/// )
/// ```
class YoutubePlayerView extends StatelessWidget {
  final YoutubeController controller;

  /// If null, the view expands to fill its parent.
  final double? width;

  /// If null, the view expands to fill its parent.
  final double? height;

  const YoutubePlayerView({
    super.key,
    required this.controller,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget player = WebViewWidget(controller: controller.webViewController);

    if (width != null || height != null) {
      player = SizedBox(
        width: width,
        height: height,
        child: player,
      );
    }

    return ClipRect(child: player);
  }
}
