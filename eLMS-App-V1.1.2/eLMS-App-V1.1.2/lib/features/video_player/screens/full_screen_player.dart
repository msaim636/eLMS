import 'package:elms/features/video_player/bloc/video_player_bloc.dart';
import 'package:elms/features/video_player/bloc/video_player_event.dart';
import 'package:elms/features/video_player/bloc/video_player_state.dart';
import 'package:elms/features/video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class FullScreenPlayer extends StatefulWidget {
  static Widget route([RouteSettings? settings]) {
    final bloc = (settings?.arguments ?? Get.arguments) as VideoPlayerBloc;
    return BlocProvider.value(value: bloc, child: const FullScreenPlayer());
  }

  const FullScreenPlayer({super.key});

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(.manual, overlays: []);

    // Show controls when entering full screen
    // Use post-frame callback to ensure the widget is built and state is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<VideoPlayerBloc>();
      final state = bloc.getState();

      // Only trigger if the UI is not already visible
      if (state is VideoPlayerLoaded && !state.uiVisible) {
        bloc.add(TriggerControlsVisibility());
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      .manual,
      overlays: SystemUiOverlay.values,
    );

    // If popped via system back button, the bloc won't know we exited.
    // Ensure the state correctly reflects that fullscreen is closed.
    final bloc = context.read<VideoPlayerBloc>();
    final state = bloc.getState();
    if (state is VideoPlayerLoaded && state.isFullScreen) {
      bloc.add(TriggerFullScreen());
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomVideoPlayer(avoidVideoLoad: true, forceFullScreen: true);
  }
}
