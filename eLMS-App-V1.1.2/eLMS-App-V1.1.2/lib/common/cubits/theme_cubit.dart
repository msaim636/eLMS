// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:elms/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elms/core/theme/app_theme.dart';

abstract class ThemeState {
  abstract String key;
}

class LightTheme extends ThemeState {
  @override
  String key = 'light';
}

class DarkTheme extends ThemeState {
  @override
  String key = 'dark';
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(LocalStorage.getTheme());

  AppTheme getCurrentTheme(BuildContext context) {
    if (state is LightTheme) {
      return AppTheme.light(context);
    }
    return AppTheme.dark(context);
  }

  void changeTheme(ThemeState theme) {
    LocalStorage.setTheme(theme);
    emit(theme);
  }
}
