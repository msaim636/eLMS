import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elms/core/localization/get_language.dart';
import 'package:elms/core/localization/language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  final GetLanguage _getLanguage;

  LanguageCubit(this._getLanguage) : super(LanguageInitial());

  Future<void> fetchLanguages() async {
    try {
      emit(LanguageProgress());

      final ({LanguageModel defaultLanguage, List<LanguageModel> languages})
      result = await _getLanguage.getList();

      emit(
        LanguageSuccess(
          languages: result.languages,
          defaultLanguage: result.defaultLanguage,
        ),
      );
    } catch (e) {
      emit(LanguageError(error: e.toString()));
    }
  }
}
