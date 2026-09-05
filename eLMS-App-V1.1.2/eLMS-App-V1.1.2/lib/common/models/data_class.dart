// ignore_for_file: unintended_html_in_doc_comment

import 'package:elms/core/api/api_params.dart';

/// A generic wrapper class for list data responses (non-paginated)
class DataClass<T> {
  /// The main data payload as List<T>
  final List<T> data;

  /// Optional map containing additional metadata or contextual information
  final Map<String, dynamic>? extraData;

  /// Creates a new instance of DataClass
  DataClass({required this.data, this.extraData});

  factory DataClass.fromResponse(
    T Function(Map<String, dynamic> data) callback,
    Map<String, dynamic> response,
  ) {
    try {
      final rawData = response[ApiParams.data];
      if (rawData is List) {
        final List<T> data = rawData
            .map((item) => callback(Map<String, dynamic>.from(item as Map)))
            .toList();
        return DataClass(data: data);
      }
      return DataClass.empty();
    } catch (e, st) {
      throw 'in $T : $e, $st';
    }
  }

  factory DataClass.empty() {
    return DataClass<T>(data: []);
  }

  @override
  String toString() {
    return 'DataClass(data: $data, extraData: $extraData)';
  }
}

/// A generic wrapper class that encapsulates data along with metadata and additional information.
/// This class is designed to provide a consistent structure for API responses and data handling
/// across the application.
///
/// @param T The type of data being wrapped. This can be any type, from primitive types
/// to complex objects or collections.
class PaginatedDataClass<T> {
  /// The main data payload of type T
  final List<T> data;

  /// The total count or number of items, typically used for pagination
  final int total;

  /// Optional map containing additional metadata or contextual information
  /// that doesn't fit into the main data structure
  Map<String, dynamic>? extraData = {};
  final int totalPage;
  final int currentPage;

  /// Creates a new instance of DataClass
  ///
  /// @param data The main data payload
  /// @param total The total count of items
  /// @param extraData Optional additional metadata
  PaginatedDataClass({
    required this.data,
    required this.total,
    this.extraData,
    required this.totalPage,
    required this.currentPage,
  });

  factory PaginatedDataClass.fromResponse(
    T Function(Map<String, dynamic> data) callback,
    Map<String, dynamic> response,
  ) {
    final rawData = response[ApiParams.data];
    if (rawData == null) {
      return PaginatedDataClass.empty();
    }

    if (rawData is List) {
      if (rawData.isEmpty) {
        return PaginatedDataClass.empty();
      }
      try {
        final List<T> list = rawData
            .map((item) => callback(Map<String, dynamic>.from(item as Map)))
            .toList();
        return PaginatedDataClass(
          data: list,
          total: list.length,
          totalPage: 1,
          currentPage: 1,
        );
      } catch (e, st) {
        throw 'in $T : $e, $st';
      }
    }

    if (rawData is Map) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
      final int total = data[ApiParams.total] ?? 0;
      final dynamic rawList = data[ApiParams.data];
      List<T> list = [];
      if (rawList is List) {
        list = rawList
            .map((item) => callback(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      try {
        return PaginatedDataClass(
          data: list,
          total: total,
          totalPage: data[ApiParams.lastPage] ?? 1,
          currentPage: data[ApiParams.currentPage] ?? 1,
        );
      } catch (e, st) {
        throw 'in $T : $e, $st';
      }
    }

    return PaginatedDataClass.empty();
  }

  factory PaginatedDataClass.empty() {
    return PaginatedDataClass(data: [], total: 0, totalPage: 0, currentPage: 1);
  }

  @override
  String toString() {
    return 'DataClass(data: $data, total: $total, extraData: $extraData)';
  }
}
