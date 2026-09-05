import 'package:elms/features/settings/models/app_setting_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elms/features/settings/cubit/settings_state.dart';
import 'package:elms/features/settings/repository/settings_repository.dart';

class AppSettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  AppSettingsCubit(this._repository) : super(SettingsInitial());

  Future<void> fetchAppSettings() async {
    try {
      emit(SettingsProgress());

      final result = await _repository.fetchAppSettings();

      emit(SettingsSuccess(settings: result));
    } catch (e) {
      emit(SettingsError(error: e.toString()));
    }
  }

  void fetchIfFailed() {
    if (state is SettingsError || state is SettingsInitial) {
      fetchAppSettings();
    }
  }

  String get currencySymbol {
    if (state case final SettingsSuccess success) {
      return success.settings.currencySymbol ?? '';
    }
    return '';
  }

  bool get isMultiInstructorMode {
    if (settings?.instructorMode == null) {
      return true;
    }
    return settings?.instructorMode == 'multi';
  }

  AppSettingModel? get settings {
    if (state case final SettingsSuccess success) {
      return success.settings;
    }
    return null;
  }
}
