import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/course/features/quiz/models/quiz_api_models.dart';
import 'package:elms/features/course/features/quiz/repositories/quiz_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StartQuizState {}

class StartQuizInitial extends StartQuizState {}

class StartQuizInProgress extends StartQuizState {}

class StartQuizSuccess extends StartQuizState {
  final QuizAttemptModel attempt;
  StartQuizSuccess({required this.attempt});
}

final class StartQuizFail extends ErrorState implements StartQuizState {
  StartQuizFail({required super.error});
}

class StartQuizCubit extends Cubit<StartQuizState> {
  final QuizRepository _repository;

  StartQuizCubit(this._repository) : super(StartQuizInitial());

  Future<void> startQuiz({required int courseChapterQuizId}) async {
    try {
      emit(StartQuizInProgress());
      final QuizAttemptModel attempt = await _repository.startQuiz(
        courseChapterQuizId: courseChapterQuizId,
      );
      emit(StartQuizSuccess(attempt: attempt));
    } catch (e) {
      emit(StartQuizFail(error: e));
    }
  }
}
