import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_seek_bar.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/configs/app_settings.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/video_player/bloc/video_player_bloc.dart';
import 'package:elms/features/video_player/bloc/video_player_event.dart';
import 'package:elms/features/video_player/bloc/video_player_state.dart';
import 'package:elms/features/video_player/widgets/player_animation_panel.dart';

import 'package:elms/features/video_player/youtube/youtube_player_view.dart';
import 'package:elms/features/video_player/video_source.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/screen_protection.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String? url;
  final bool avoidVideoLoad;
  final bool forceFullScreen;
  final VoidCallback? onVideoCompletion;
  final bool hideLayout;
  final bool showNextButton;
  final bool showPreviousButton;
  final VoidCallback? onNextTap;
  final VoidCallback? onPreviousTap;
  final bool isHLS;
  final double? height;
  final bool isMiniPlayer;
  final VoidCallback? onTapMiniPlayer;
  final bool autoPlay;

  CustomVideoPlayer({
    super.key,
    this.avoidVideoLoad = false,
    this.forceFullScreen = false,
    this.url,
    this.onVideoCompletion,
    this.hideLayout = false,
    this.showNextButton = false,
    this.showPreviousButton = false,
    this.onNextTap,
    this.onPreviousTap,
    this.isHLS = false,
    this.height,
    this.isMiniPlayer = false,
    this.onTapMiniPlayer,
    this.autoPlay = false,
  }) : assert(
         avoidVideoLoad || (url != null && url.isNotEmpty),
         'URL must be set if avoidVideoLoad is false',
       );

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer>
    with WidgetsBindingObserver, ScreenProtection {
  late VideoPlayerBloc player = context.read<VideoPlayerBloc>();
  double _volume = 0.5;
  final ValueNotifier<bool> isSeekBarExpanded = ValueNotifier(false);
  double _brightness = 0.5;
  final ValueNotifier<VideoAnimations> animationPanelController = ValueNotifier(
    VideoAnimations(),
  );
  OverlayEntry? _settingsOverlay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initBrightnessSettings();
    debugPrint(
      'CustomVideoPlayer current URL: ${widget.url} (isHLS: ${widget.isHLS})',
    );
    if (!widget.avoidVideoLoad) {
      player.add(
        LoadVideo(
          widget.url!,
          onCompletion: widget.onVideoCompletion,
          isHLS: widget.isHLS,
          autoPlay: widget.autoPlay,
        ),
      );
    }
    if (widget.forceFullScreen) {
      SystemChrome.setPreferredOrientations([.landscapeLeft, .landscapeRight]);
    }
  }

  Future<void> _initBrightnessSettings() async {
    if (player.getState()?.isFullScreen == true) {
      _brightness = await ScreenBrightness().application;
    }
  }

  void _onTapPlayAction({required bool isPlaying}) {
    player.add(isPlaying ? PauseVideo() : PlayVideo());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Pause video when app goes to background
    if (state == .paused || state == .inactive) {
      if (player.isYoutube) {
        if (player.youtubeController?.isPlaying == true) {
          player.add(PauseVideo());
        }
      } else {
        final videoController = player.videoPlayerController;
        if (videoController != null && videoController.value.isPlaying) {
          player.add(PauseVideo());
        }
      }
    }
  }

  @override
  void deactivate() {
    // Don't pause when navigating to full screen
    final state = player.getState();
    final isGoingToFullScreen =
        state is VideoPlayerLoaded && state.isFullScreen;

    if (!isGoingToFullScreen && !widget.forceFullScreen) {
      // Only pause video when navigating away (not to full screen)
      if (player.isYoutube) {
        if (player.youtubeController?.isPlaying == true) {
          player.add(PauseVideo());
        }
      } else {
        final videoController = context
            .read<VideoPlayerBloc>()
            .videoPlayerController;
        if (videoController != null && videoController.value.isPlaying) {
          player.add(PauseVideo());
        }
      }
    }
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Safely attempt to reset orientation. If iOS throws a UISceneErrorDomain,
    // catching it prevents the exception from breaking super.dispose().
    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } catch (e) {
      debugPrint('Failed to reset orientation in dispose: $e');
    }

    isSeekBarExpanded.dispose();
    animationPanelController.dispose();
    _settingsOverlay?.remove();

    // Don't pause video when disposing full screen player (only pause when leaving course entirely)
    if (!widget.forceFullScreen) {
      if (player.isYoutube) {
        if (player.youtubeController?.isPlaying == true) {
          player.add(PauseVideo());
        }
      } else {
        final videoController = player.videoPlayerController;
        if (videoController != null && videoController.value.isPlaying) {
          player.add(PauseVideo());
        }
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double playerHeight = widget.forceFullScreen
        ? context.screenHeight
        : (widget.height ?? 211);

    return RawGestureDetector(
      behavior: .deferToChild,
      gestures: {
        if (widget.forceFullScreen)
          HorizontalDragGesturePrevention:
              GestureRecognizerFactoryWithHandlers<
                HorizontalDragGesturePrevention
              >(() => HorizontalDragGesturePrevention(), (instance) {
                instance.onDown = (_) {};
                instance.onCancel = () {};
                instance.onEnd = (_) {};
                instance.onDown = (_) {};
                instance.onUpdate = (_) {};
              }),
      },
      child: ClipRRect(
        borderRadius: widget.forceFullScreen
            ? BorderRadius.zero
            : BorderRadius.circular(8),
        child: SizedBox(
          width: context.screenWidth,
          height: playerHeight,
          child: widget.forceFullScreen
              ? SafeArea(child: _buildPlayer(context, playerHeight))
              : _buildPlayer(context, playerHeight),
        ),
      ),
    );
  }

  Widget _buildPlayer(BuildContext context, double playerHeight) {
    return BlocConsumer<VideoPlayerBloc, VideoPlayerState>(
      listenWhen: (previous, current) {
        if (previous is VideoPlayerLoaded && current is VideoPlayerLoaded) {
          return previous.isFullScreen != current.isFullScreen;
        }
        return false;
      },
      listener: (context, state) {
        if (state is VideoPlayerLoaded && !widget.forceFullScreen) {
          final nestedNavigator = Get.nestedKey(1)?.currentState;
          final useNestedNavigator =
              AppConstant.kEnableExperimentalMiniPlayer &&
              nestedNavigator != null;

          if (useNestedNavigator) {
            if (state.isFullScreen) {
              // Ensure we don't push twice
              nestedNavigator.pushNamed(
                CourseContentRoute.fullScreenVideoPlayer,
                arguments: player,
              );
            } else {
              // Ensure we only pop if we are actually in full screen
              nestedNavigator.pop();
            }
          } else {
            if (state.isFullScreen) {
              if (Get.currentRoute != AppRoutes.fullScreenVideoPlayer) {
                Get.toNamed(AppRoutes.fullScreenVideoPlayer, arguments: player);
              }
            } else {
              if (Get.currentRoute == AppRoutes.fullScreenVideoPlayer) {
                Get.back();
              }
            }
          }
        }
      },
      builder: (context, state) {
        final bool isPlaying = state is VideoPlayerLoaded && state.isPlaying;

        return Container(
          width: context.screenWidth,
          height: playerHeight,
          color: context.color.primary.withValues(alpha: 0.4),
          child: Stack(
            children: [
              if (state is VideoPlayerError) ...{
                _buildVideoErrorWidget(context, state),
              },

              // Conditionally render YouTube WebView or native VideoPlayer
              if (state is VideoPlayerLoaded &&
                  state.isYoutube &&
                  player.youtubeController != null &&
                  state is! VideoPlayerError)
                Positioned.fill(
                  child: (!widget.forceFullScreen && state.isFullScreen)
                      ? const SizedBox.shrink()
                      : YoutubePlayerView(
                          controller: player.youtubeController!,
                        ),
                )
              else if (player.videoPlayerController != null &&
                  state is! VideoPlayerError)
                Positioned.fill(
                  child:
                      (!widget.forceFullScreen &&
                          state is VideoPlayerLoaded &&
                          state.isFullScreen)
                      ? const SizedBox.shrink()
                      : AspectRatio(
                          aspectRatio:
                              player.videoPlayerController!.value.aspectRatio,
                          child: VideoPlayer(player.videoPlayerController!),
                        ),
                ),

              if (!widget.hideLayout && state is! VideoPlayerError)
                PlayerAnimationPanel(controller: animationPanelController),

              if (state is VideoPlayerLoaded && !widget.hideLayout) ...[
                _buildGesturePanel(context, state),
                if (!widget.isMiniPlayer) _buildControls(state),
              ],

              if (state is VideoPlayerLoading) ...[
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        );
      },
    );
  }

  void _brightnessAndVolumeControls(
    DragUpdateDetails details,
    double screenWidth,
  ) {
    final double dx = details.localPosition.dx;
    final double dy = details.delta.dy;
    if (dx < screenWidth / 2) {
      if (player.getState()?.isFullScreen ?? false) {
        // Left half - adjust brightness
        _brightness -= dy * 0.005;
        _brightness = _brightness.clamp(0.0, 1.0);
        ScreenBrightness().setApplicationScreenBrightness(_brightness);
        animationPanelController.value = animationPanelController.value
            .copyWith(brightness: _brightness, showBrightness: true);
      }
    } else {
      // Right half - adjust volume
      _volume -= dy * 0.01;
      _volume = _volume.clamp(0.0, 1.0);
      animationPanelController.value = animationPanelController.value.copyWith(
        volume: _volume,
        showVolume: true,
      );
      player.add(SetVolume(_volume));
    }
  }

  Widget _buildGesturePanel(BuildContext context, VideoPlayerLoaded state) {
    // Only enable vertical drag gestures in fullscreen mode
    // In normal mode, we need to allow the mini player's drag functionality to work
    final bool enableVerticalDrag = state.isFullScreen;

    return GestureDetector(
      behavior: .translucent,
      onTap: () {
        if (widget.isMiniPlayer) {
          widget.onTapMiniPlayer?.call();
          return;
        }
        player.add(TriggerControlsVisibility(userGesture: false));
      },
      onDoubleTapDown: (details) {
        final bool isLeft = details.localPosition.dx < context.screenWidth / 2;

        player.add(TriggerControlsVisibility(userGesture: false));
        player.add(
          DoubleTapSeek(
            isLeft ? DoubleTapDirection.left : DoubleTapDirection.right,
          ),
        );

        if (isLeft) {
          animationPanelController.value = animationPanelController.value
              .copyWith(showRewind: true);
        } else {
          animationPanelController.value = animationPanelController.value
              .copyWith(showForward: true);
        }
      },
      // Only allow vertical drag for brightness/volume control when in fullscreen
      // Otherwise, let the mini player handle vertical drags for scrolling
      onVerticalDragUpdate: enableVerticalDrag
          ? (details) {
              _brightnessAndVolumeControls(details, context.screenWidth);
            }
          : null,
      onVerticalDragEnd: enableVerticalDrag
          ? (details) {
              animationPanelController.value = animationPanelController.value
                  .copyWith(showVolume: false, showBrightness: false);
            }
          : null,
      child: const SizedBox(width: double.infinity, height: double.infinity),
    );
  }

  Widget _buildControls(VideoPlayerLoaded state) {
    return IgnorePointer(
      ignoring: !state.uiVisible,
      child: AnimatedOpacity(
        opacity: state.uiVisible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Stack(
          fit: .expand,
          children: [
            Positioned.fill(
              child: IgnorePointer(child: Container(color: Colors.black26)),
            ),
            Align(
              alignment: .topCenter,
              child: Padding(
                padding: const .all(8.0),
                child: Row(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .end,
                  children: [_buildSettingsButton(context)],
                ),
              ),
            ),
            Align(child: _buildActionRow(context, isPlaying: state.isPlaying)),
            Positioned(
              bottom: 0,
              right: 10,
              left: 10,
              child: _buildProgressWithDuration(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSettingsOverlay(context),
      child: const Icon(Icons.settings, color: Colors.white),
    );
  }

  void _showSettingsOverlay(BuildContext context) {
    if (_settingsOverlay != null) return;

    final wrapperKey = GlobalKey<_OverlaySettingsWrapperState>();

    _settingsOverlay = OverlayEntry(
      builder: (context) {
        return _OverlaySettingsWrapper(
          key: wrapperKey,
          onClose: () {
            _settingsOverlay?.remove();
            _settingsOverlay = null;
          },
          child: BlocProvider.value(
            value: player,
            child: _InlineSettingsContent(
              onClose: () {
                wrapperKey.currentState?.close();
              },
            ),
          ),
        );
      },
    );

    const GlobalObjectKey<OverlayState>(
      'top-overlay',
    ).currentState?.insert(_settingsOverlay!);
  }

  Widget _buildProgressWithDuration(BuildContext context) => Padding(
    padding: .only(bottom: widget.forceFullScreen ? 15 : 0),
    child: ValueListenableBuilder(
      valueListenable: player.minifiedPosition,
      builder: (context, value, child) {
        ///This will convert the 0-1 to the screen width respective value
        final double seekBarProgress = context.screenWidth * (1 - value);
        return GestureDetector(
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            player.add(
              SeekVideo.to(
                details.localPosition.dx / context.screenWidth,
                updateVisuallyOnly: true,
              ),
            );
            isSeekBarExpanded.value = true;
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            player.add(
              SeekVideo.to(details.localPosition.dx / context.screenWidth),
            );
            isSeekBarExpanded.value = false;
          },
          onTapUp: (TapUpDetails details) {
            player.add(
              SeekVideo.to(details.localPosition.dx / context.screenWidth),
            );
            isSeekBarExpanded.value = false;
          },
          onTapDown: (TapDownDetails details) {
            isSeekBarExpanded.value = true;
          },
          child: Column(
            crossAxisAlignment: .stretch,
            spacing: 2,
            children: [
              Padding(
                padding: const .symmetric(vertical: 7),
                child: Row(
                  children: [
                    CustomText(
                      player.progressDuration(value),
                      fontSize: 12,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall!.copyWith(color: Colors.white),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        player.add(TriggerFullScreen());
                      },
                      child: Container(
                        padding: const .all(0),
                        child: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: isSeekBarExpanded,
                builder: (context, isExpanded, child) {
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    reverseDuration: const Duration(milliseconds: 900),
                    child: _buildSeekBar(
                      context,
                      height: isExpanded ? 8 : 5,
                      seekBarProgress: seekBarProgress,
                    ),
                  );
                },
              ),
              const SizedBox(height: 5),
            ],
          ),
        );
      },
    ),
  );

  Widget _buildVideoErrorWidget(BuildContext context, VideoPlayerError state) {
    final isUnsupported = state.errorType == VideoErrorType.unsupported;
    const webLink = AppSettings.webLink;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Icon(
            isUnsupported ? Icons.videocam_off : Icons.error_outline,
            color: context.color.error,
            size: 40,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomText(
              isUnsupported
                  ? AppLabels.unsupportedVideoFormat.tr
                  : AppLabels.unableToPlayVideo.tr,
              style: TextStyle(fontSize: context.font.small),
              textAlign: TextAlign.center,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              if (!isUnsupported)
                GestureDetector(
                  onTap: () {
                    if (widget.url != null) {
                      player.add(
                        LoadVideo(
                          widget.url!,
                          onCompletion: widget.onVideoCompletion,
                          isHLS: widget.isHLS,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.color.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomText(
                      AppLabels.retry.tr,
                      style: TextStyle(fontSize: context.font.small),
                      color: context.color.onPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              if (isUnsupported && webLink.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    try {
                      await launchUrl(
                        Uri.parse(webLink),
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (_) {}
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.color.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomText(
                      AppLabels.openInWeb.tr,
                      style: TextStyle(fontSize: context.font.small),
                      color: context.color.onPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, {required bool isPlaying}) {
    return Row(
      mainAxisAlignment: .center,
      spacing: 30,
      children: [
        if (widget.showPreviousButton) _buildPreviousAction(context),
        _buildPlayAction(context, isPlaying: isPlaying),
        if (widget.showNextButton) _buildNextAction(context),
      ],
    );
  }

  Widget _buildNextAction(BuildContext context) {
    return GestureDetector(
      onTap: widget.onNextTap,
      child: Container(
        decoration: BoxDecoration(
          shape: .circle,
          color: context.color.textSecondary,
        ),
        padding: const .all(4),
        child: Icon(Icons.skip_next, color: context.color.surface),
      ),
    );
  }

  Widget _buildPreviousAction(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPreviousTap,
      child: Container(
        decoration: BoxDecoration(
          shape: .circle,
          color: context.color.textSecondary,
        ),
        padding: const .all(4),
        child: Icon(Icons.skip_previous, color: context.color.surface),
      ),
    );
  }

  Widget _buildPlayAction(BuildContext context, {required bool isPlaying}) {
    return GestureDetector(
      onTap: () => _onTapPlayAction(isPlaying: isPlaying),
      child: Container(
        decoration: BoxDecoration(
          shape: .circle,
          color: context.color.textSecondary,
        ),
        padding: const .all(8),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow_rounded,
          size: 36,
          color: context.color.surface,
        ),
      ),
    );
  }

  Widget _buildSeekBar(
    BuildContext context, {
    required double height,
    required double seekBarProgress,
  }) {
    return CustomSeekBar(
      thickness: height,
      fullLength: context.screenWidth,
      seekBarProgress: seekBarProgress,
    );
  }
}

class _OverlaySettingsWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onClose;

  const _OverlaySettingsWrapper({
    super.key,
    required this.child,
    required this.onClose,
  });

  @override
  State<_OverlaySettingsWrapper> createState() =>
      _OverlaySettingsWrapperState();
}

class _OverlaySettingsWrapperState extends State<_OverlaySettingsWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void close() {
    _controller.reverse().then((_) => widget.onClose());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background dimming
        Positioned.fill(
          child: GestureDetector(
            onTap: close,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(color: Colors.black54),
            ),
          ),
        ),
        // Bottom sheet
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                decoration: BoxDecoration(
                  color: context.color.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: SafeArea(top: false, child: widget.child),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Inline settings content widget that renders inside the video player's Stack.
/// This avoids Navigator/Scaffold dependency issues that arise because the
/// video player lives in an overlay Stack outside any Scaffold.
class _InlineSettingsContent extends StatefulWidget {
  final VoidCallback onClose;

  const _InlineSettingsContent({required this.onClose});

  @override
  State<_InlineSettingsContent> createState() => _InlineSettingsContentState();
}

enum _SettingsSubPanel { none, speed, quality }

class _InlineSettingsContentState extends State<_InlineSettingsContent> {
  _SettingsSubPanel _activePanel = _SettingsSubPanel.none;

  @override
  Widget build(BuildContext context) {
    if (_activePanel == _SettingsSubPanel.speed) {
      return _buildSpeedPanel(context);
    }
    if (_activePanel == _SettingsSubPanel.quality) {
      return _buildQualityPanel(context);
    }
    return _buildMainPanel(context);
  }

  Widget _buildMainPanel(BuildContext context) {
    final qualities =
        context.read<VideoPlayerBloc>().getState()?.source?.getQualities() ??
        [];
    final hasQualities = qualities.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(AppLabels.speed.tr),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => setState(() => _activePanel = _SettingsSubPanel.speed),
        ),
        if (hasQualities)
          ListTile(
            title: Text(AppLabels.quality.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                setState(() => _activePanel = _SettingsSubPanel.quality),
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

  Widget _buildSpeedPanel(BuildContext context) {
    final currentSpeed =
        context.watch<VideoPlayerBloc>().getState()?.speed ??
        PlaybackSpeed.normal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.arrow_back),
          title: Text(AppLabels.speed.tr),
          onTap: () => setState(() => _activePanel = _SettingsSubPanel.none),
        ),
        ...PlaybackSpeed.values.map((speed) {
          final bool isSelected = speed == currentSpeed;
          return ListTile(
            title: CustomText(
              speed.label,
              style: TextStyle(
                fontSize: context.font.medium,
                fontWeight: isSelected ? FontWeight.bold : null,
                color: isSelected ? context.color.primary : null,
              ),
            ),
            selected: isSelected,
            selectedTileColor: context.color.outline.withValues(alpha: 0.4),
            visualDensity: VisualDensity.compact,
            onTap: () {
              context.read<VideoPlayerBloc>().add(SetSpeed(speed));
              widget.onClose();
            },
          );
        }),
      ],
    );
  }

  Widget _buildQualityPanel(BuildContext context) {
    final qualities =
        context.read<VideoPlayerBloc>().getState()?.source?.getQualities() ??
        [];
    final currentQuality =
        context.watch<VideoPlayerBloc>().getState()?.quality ??
        Quality.notSpecified();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.arrow_back),
          title: Text(AppLabels.quality.tr),
          onTap: () => setState(() => _activePanel = _SettingsSubPanel.none),
        ),
        ...qualities.map((quality) {
          final bool isSelected = currentQuality == quality;
          return ListTile(
            title: CustomText(
              quality.name,
              style: TextStyle(
                fontSize: context.font.small,
                fontWeight: isSelected ? FontWeight.bold : null,
                color: isSelected ? context.color.primary : null,
              ),
            ),
            selected: isSelected,
            selectedTileColor: context.color.outline.withValues(alpha: 0.4),
            visualDensity: VisualDensity.compact,
            onTap: () {
              if (!isSelected) {
                context.read<VideoPlayerBloc>().add(SetQuality(quality));
              }
              widget.onClose();
            },
          );
        }),
      ],
    );
  }
}

class HorizontalDragGesturePrevention extends HorizontalDragGestureRecognizer {
  bool _hasRejected = false;

  HorizontalDragGesturePrevention({super.debugOwner});

  @override
  void addPointer(PointerDownEvent event) {
    _hasRejected = false;
    super.addPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent && !_hasRejected) {
      final dx = event.delta.dx.abs();
      final dy = event.delta.dy.abs();

      if (dy > dx) {
        _hasRejected = true;

        // This tells the gesture arena to reject this recognizer
        resolve(GestureDisposition.rejected);
        return;
      }
    }

    super.handleEvent(event);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _hasRejected = false;
    super.didStopTrackingLastPointer(pointer);
  }
}
