import 'package:elms/common/models/blueprints.dart';
import 'package:elms/core/localization/get_language.dart';

abstract class LanguageState extends BaseState {}

class LanguageInitial extends LanguageState {}

class LanguageProgress extends LanguageState {}

class LanguageSuccess extends LanguageState {
  final List<LanguageModel> languages;
  final LanguageModel defaultLanguage;

  LanguageSuccess({required this.languages, required this.defaultLanguage});
}

final class LanguageError extends LanguageState {
  final String error;

  LanguageError({required this.error});
}
