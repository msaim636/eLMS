import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/settings/models/app_setting_model.dart';

abstract class SettingsState extends BaseState {}

class SettingsInitial extends SettingsState {}

class SettingsProgress extends SettingsState {}

class SettingsSuccess extends SettingsState {
  final AppSettingModel settings;

  SettingsSuccess({required this.settings});
}

final class SettingsError extends SettingsState {
  final String error;

  SettingsError({required this.error});
}
