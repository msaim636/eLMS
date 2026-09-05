import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/features/settings/models/app_setting_model.dart';

class SettingsRepository {
  Future<AppSettingModel> fetchAppSettings() async {
    final Map<String, dynamic> response = await Api.get(Apis.appSettings);

    return AppSettingModel.fromJson(
      response[ApiParams.data] as Map<String, dynamic>,
    );
  }
}
