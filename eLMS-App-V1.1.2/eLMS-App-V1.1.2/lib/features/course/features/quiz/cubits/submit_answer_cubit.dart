import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/course/features/quiz/models/quiz_api_models.dart';
import 'package:elms/features/course/features/quiz/repositories/quiz_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SubmitAnswerState {}

class SubmitAnswerInitial extends SubmitAnswerState {}

class SubmitAnswerInProgress extends SubmitAnswerState {}

class SubmitAnswerSuccess extends SubmitAnswerState {
  final QuizAnswerModel answer;
  SubmitAnswerSuccess({required this.answer});
}

final class SubmitAnswerFail extends ErrorState implements SubmitAnswerState {
  SubmitAnswerFail({required super.error});
}

class SubmitAnswerCubit extends Cubit<SubmitAnswerState> {
  final QuizRepository _repository;

  SubmitAnswerCubit(this._repository) : super(SubmitAnswerInitial());

  Future<void> submitAnswer({
    required int quizQuestionId,
    required int quizOptionId,
    required int attemptId,
  }) async {
    try {
      emit(SubmitAnswerInProgress());
      final QuizAnswerModel answer = await _repository.submitAnswer(
        quizQuestionId: quizQuestionId,
        quizOptionId: quizOptionId,
        attemptId: attemptId,
      );
      emit(SubmitAnswerSuccess(answer: answer));
    } catch (e) {
      emit(SubmitAnswerFail(error: e));
    }
  }
}
