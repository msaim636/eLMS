import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/course/features/quiz/models/quiz_summary_model.dart';
import 'package:elms/features/course/features/quiz/repositories/quiz_summary_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchQuizSummaryState {}

class FetchQuizSummaryInitial extends FetchQuizSummaryState {}

class FetchQuizSummaryInProgress extends FetchQuizSummaryState {}

class FetchQuizSummarySuccess extends FetchQuizSummaryState {
  final QuizSummaryModel summary;
  FetchQuizSummarySuccess({required this.summary});
}

final class FetchQuizSummaryFail extends ErrorState
    implements FetchQuizSummaryState {
  FetchQuizSummaryFail({required super.error});
}

class FetchQuizSummaryCubit extends Cubit<FetchQuizSummaryState> {
  final QuizSummaryRepository _repository;

  FetchQuizSummaryCubit(this._repository) : super(FetchQuizSummaryInitial());

  Future<void> fetchQuizSummary({required int courseChapterQuizId}) async {
    try {
      emit(FetchQuizSummaryInProgress());
      final QuizSummaryModel summary = await _repository.fetchQuizSummary(
        courseChapterQuizId: courseChapterQuizId,
      );
      emit(FetchQuizSummarySuccess(summary: summary));
    } catch (e) {
      emit(FetchQuizSummaryFail(error: e));
    }
  }
}
