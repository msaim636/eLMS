// import 'package:elms/common/models/video_player_model.dart';
// import 'package:elms/common/widgets/video_player_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class OverlayScreen {
//   static OverlayEntry? _entry;

//   static bool get isOpen {
//     return _entry != null && _entry!.mounted;
//   }

//   static show(BuildContext context, {required Widget screen}) {
//     _entry = OverlayEntry(
//         builder: (context) => _OverlayScreen(screen), maintainState: true);
//     Overlay.of(context).insert(_entry!);
//   }

//   static void close() {
//     _entry?.remove();
//     _entry = null;
//   }
// }

// class _OverlayScreen extends StatefulWidget {
//   final Widget screen;
//   const _OverlayScreen(this.screen);
//   @override
//   State<_OverlayScreen> createState() => _OverlayScreenState();
// }

// class _OverlayScreenState extends State<_OverlayScreen> with RouteAware {
//   final _controller = VideoPlayerController.networkUrl(Uri.parse(
//       'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'));
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: VideoPlayerScreen(
//         playlist: Playlist(id: '0', title: 'Demo video', videos: [
//           VideoModel(
//               id: '11',
//               title: 'heyyy',
//               thumbnail: '',
//               source: YoutubeVideoSource(videoId: 'PCSLQ2oUYjY'))
//         ]),
//         initialVideoIndex: 0,
//         closeScreen: () {
//           OverlayScreen.close();
//         },
//       ),
//     );
//   }
// }
