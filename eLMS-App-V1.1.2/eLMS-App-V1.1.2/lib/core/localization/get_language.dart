import 'package:elms/common/models/blueprints.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class GetLanguage {
  Future<LanguageModel> get({required String code}) async {
    final response = await Api.get(
      Apis.systemLanguages,
      data: {'code': code, 'system_type': 'app'},
    );

    final data = response[ApiParams.data] as Map<String, dynamic>;
    return LanguageModel.fromJson(
      (data[ApiParams.languages] as List).first as Map<String, dynamic>,
    );
  }

  Future<({LanguageModel defaultLanguage, List<LanguageModel> languages})>
  getList() async {
    final Map<String, dynamic> response = await Api.get(Apis.systemLanguages);
    final data = response[ApiParams.data] as Map<String, dynamic>;

    return (
      languages: (data[ApiParams.languages] as List)
          .map((e) => LanguageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      defaultLanguage: LanguageModel.fromJson(
        data['default_lang'] as Map<String, dynamic>,
      ),
    );
  }
}

class LanguageModel extends Model {
  final int id;
  final String name;
  final String code;
  final bool isRtl;
  final bool isDefault;
  final String image;
  final Map<String, dynamic> translationsApp;

  LanguageModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isRtl,
    required this.isDefault,
    required this.image,
    required this.translationsApp,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json.require<int>('id'),
      name: json.require<String>('name'),
      code: json.require<String>('code'),
      isRtl: json.require<bool>('is_rtl'),
      isDefault: json.require<bool>('is_default'),
      image: json.require<String>('image'),
      translationsApp: json.optional('translations_app') is List
          ? {}
          : json.optional<Map<String, dynamic>>('translations_app') ?? {},
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'is_rtl': isRtl,
    'is_default': isDefault,
    'image': image,
    'translations_app': translationsApp,
  };

  @override
  String toString() {
    return 'LanguageModel(id: $id, name: $name, code: $code, isRtl: $isRtl, isDefault: $isDefault, image: $image, translationsApp: ${translationsApp.length} items)';
  }
}
