import 'package:country_code_picker/country_code_picker.dart';
import 'package:device_region/device_region.dart';
import 'package:get/get.dart';

class Utils {
  static CountryCode? simCountry;

  /// Builds a localized `<count> <word>` string, choosing the [singular] or
  /// [plural] label based on [count]. Pass label keys from `AppLabels`.
  ///
  /// e.g. `Utils.pluralize(1, singular: AppLabels.course, plural: AppLabels.courses)`
  /// → "1 Course", and `2` → "2 Courses".
  static String pluralize(
    num count, {
    required String singular,
    required String plural,
  }) {
    return '$count ${(count == 1 ? singular : plural).tr}';
  }

  static bool isYoutubeVideo(String url) {
    final RegExp regex = RegExp(
      r"(?:https?:\/\/)?(?:www\.|m\.)?(?:youtube\.com\/(?:watch\?v=|embed\/|shorts\/)|youtu\.be\/)([\w-]{11})",
      caseSensitive: false,
    );
    return regex.hasMatch(url);
  }

  static String? extractYoutubeVideoId(String url) {
    final regex = RegExp(
      r'(?:https?:\/\/)?(?:www\.|m\.)?'
      r'(?:youtube\.com\/(?:watch\?.*v=|embed\/|v\/|shorts\/|live\/)|youtu\.be\/)'
      r'([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );

    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  static Future<CountryCode?> getSIMCountry() async {
    try {
      final String? code = await DeviceRegion.getSIMCountryCode();
      if (code != null) {
        simCountry = CountryCode.fromCountryCode(code.toUpperCase());
        return simCountry;
      }
    } catch (_) {}
    return null;
  }
}
