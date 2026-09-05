import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:elms/common/cubits/theme_cubit.dart';
import 'package:elms/core/configs/app_settings.dart';
import 'package:elms/core/deep_linking/deep_link_manager.dart';
import 'package:elms/core/error_management/exception_handler.dart';
import 'package:elms/core/localization/app_localization.dart';
import 'package:elms/core/localization/get_language.dart';
import 'package:elms/core/localization/language_cubit.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/core/services/iap_manager.dart';
import 'package:elms/core/services/refresh_notifier.dart';
import 'package:elms/core/theme/app_theme.dart';
import 'package:elms/core/debug/test_error_config.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/course/screens/course_content_screen.dart';
import 'package:elms/features/main/main_screen.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:elms/features/cart/cubit/cart_cubit.dart';
import 'package:elms/features/cart/repository/cart_repository.dart';
import 'package:elms/features/category/cubits/fetch_category_cubit.dart';
import 'package:elms/features/category/repositories/category_repository.dart';
import 'package:elms/features/course/cubits/fetch_course_languages_cubit.dart';
import 'package:elms/features/video_player/bloc/video_player_bloc.dart';
import 'package:elms/features/video_player/video_player.dart';
import 'package:elms/features/wishlist/cubit/wishlist_action_cubit.dart';
import 'package:elms/features/wishlist/repository/wishlist_repository.dart';
import 'package:elms/features/policy/cubit/policy_cubit.dart';
import 'package:elms/features/policy/repository/policy_repository.dart';
import 'package:elms/features/settings/cubit/app_settings_cubit.dart';
import 'package:elms/features/settings/repository/settings_repository.dart';
import 'package:elms/utils/local_storage.dart';
import 'package:elms/utils/video/ghost_target.dart';
import 'package:elms/utils/video/mini_player.dart';
import 'package:elms/utils/video/player_manager.dart';
import 'package:elms/utils/video/player_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

class App extends StatefulWidget {
  final bool enableErrorHandling;
  const App({super.key, this.enableErrorHandling = true});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    if (Platform.isIOS) {
      IapManager.instance.initialize();
    }
    // Initialize RefreshNotifier service (doesn't require navigation context)
    Get.put(RefreshNotifier());

    // Reset overlay visibility whenever the course content is closed.
    courseContentNavigator.addListener(_onCourseContentNavigatorChanged);

