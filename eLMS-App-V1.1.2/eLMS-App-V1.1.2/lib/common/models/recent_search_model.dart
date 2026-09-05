import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class RecentSearchModel extends Model {
  final String searchText;
  final int courseCount;
  final DateTime timestamp;
  final String? imageUrl;

  RecentSearchModel({
    required this.searchText,
    required this.courseCount,
    required this.timestamp,
    this.imageUrl,
  });

  factory RecentSearchModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchModel(
      searchText: json.require<String>('searchText'),
      courseCount: json.require<int>('courseCount'),
      timestamp: DateTime.parse(json.require<String>('timestamp')),
      imageUrl: json.optional<String>('imageUrl'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'searchText': searchText,
      'courseCount': courseCount,
      'timestamp': timestamp.toIso8601String(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentSearchModel && other.searchText == searchText;
  }

  @override
  int get hashCode => searchText.hashCode;
}
