import 'dart:async';
import 'dart:ui';

import 'package:elms/common/models/language_model.dart';
import 'package:elms/features/settings/cubit/app_settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  bool get isValidUrl => Uri.tryParse(this)?.hasAbsolutePath ?? false;

  // String get capitalize =>
  //     isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get currency {
    final num? value = num.tryParse(this);
    final String formatted = value != null ? value.toStringAsFixed(2) : this;
    return '${Get.context?.read<AppSettingsCubit>().currencySymbol} $formatted';
  }

  String get getDurationLabel {
    final int? totalHours = int.tryParse(this);

    if (totalHours == null || totalHours < 0) {
      return "Invalid";
    }

    final avg = Get.context
        ?.read<AppSettingsCubit>()
        .settings
        ?.weeklyAverageWatchHours;

    final int weeks = (totalHours / (avg ?? 1))
        .ceil()
        .clamp(1, double.infinity)
        .toInt();

    if (weeks == 1) return "1 week";
    if (weeks <= 2) return "1 - 2 weeks";
    if (weeks <= 4) return "2 - 4 weeks";
    if (weeks <= 8) return "4 - 8 weeks";
    if (weeks <= 12) return "3 - 4 months";
    if (weeks <= 16) return "4 - 6 months";
    if (weeks <= 20) return "6 - 8 months";
    if (weeks <= 24) return "8 - 10 months";
    if (weeks <= 28) return "10 - 12 months";

    return "12+ months";
  }

  String formatCountRounded(int value) {
    if (value < 10) return value.toString();

    int magnitude = 1;

    // Find highest power of 10 less than value
    while (magnitude * 10 <= value) {
      magnitude *= 10;
    }

    final int result = (value ~/ magnitude) * magnitude;

    return value == result ? "$result" : "$result+";
  }

  String translateWithTemplate(Map<String, String> params) {
    return tr.replaceAllMapped(
      RegExp(r'\{{(\w+)\}}'),
      (Match match) => params[match.group(1)] ?? '',
    );
  }

  bool containsAny(List<String> list) {
    if (list.any((element) => contains(element))) {
      return true;
    } else {
      return false;
    }
  }

  /// Formats a date string (e.g. "2025-01-13" or ISO 8601) as "January 13, 2025"
  String get toFormattedDate {
    final DateTime? date = DateTime.tryParse(this);
    if (date == null) return this;
    return DateFormat('MMMM d, yyyy').format(date);
  }

  /// Strips HTML tags from the string and decodes HTML entities
  String get stripHtmlTags {
    if (isEmpty) return this;

    // Remove HTML tags
    String result = replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode common HTML entities
    result = result
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—')
        .replaceAll('&hellip;', '…')
        .replaceAll('&bull;', '•');

    // Trim extra whitespace
    return result.trim();
  }
}

extension NumExtension on num {
  String get toStringWithCommas {
    final String number = toString();
    if (number.length >= 4) {
      return number.replaceRange(3, 4, ',');
    }
    return number;
  }

  double minMaxNormalize(double min, double max) {
    if (min == max) return 0.0; // Avoid division by zero
    return (this - min) / (max - min);
  }

  /// Rounds the rating to a single decimal place for a consistent display
  /// across the app (matching web), e.g. 4.33333 -> "4.3", 5 -> "5.0".
  String get ratingLabel => toStringAsFixed(1);
}

extension MapEx<K, V> on Map<K, V> {
  Map<K, V> removeEmptyKeys() {
    removeWhere((key, value) {
      return value == null || value == '';
    });

    return this;
  }

  Iterable<U> mapIndexed<U>(U Function(V e, int i) f) {
    var i = 0;
    return values.map<U>((it) {
      final t = i;
      i++;
      return f(it, t);
    });
  }
}

extension StreamEx<T> on Stream<T> {
  // Adds an `mapIndexed` method to Streams, which allows mapping with index
  Stream<U> mapIndexed<U>(U Function(T e, int i) f) {
    var i = 0;
    return transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(f(data, i));
          i++;
        },
      ),
    );
  }
}

extension IndexedAny<E> on List<E> {
  /// Checks if any element in the list satisfies the given [test] function.
  /// Provides the element and its index to the [test] function.
  /// Returns true if any element satisfies the condition.
  bool indexedAny(bool Function(E element, int index) test) {
    for (var i = 0; i < length; i++) {
      if (test(this[i], i)) {
        return true;
      }
    }
    return false;
  }

  List<E> get unique => toSet().toList();
  List<List<E>> chunked(int size) {
    final List<List<E>> chunks = [];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }

  E? get(int index) {
    try {
      return this[index];
    } catch (e) {
      return null;
    }
  }
}

extension LanguageListExtension on List<Language> {
  List<Locale> get supported =>
      map((language) => Locale(language.local)).toList();
  List<String> get supportedLocalString =>
      map((language) => language.local).toList();
}

extension DynamicExtension on Object {
  int? forceInt([int? defaultValue]) {
    if (this is String) {
      return int.parse(this as String);
    } else if (this is int) {
      return this as int;
    } else if (this is double) {
      return (this as double).toInt();
    } else if (this is num) {
      return (this as num).toInt();
    } else {
      return defaultValue;
    }
  }
}

extension JsonConversionExtensions on Map {
  T require<T>(String key) {
    try {
      final value = this[key];

      if ((T == int || T == double || T == num) && value is String) {
        num? parsed = num.tryParse(value);
        if (parsed == null) {
          throw Exception('Can not parse to int: $key value is {$value}');
        }
        if (T == int) {
          parsed = parsed.toInt();
        }
        if (T == double) {
          parsed = parsed.toDouble();
        }

        return parsed as T;
      }
      if (T == String && value is! String) {
        return value.toString() as T;
      }

      if (value is T) return value;
      throw Exception(
        "Key '$key' requires type '$T' but got '${value.runtimeType}' with value: $value",
      );
    } catch (_) {
      rethrow;
    }
  }

  T? optional<T>(String key) {
    final value = this[key];

    if (value == null) return null;
    if ((T == int || T == double || T == num) && value is String) {
      num? parsed = num.tryParse(value);
      if (T == int) {
        parsed = parsed?.toInt();
      }
      if (T == double) {
        parsed = parsed?.toDouble();
      }
      return parsed as T;
    }
    if (T == String && value is! String) {
      return value.toString() as T;
    }

    if (value is T) return value;
    throw Exception(
      "Key '$key' requires type '$T' but got '${value.runtimeType}' with value: $value",
    );
  }
}
