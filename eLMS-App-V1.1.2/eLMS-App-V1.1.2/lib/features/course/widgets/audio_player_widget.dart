import 'dart:ui';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/video_banner_container.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String? coverImageUrl;
  final double height;
  final VoidCallback? onAudioCompletion;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.coverImageUrl,
    required this.height,
    this.onAudioCompletion,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      if (widget.audioUrl.isEmpty) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      await _audioPlayer.setUrl(widget.audioUrl);

      // Listen for completion
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          widget.onAudioCompletion?.call();
        }
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.color.surface,
          border: Border.all(color: context.color.outline),
        ),
        child: Stack(
          children: [
            // Background cover image
            if (widget.coverImageUrl != null &&
                widget.coverImageUrl!.isNotEmpty) ...[
              Positioned.fill(
                child: VideoBannerContainer(
                  url: widget.coverImageUrl!,
                  height: widget.height,
                  width: context.screenWidth,
                  hideControlIcons: true,
                  blackFilmAlpha: 0.7,
                ),
              ),
              // Blur backdrop filter
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 2),
                  child: Container(
                    color: Colors.transparent.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ] else ...[
              Positioned.fill(
                child: Container(
                  color: context.color.primary.withValues(alpha: 0.8),
                ),
              ),
            ],

            // Loading or error state
            if (_isLoading || _hasError)
              Positioned.fill(
                child: Center(
                  child: _isLoading
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 12,
                          children: [
                            CircularProgressIndicator(
                              color: context.color.onPrimary,
                            ),
                            CustomText(
                              AppLabels.audioLoading.tr,
                              style: TextStyle(
                                fontSize: context.font.small,
                              ).copyWith(color: context.color.onPrimary),
                            ),
                          ],
                        )
                      : CustomText(
                          AppLabels.somethingWentWrong.tr,
                          style: TextStyle(
                            fontSize: context.font.small,
                          ).copyWith(color: context.color.onPrimary),
                        ),
                ),
              ),

            // Audio player controls
            if (!_isLoading && !_hasError) ...[
              // Duration display in the middle
              Center(
                child: StreamBuilder<Duration?>(
                  stream: _audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return CustomText(
                      _formatDuration(position),
                      style: TextStyle(
                        color: context.color.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 56,
                      ),
                    );
                  },
                ),
              ),

              // Bottom controls
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  spacing: 12,
                  children: [
                    // Play/Pause button
                    StreamBuilder<PlayerState>(
                      stream: _audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final isPlaying = playerState?.playing ?? false;
                        final processingState =
                            playerState?.processingState ??
                            ProcessingState.idle;

                        return Container(
                          decoration: BoxDecoration(
                            color: context.color.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: context.color.onPrimary,
                              size: 32,
                            ),
                            onPressed:
                                processingState == ProcessingState.loading
                                ? null
                                : () {
                                    if (isPlaying) {
                                      _audioPlayer.pause();
                                    } else {
                                      _audioPlayer.play();
                                    }
                                  },
                          ),
                        );
                      },
                    ),

                    // Progress bar
                    Expanded(
                      child: StreamBuilder<Duration?>(
                        stream: _audioPlayer.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final duration =
                              _audioPlayer.duration ?? Duration.zero;

                          return Column(
                            spacing: 4,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 16,
                                  ),
                                  activeTrackColor: context.color.primary,
                                  inactiveTrackColor: context.color.onPrimary
                                      .withValues(alpha: 0.3),
                                  thumbColor: context.color.primary,
                                  overlayColor: context.color.primary
                                      .withValues(alpha: 0.2),
                                ),
                                child: Slider(
                                  value: position.inMilliseconds.toDouble(),
                                  max: duration.inMilliseconds.toDouble() > 0
                                      ? duration.inMilliseconds.toDouble()
                                      : 1.0,
                                  onChanged: (value) {
                                    _audioPlayer.seek(
                                      Duration(milliseconds: value.toInt()),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      _formatDuration(position),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: context.color.onPrimary
                                                .withValues(alpha: 0.9),
                                          ),
                                    ),
                                    CustomText(
                                      _formatDuration(duration),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: context.color.onPrimary
                                                .withValues(alpha: 0.9),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
