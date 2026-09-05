import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/course/features/quiz/models/quiz_api_models.dart';
import 'package:elms/features/course/features/quiz/repositories/quiz_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FinishQuizState {}

class FinishQuizInitial extends FinishQuizState {}

class FinishQuizInProgress extends FinishQuizState {}

class FinishQuizSuccess extends FinishQuizState {
  final QuizFinishResponseModel response;
  FinishQuizSuccess({required this.response});
}

final class FinishQuizFail extends ErrorState implements FinishQuizState {
  FinishQuizFail({required super.error});
}

class FinishQuizCubit extends Cubit<FinishQuizState> {
  final QuizRepository _repository;

  FinishQuizCubit(this._repository) : super(FinishQuizInitial());

  Future<void> finishQuiz({required int attemptId}) async {
    try {
      emit(FinishQuizInProgress());
      final QuizFinishResponseModel response = await _repository.finishQuiz(
        attemptId: attemptId,
      );
      emit(FinishQuizSuccess(response: response));
    } catch (e) {
      emit(FinishQuizFail(error: e));
    }
  }
}
