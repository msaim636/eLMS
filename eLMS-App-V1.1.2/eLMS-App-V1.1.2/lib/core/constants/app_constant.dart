class AppConstant {
  static const double kLoaderBackgroundOpacity = 0.8;
  static const int kDoubleTapSeekDuration = 10; //in seconds
  static const int kShimmerCount = 5; //in seconds
  static double calculatedBottomNavigationHight = 0;

  // Feature flag for experimental mini player with overlay navigation
  static const bool kEnableExperimentalMiniPlayer = false;

  /// Flag to control screen capture prevention.
  ///
  /// When set to `true`, prevents users from taking screenshots or
  /// screen recordings of the app content. This is useful for protecting
  /// copyrighted course materials and sensitive information.
  static const bool kPreventScreenCapture = true;

  /// Flag to enable screen width testing mode.
  ///
  /// When set to `true`, shows a floating control panel that allows
  /// testing the app at different screen widths to identify UI issues
  /// on smaller devices. Only enable during development/testing.
  static const bool kEnableScreenWidthTester = false;

  ///Turn this on if you want to log multipart form file request
  static const bool kEnabledConsoleAPILogging = false;

  /// Flag to enable experimental pattern gesture debug unlock.
  ///
  /// When set to `true`, enables the hidden pattern gesture system
  /// that allows unlocking debug menu by tapping specific patterns.
  /// This feature is experimental and may be removed in future versions.
  static const bool kEnableExperimentalPatternGestureDebug = false;

  /// Flag to enable the debug error tester button.
  ///
  /// When set to `true`, shows a floating debug button on the splash screen
  /// that allows testing various error scenarios. Should be disabled in
  /// production builds.
  static const bool kEnableDebugErrorTester = false;

  /// Flag to enable demo mode.
  ///
  /// When set to `true`, login fields are prefilled with [kDemoEmail] and
  /// [kDemoPassword], and email verification is skipped for [kDemoEmail].
  /// Used for showcasing the app (e.g. store reviews). Should be disabled in
  /// production builds.
  static const bool kIsDemoMode = bool.fromEnvironment('demoMode');

  /// Demo account email used when [kIsDemoMode] is enabled.
  static const String kDemoEmail = 'elms@gmail.com';

  /// Demo account password used when [kIsDemoMode] is enabled.
  static const String kDemoPassword = 'Test@123';
}
