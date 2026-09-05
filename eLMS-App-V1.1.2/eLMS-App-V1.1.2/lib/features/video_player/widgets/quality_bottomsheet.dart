import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/features/video_player/bloc/video_player_bloc.dart';
import 'package:elms/features/video_player/bloc/video_player_event.dart';
import 'package:elms/features/video_player/bloc/video_player_state.dart';
import 'package:elms/features/video_player/video_source.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class QualityBottomSheet extends StatefulWidget {
  const QualityBottomSheet({super.key});

  @override
  State<QualityBottomSheet> createState() => _QualityBottomSheetState();
}

class _QualityBottomSheetState extends State<QualityBottomSheet> {
  List<Quality> qualities = [];

  @override
  void initState() {
    qualities =
        context.read<VideoPlayerBloc>().getState()?.source?.getQualities() ??
        [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
      builder: (context, state) {
        Quality currentQuality = Quality.notSpecified();
        if (state is VideoPlayerLoaded) {
          currentQuality = state.quality;
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            final Quality quality = qualities[index];
            final bool isSelected = currentQuality == quality;

            return Material(
              type: .transparency,
              child: ListTile(
                selected: isSelected,
                title: CustomText(
                  quality.name,
                  style: TextStyle(
                    fontSize: context.font.small,
                    fontWeight: isSelected ? .bold : null,
                    color: isSelected ? context.color.primary : null,
                  ),
                ),
                selectedTileColor: context.color.outline.withValues(alpha: 0.4),
                visualDensity: VisualDensity.compact,
                onTap: () {
                  if (isSelected) {
                    return;
                  }
                  context.read<VideoPlayerBloc>().add(SetQuality(quality));
                  Get.back();
                },
              ),
            );
          },
          itemCount: qualities.length,
        );
      },
    );
  }
}
