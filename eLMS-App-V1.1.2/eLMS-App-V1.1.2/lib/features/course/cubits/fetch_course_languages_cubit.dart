import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/course_language_model.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/features/course/repositories/course_language_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FetchCourseLanguagesState {}

class FetchCourseLanguagesInitial extends FetchCourseLanguagesState {}

class FetchCourseLanguagesInProgress extends FetchCourseLanguagesState {}

class FetchCourseLanguagesSuccess extends FetchCourseLanguagesState {
  final List<CourseLanguageModel> languages;
  FetchCourseLanguagesSuccess(this.languages);
}

final class FetchCourseLanguagesFail extends ErrorState
    implements FetchCourseLanguagesState {
  FetchCourseLanguagesFail({required super.error});
}

class FetchCourseLanguagesCubit extends Cubit<FetchCourseLanguagesState> {
  final CourseLanguageRepository _repository = CourseLanguageRepository();

  FetchCourseLanguagesCubit() : super(FetchCourseLanguagesInitial());

  Future<void> fetch() async {
    try {
      emit(FetchCourseLanguagesInProgress());

      final DataClass<CourseLanguageModel> dataClass = await _repository
          .fetchCourseLanguages();

      emit(FetchCourseLanguagesSuccess(dataClass.data));
    } catch (e) {
      emit(FetchCourseLanguagesFail(error: e));
    }
  }

  List<CourseLanguageModel> getCourseLanguages() {
    if (state case final FetchCourseLanguagesSuccess success) {
      return success.languages;
    }
    return [];
  }
}
