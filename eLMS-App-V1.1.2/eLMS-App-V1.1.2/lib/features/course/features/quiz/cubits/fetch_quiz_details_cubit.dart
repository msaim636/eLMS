import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/course/features/quiz/models/quiz_api_models.dart';
import 'package:elms/features/course/features/quiz/repositories/quiz_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchQuizDetailsState {}

class FetchQuizDetailsInitial extends FetchQuizDetailsState {}

class FetchQuizDetailsInProgress extends FetchQuizDetailsState {}

class FetchQuizDetailsSuccess extends FetchQuizDetailsState {
  final QuizInfoModel quizInfo;
  FetchQuizDetailsSuccess({required this.quizInfo});
}

final class FetchQuizDetailsFail extends ErrorState
    implements FetchQuizDetailsState {
  FetchQuizDetailsFail({required super.error});
}

class FetchQuizDetailsCubit extends Cubit<FetchQuizDetailsState> {
  final QuizRepository _repository;

  FetchQuizDetailsCubit(this._repository) : super(FetchQuizDetailsInitial());

  Future<void> fetchQuizDetails({required int courseChapterQuizId}) async {
    try {
      emit(FetchQuizDetailsInProgress());
      final QuizInfoModel quizInfo = await _repository.getQuizDetails(
        courseChapterQuizId: courseChapterQuizId,
      );
      emit(FetchQuizDetailsSuccess(quizInfo: quizInfo));
    } catch (e) {
      emit(FetchQuizDetailsFail(error: e));
    }
  }
}
