import 'package:elms/common/models/blueprints.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class SliderModel extends Model {
  final int id;
  final String image;
  final String? thirdPartyLink;
  final String? modelType;
  final int? modelId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String type;
  final String value;

  SliderModel({
    required this.id,
    required this.image,
    this.thirdPartyLink,
    this.modelType,
    this.modelId,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    required this.value,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    try {
      return SliderModel(
        id: json.require<int>('id'),
        image: json.require<String>('image'),
        thirdPartyLink: json.optional<String>('third_party_link'),
        modelType: json.optional<String>('model_type'),
        modelId: json.optional<int>('model_id'),
        createdAt: DateTime.parse(json.require<String>('created_at')),
        updatedAt: DateTime.parse(json.require<String>('updated_at')),
        type: json.require<String>('type'),
        value: json.require<String>('value'),
      );
    } catch (e) {
      throw ApiException(message: 'Error is $e');
    }
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'third_party_link': thirdPartyLink,
      'model_type': modelType,
      'model_id': modelId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'type': type,
      'value': value,
    };
  }
}