    // Delay initialization that requires navigation context until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.enableErrorHandling) {
        ExceptionHandler.registerErrorSnackbarService();
      }
    });
  }

  void _onCourseContentNavigatorChanged() {
    if (courseContentNavigator.value == null) {
      courseContentRouteObserver.reset();
    }
  }

  @override
  void dispose() {
    courseContentNavigator.removeListener(_onCourseContentNavigatorChanged);
    WidgetsBinding.instance.removeObserver(this);
    DeepLinkManager.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(
          create: (context) => AuthenticationCubit(AuthRepository()),
        ),
        BlocProvider(
          create: (context) => FetchCategoryCubit(CategoryRepository()),
        ),
        BlocProvider(
          create: (context) => WishlistActionCubit(WishlistRepository()),
        ),
        BlocProvider(
          create: (BuildContext context) => CartCubit(CartRepository()),
        ),
        BlocProvider(create: (context) => FetchCourseLanguagesCubit()),
        BlocProvider(create: (context) => PolicyCubit(PolicyRepository())),
        BlocProvider(
          create: (context) => AppSettingsCubit(SettingsRepository()),
        ),
        BlocProvider(create: (context) => LanguageCubit(GetLanguage())),
      ],
      child: Builder(
        builder: (BuildContext context) {
          final AppTheme currentTheme = context
              .watch<ThemeCubit>()
              .getCurrentTheme(context);

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: currentTheme.isDarkMode
                ? SystemUiOverlayStyle.light.copyWith(
                    statusBarColor: Colors.transparent,
                  )
                : SystemUiOverlayStyle.dark.copyWith(
                    statusBarColor: Colors.transparent,
                  ),
            child: GetMaterialApp(
              debugShowCheckedModeBanner: false,
              getPages: AppRoutes.pages,
              title: AppSettings.appName,
              defaultTransition: .fadeIn,
              initialRoute: AppRoutes.splashScreen,
              navigatorObservers: [courseContentRouteObserver],
              localizationsDelegates: <LocalizationsDelegate>[
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                CountryLocalizations.getDelegate(enableLocalization: false),
              ],
              translationsKeys: AppLocalization.instance.translationKeys,
              locale: AppLocalization.instance.current,
              theme: currentTheme.theme,
              builder: (context, child) {
                final appChild = AnnotatedRegion(
                  value:
                      (!currentTheme.isDarkMode
                              ? SystemUiOverlayStyle.dark
                              : SystemUiOverlayStyle.light)
                          .copyWith(
                            statusBarColor: Colors.transparent,
                            systemNavigationBarColor:
                                currentTheme.theme.scaffoldBackgroundColor,
                            systemNavigationBarIconBrightness:
                                !currentTheme.isDarkMode
                                ? Brightness.dark
                                : Brightness.light,
                          ),
                  child: ColoredBox(
                    color: currentTheme.theme.scaffoldBackgroundColor,
                    child: SafeArea(
                      top: false,
                      bottom: Platform.isAndroid,
                      child: child!,
                    ),
                  ),
                );

                final bool isRtl = TestErrorSimulator.isRtlSimulationEnabled
                    ? !LocalStorage.getIsRtl()
                    : LocalStorage.getIsRtl();

                // Clip the video player to the content area so it cannot
                // render over the pinned AppBar when the placeholder scrolls
                // behind it. The boundary is status-bar height + AppBar height
                // (kToolbarHeight + 10 matches CourseDetailsAppBar.preferredSize).
                final double videoClipTop =
                    MediaQuery.of(context).padding.top + kToolbarHeight + 10;

                return Directionality(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: Stack(
                    children: [
                      appChild,
                      ValueListenableBuilder<bool>(
                        valueListenable: courseContentOverlayVisible,
                        builder: (context, isVisible, child) {
                          return Offstage(offstage: !isVisible, child: child);
                        },
                        child:
                            ValueListenableBuilder<
                              CourseContentScreenArguments?
                            >(
                              valueListenable: courseContentNavigator,
                              builder: (context, args, child) {
                                if (args == null) {
                                  return const SizedBox.shrink();
                                }
                                // CourseContentScreen is mounted here as a
                                // floating layer outside the Navigator, so it
                                // has no Overlay ancestor. Text fields (the
                                // discussion message bar) need one for their
                                // selection handles/toolbar. Provide a
                                // dedicated Overlay, keyed per course so it
                                // recreates when the course changes (the entry
                                // builder captures `args` once).
                                return SizedBox.expand(
                                  child: Overlay(
                                    key: ValueKey(
                                      'course-content-${args.course.id}',
                                    ),
                                    initialEntries: [
                                      OverlayEntry(
                                        builder: (context) =>
                                            CourseContentScreen.route(args),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      ),
                      const GhostTarget(),
                      const MiniPlayerTarget(),

                      Positioned(
                        top: videoClipTop,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ClipRect(
                          child: PlayerWrapper(
                            builder: (context) {
                              // The outer builder is built once and reused by
                              // PlayerWrapper's ListenableBuilder via `child:`,
                              // so reading `videoUri` directly here would never
                              // pick up a new video. Subscribe to the dedicated
                              // URI ValueNotifier so selecting another lecture
                              // rebuilds this subtree (with a fresh BlocProvider
                              // keyed by url) — fires only on the rare video
                              // change, never per drag tick.
                              return ValueListenableBuilder<Uri?>(
                                valueListenable:
                                    PlayerManager.instance.videoUriListenable,
                                builder: (context, uri, _) {
                                  final url = uri.toString();
                                  // HLS lectures expose the `/api/video/{id}/stream`
                                  // endpoint (not a media file). The flag is set by
                                  // the caller in PlayerManager.setVideo metadata so
                                  // LoadVideo routes it through HLSVideo.
                                  final bool isHLS =
                                      PlayerManager
                                          .instance
                                          .videoMetadata?['isHLS'] ==
                                      true;
                                  // Completion callback supplied by the screen
                                  // that started the video (e.g. the course
                                  // content screen marks the lecture complete at
                                  // 90% watched). Null for screens that don't
                                  // track completion.
                                  final VoidCallback? onVideoCompletion =
                                      PlayerManager
                                              .instance
                                              .videoMetadata?['onCompletion']
                                          as VoidCallback?;
                                  debugPrint(
                                    'PlayerWrapper rebuild -> url: $url',
                                  );
                                  // The `isMiniPlayer` flag must stay reactive
                                  // (otherwise tapping the mini-player only
                                  // shows controls instead of maximizing), so
                                  // subscribe to a dedicated ValueNotifier here
                                  // — fires only on the rare full↔mini
                                  // transition, never per drag tick.
                                  return BlocProvider(
                                    key: ValueKey('b-$url'),
                                    create: (context) => VideoPlayerBloc(),
                                    child: ValueListenableBuilder<bool>(
                                      valueListenable: PlayerManager
                                          .instance
                                          .isMinimizedListenable,
                                      builder: (context, isMini, _) =>
                                          CustomVideoPlayer(
                                            url: url,
                                            isHLS: isHLS,
                                            onVideoCompletion:
                                                onVideoCompletion,
                                            isMiniPlayer: isMini,
                                            onTapMiniPlayer: () {
                                              PlayerManager.instance.maximize();
                                            },
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      // Top-level overlay for the settings bottom sheet
                      const Positioned.fill(
                        child: Overlay(key: GlobalObjectKey('top-overlay')),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
