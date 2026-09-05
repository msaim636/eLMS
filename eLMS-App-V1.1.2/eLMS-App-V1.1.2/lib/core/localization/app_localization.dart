import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:elms/core/localization/get_language.dart';
import 'package:elms/utils/local_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// AppLocalization is a wrapper around GetX localization system.
/// This abstraction layer makes it easier to switch to a different localization system in the future
/// if needed, without affecting the rest of the application.
final class AppLocalization {
  AppLocalization._();

  /// Singleton instance of AppLocalization
  static AppLocalization? _instance;
  static AppLocalization get instance {
    _instance ??= AppLocalization._();
    return _instance!;
  }

  /// Fallback locale to use when the selected or device locale fails to load
  Locale? fallbackLocale;

  /// Gets the current locale based on the following priority:
  /// 1. Fallback locale (if there was an error loading the selected locale)
  /// 2. User selected locale (stored in local storage)
  /// 3. Device locale (if supported by the app)
  Locale? get current {
    final Locale? deviceLocale = Get.deviceLocale;
    final Locale? selectedLocale = LocalStorage.getLocale();

    ///This will first check for fallback locale because in any case there is issue in loading language then first fallback language will be loaded
    ///Selected locale will be after that, if user has not selected any language then it will be looking for device locale if we have added it in our file
    /// Fallback locale will be always default locale
    return fallbackLocale ?? selectedLocale ?? deviceLocale;
  }

  /// Returns all available translation keys and their values
  Map<String, Map<String, String>> get translationKeys => Get.translations;

  /// Initializes the localization system with the current locale
  Future<void> init() async {
    await load(current!);
  }

  /// Changes the application's locale and persists the selection
  /// [locale] - The new locale to set
  /// [isRtl] - Whether the language is right-to-left
  FutureOr<void> setLocale(Locale locale, {bool isRtl = false}) async {
    LocalStorage.setLocale(locale, isRtl: isRtl);
    await load(locale);

    await Get.updateLocale(locale);
  }

  /// Loads translations for the specified locale
  /// If loading fails, falls back to the default language
  /// [locale] - The locale to load translations for
  Future<void> load(Locale locale) async {
    final result = await _loadLanguage(locale.languageCode);

    //Reset fallback locale if loading was successful
    fallbackLocale = null;
    Get.addTranslations(result.translations);

    // Store RTL property if not already stored
    if (LocalStorage.getLocale()?.languageCode == locale.languageCode) {
      LocalStorage.setLocale(locale, isRtl: result.isRtl);
    }
  }

  /// Loads translation data from API
  /// [locale] - The language code to load translations for
  /// Returns a map of translation keys and their values along with RTL property
  /// On error, falls back to loading template.json from assets
  Future<({Map<String, Map<String, String>> translations, bool isRtl})>
  _loadLanguage(String locale) async {
    try {
      final GetLanguage getLanguage = GetLanguage();
      final LanguageModel languageModel = await getLanguage.get(code: locale);

      return (
        translations: {
          locale: Map<String, String>.from(languageModel.translationsApp),
        },
        isRtl: languageModel.isRtl,
      );
    } catch (e) {
      // Fallback: Load template.json from assets if API call fails
      return await _loadTemplateJson(locale);
    }
  }

  /// Loads translation data from local template.json file
  /// [locale] - The language code to use for the translations key
  /// Returns a map of translation keys and their values along with RTL property
  Future<({Map<String, Map<String, String>> translations, bool isRtl})>
  _loadTemplateJson(String locale) async {
    final String jsonString = await rootBundle.loadString(
      'assets/languages/template.json',
    );
    final Map<String, dynamic> jsonData =
        json.decode(jsonString) as Map<String, dynamic>;

    // Convert JSON data to Map<String, String>
    final Map<String, String> translations = jsonData.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return (
      translations: {locale: translations},
      isRtl: false, // Template is in English, which is LTR
    );
  }
}
