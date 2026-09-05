/// Global application configuration settings.
///
/// This class contains all the core configuration constants used throughout
/// the ELMS application. It uses a private constructor to prevent instantiation
/// and exposes all settings as static members.
///
/// Usage:
/// ```dart
/// String name = AppSettings.appName;
/// String api = AppSettings.baseUrl;
/// ```
class AppSettings {
  /// Private constructor to prevent instantiation of this utility class.
  const AppSettings._();

  /// The display name of the application.
  ///
  /// Used in app bars, splash screens, and other UI elements where the
  /// application name needs to be displayed.
  static const String appName = 'eLMS';

  /// The base URL for all API endpoints.
  ///
  /// This is the root URL for the backend API server. All API calls
  /// are made relative to this base URL.
  ///
  /// Example: `$baseUrl/api/v1/courses`

  static String get baseUrl => 'https://elms.wrteam.me/';

  /// The web version URL of the application.
  ///
  /// This link can be used for sharing the web version of the platform
  /// or for redirecting users to the browser-based interface.
  static const String webLink = 'http://elms-web.wrteam.me';

  /// Duration in seconds for OTP timer countdown.
  /// Specifies how long users have to enter the OTP before it expires.
  /// and they need to request a new one. Default is 120 seconds (2 minutes).
  static const int otpTimerDuration = 120;

  /// Default country dial code for phone number input.
  ///
  /// Used as the pre-selected country code in phone number fields.
  static const int defaultDialCode = 91;
}
