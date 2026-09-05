import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/features/video_player/bloc/video_player_bloc.dart';
import 'package:elms/features/video_player/bloc/video_player_event.dart';
import 'package:elms/features/video_player/bloc/video_player_state.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class PlaySpeedBottomSheet extends StatelessWidget {
  const PlaySpeedBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
      builder: (context, state) {
        PlaybackSpeed speed = PlaybackSpeed.normal;
        if (state is VideoPlayerLoaded) {
          speed = state.speed;
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final PlaybackSpeed speedValue = PlaybackSpeed.values[index];
            final bool isSelected = speedValue == speed;
            return Material(
              type: .transparency,
              child: ListTile(
                title: CustomText(
                  speedValue.label,
                  style: TextStyle(
                    fontSize: context.font.medium,
                    fontWeight: isSelected ? .bold : null,
                    color: isSelected ? context.color.primary : null,
                  ),
                ),
                selected: isSelected,
                selectedTileColor: context.color.outline.withValues(alpha: 0.4),
                visualDensity: VisualDensity.compact,
                onTap: () {
                  context.read<VideoPlayerBloc>().add(SetSpeed(speedValue));
                  Get.back();
                },
              ),
            );
          },
          itemCount: PlaybackSpeed.values.length,
        );
      },
    );
  }
}
