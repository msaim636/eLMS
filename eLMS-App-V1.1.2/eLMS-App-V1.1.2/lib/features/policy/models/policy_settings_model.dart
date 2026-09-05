import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class PolicySettingsModel extends Model {
  final String pageContent;

  PolicySettingsModel({required this.pageContent});

  factory PolicySettingsModel.fromJson(Map<String, dynamic> json) {
    return PolicySettingsModel(
      pageContent: json.optional<String>('page_content') ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'page_content': pageContent};
  }
}
