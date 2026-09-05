import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/video_player/bloc/video_player_bloc.dart';
import 'package:elms/features/video_player/bloc/video_player_event.dart';
import 'package:elms/features/video_player/widgets/play_speed_bottomsheet.dart';
import 'package:elms/features/video_player/widgets/quality_bottomsheet.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class VideoPlayerSettingsBottomSheet extends StatelessWidget {
  const VideoPlayerSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Get available qualities to determine if we should show the quality option
    final qualities =
        context.read<VideoPlayerBloc>().getState()?.source?.getQualities() ??
        [];
    final hasQualities = qualities.isNotEmpty;

    return Column(
      mainAxisSize: .min,
      children: [
        ListTile(
          title: Text(AppLabels.speed.tr),
          onTap: () {
            UiUtils.showCustomBottomSheet(
              context,
              child: BlocProvider.value(
                value: context.read<VideoPlayerBloc>(),
                child: const PlaySpeedBottomSheet(),
              ),
            );
          },
        ),
        if (hasQualities)
          ListTile(
            title: Text(AppLabels.quality.tr),
            onTap: () {
              UiUtils.showCustomBottomSheet(
                context,
                child: BlocProvider.value(
                  value: context.read<VideoPlayerBloc>(),
                  child: const QualityBottomSheet(),
                ),
              );
            },
          ),
        CheckboxListTile(
          value: context.watch<VideoPlayerBloc>().getState()?.loop ?? false,
          onChanged: (value) {
            context.read<VideoPlayerBloc>().add(SetLoop(value!));
          },
          title: Text(AppLabels.loop.tr),
        ),
      ],
    );
  }
}
