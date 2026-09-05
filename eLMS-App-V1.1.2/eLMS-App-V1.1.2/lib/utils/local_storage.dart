import 'dart:async';

import 'package:elms/common/cubits/theme_cubit.dart';
import 'package:elms/common/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum AuthState { firstTime, unAuthenticated, guest, authenticated }

class LocalStorage {
  LocalStorage._();

  // Box names
  static const String _settingsBox = 'settings';
  static const String _userBox = 'user';
  static const String _themeBox = 'theme';
  static const String _recentSearchesBox = 'recent_searches';

  // Box instances
  static Box settings = Hive.box(_settingsBox);
  static Box user = Hive.box(_userBox);
  static Box theme = Hive.box(_themeBox);
  static Box recentSearches = Hive.box(_recentSearchesBox);

  // Keys for user box
  static const String _authStateKey = 'authState';

  static const String _token = 'token';
  static const String _userId = 'user_id';
  static const String _countryCode = 'country_code';
  static const String _countryCallingCode = 'country_calling_code';

  // Keys for theme box
  static const String _themeKey = 'theme';

  //keys for language box
  static const String _languageKey = 'language';
  static const String _languageRtlKey = 'language_rtl';

  // Keys for recent searches box
  static const String _recentSearchesKey = 'searches';

  // Keys for featured sections cache
  static const String _cachedSectionTypesKey = 'cached_section_types';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_userBox);
    await Hive.openBox(_themeBox);
    await Hive.openBox(_recentSearchesBox);

    // Check if auth state key exists, if not set it to firstTime
    if (!user.containsKey(_authStateKey)) {
      await setAuthState(AuthState.firstTime);
    }
  }

  static AuthState getAuthState() {
    final String stateName = user.get(_authStateKey);
    try {
      return AuthState.values.byName(stateName);
    } catch (_) {
      return AuthState.firstTime;
    }
  }

  static Future<void> setAuthState(AuthState state) async {
    await user.put(_authStateKey, state.name);
  }

  static Future<void> setUserAuthenticated() async {
    await setAuthState(AuthState.authenticated);
  }

  static Future<void> setUserNotAuthenticated() async {
    await setAuthState(AuthState.unAuthenticated);
  }

  static Future<void> setUserUnauthenticated() async {
    await setAuthState(AuthState.unAuthenticated);
  }

  static Future<void> setUserIsGuest() async {
    await setAuthState(AuthState.guest);
  }

  static Future<void> setUserAuthenticatedAsGuest() async {
    await setAuthState(AuthState.guest);
  }

  static Future<void> storeUserDetails(UserModel userModel) async {
    await user.putAll({
      _token: userModel.token,
      _userId: userModel.id,
      _countryCode: userModel.countryCode,
      _countryCallingCode: userModel.countryCallingCode,
    });
  }

  ///Auth token
  static String? get token {
    return user.get(_token);
  }

  static Future<void> clearToken() async {
    await user.delete(_token);
  }

  ///Country code
  static String? get countryCode {
    return user.get(_countryCode);
  }

  ///Country calling code
  static String? get countryCallingCode {
    return user.get(_countryCallingCode);
  }

  static Future<void> setFirstTimeUser(bool isFirstTime) async {
    await setAuthState(
      isFirstTime ? AuthState.firstTime : AuthState.unAuthenticated,
    );
  }

  static Future<bool> logoutUser() async {
    await setAuthState(AuthState.unAuthenticated);
    return true;
  }

  static void setTheme(ThemeState value) {
    theme.put(_themeKey, value.key);
  }

  static void setLocale(Locale locale, {bool isRtl = false}) async {
    await settings.put(_languageKey, locale.languageCode);
    await settings.put(_languageRtlKey, isRtl);
  }

  static Locale? getLocale() {
    final String? locale = settings.get(_languageKey);
    if (locale == null) {
      return null;
    }
    return Locale(locale);
  }

  static bool getIsRtl() {
    return settings.get(_languageRtlKey, defaultValue: false);
  }

  static ThemeState getTheme() {
    if (theme.get(_themeKey) == 'light' || theme.get(_themeKey) == null) {
      return LightTheme();
    } else {
      return DarkTheme();
    }
  }

  // Recent searches methods
  static List<Map<String, dynamic>> getRecentSearches() {
    final dynamic storedData = recentSearches.get(
      _recentSearchesKey,
      defaultValue: [],
    );
    if (storedData is List) {
      return storedData
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return [];
  }

  static Future<void> storeRecentSearches(
    List<Map<String, dynamic>> searches,
  ) async {
    await recentSearches.put(_recentSearchesKey, searches);
  }

  static Future<void> clearRecentSearches() async {
    await recentSearches.delete(_recentSearchesKey);
  }

  // Cached featured section types
  static List<String> getCachedSectionTypes() {
    final dynamic data = settings.get(_cachedSectionTypesKey);
    if (data is List) {
      return data.cast<String>();
    }
    return [];
  }

  static Future<void> setCachedSectionTypes(List<String> types) async {
    await settings.put(_cachedSectionTypesKey, types);
  }
}
