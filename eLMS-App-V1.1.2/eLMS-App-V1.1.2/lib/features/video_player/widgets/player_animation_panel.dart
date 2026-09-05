// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_seek_bar.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/video_player/widgets/double_tap_animation.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';

final class VideoAnimations {
  bool showRewind;
  bool showForward;
  bool showVolume;
  bool showBrightness;
  double volume;
  double brightness;

  VideoAnimations({
    this.showRewind = false,
    this.showForward = false,
    this.showVolume = false,
    this.showBrightness = false,
    this.volume = 0,
    this.brightness = 0,
  });

  VideoAnimations copyWith({
    bool? showRewind,
    bool? showForward,
    bool? showVolume,
    bool? showBrightness,
    double? volume,
    double? brightness,
  }) {
    return VideoAnimations(
      showRewind: showRewind ?? this.showRewind,
      showForward: showForward ?? this.showForward,
      showVolume: showVolume ?? this.showVolume,
      showBrightness: showBrightness ?? this.showBrightness,
      volume: volume ?? this.volume,
      brightness: brightness ?? this.brightness,
    );
  }
}

class PlayerAnimationPanel extends StatefulWidget {
  final ValueNotifier<VideoAnimations> controller;
  const PlayerAnimationPanel({super.key, required this.controller});

  @override
  State<PlayerAnimationPanel> createState() => _PlayerAnimationPanelState();
}

class _PlayerAnimationPanelState extends State<PlayerAnimationPanel> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder(
          valueListenable: widget.controller,
          builder: (context, value, child) {
            return Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Align(
                        alignment: .centerLeft,
                        child: DoubleTapAnimation(
                          show: value.showRewind,
                          isRewind: true,
                          onEnd: () {
                            widget.controller.value = widget.controller.value
                                .copyWith(showRewind: false);
                          },
                        ),
                      ),
                      if (value.showBrightness)
                        Align(
                          alignment: .centerLeft,
                          child: Padding(
                            padding: const .symmetric(
                              horizontal: 7,
                              vertical: 20,
                            ),
                            child: Column(
                              mainAxisSize: .min,
                              spacing: 5,
                              children: [
                                CustomText(
                                  AppLabels.brightness.tr,
                                  style: TextStyle(
                                    fontSize: context.font.small,
                                  ).copyWith(color: context.color.onPrimary),
                                ),
                                CustomSeekBar(
                                  thickness: 4,
                                  fullLength: 100,
                                  seekBarProgress: 100 * value.brightness,
                                  orientation: SeekBarOrientation.vertical,
                                  colors: const [Colors.grey, Colors.grey],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    fit: .expand,
                    children: [
                      Align(
                        alignment: .centerRight,
                        child: DoubleTapAnimation(
                          show: value.showForward,
                          onEnd: () {
                            widget.controller.value = widget.controller.value
                                .copyWith(showForward: false);
                          },
                        ),
                      ),
                      if (value.showVolume)
                        Align(
                          alignment: .centerRight,
                          child: Padding(
                            padding: const .symmetric(
                              horizontal: 7,
                              vertical: 20,
                            ),
                            child: Column(
                              mainAxisSize: .min,
                              spacing: 5,
                              children: [
                                CustomText(
                                  AppLabels.volume.tr,
                                  style: TextStyle(
                                    fontSize: context.font.small,
                                  ).copyWith(color: context.color.onPrimary),
                                ),
                                CustomSeekBar(
                                  thickness: 4,
                                  fullLength: 100,
                                  seekBarProgress: 100 * value.volume,
                                  orientation: SeekBarOrientation.vertical,
                                  colors: const [Colors.grey, Colors.grey],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
