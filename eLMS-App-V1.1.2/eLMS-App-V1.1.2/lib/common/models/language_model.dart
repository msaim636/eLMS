import 'package:elms/common/models/blueprints.dart';

class Language extends Model {
  final String name;
  final String local;

  Language({required this.name, required this.local});

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}
