import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/help_support/repositories/help_desk_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AskQuestionState {}

class AskQuestionInitial extends AskQuestionState {}

class AskQuestionInProgress extends AskQuestionState {}

class AskQuestionSuccess extends AskQuestionState {
  final Map<String, dynamic> response;
  AskQuestionSuccess({required this.response});
}

final class AskQuestionFail extends ErrorState implements AskQuestionState {
  AskQuestionFail({required super.error});
}

class AskQuestionCubit extends Cubit<AskQuestionState> {
  final HelpDeskRepository _helpDeskRepository;

  AskQuestionCubit(this._helpDeskRepository) : super(AskQuestionInitial());

  Future<void> askQuestion({
    required int groupId,
    required String title,
    required String description,
  }) async {
    try {
      emit(AskQuestionInProgress());
      final response = await _helpDeskRepository.askQuestion(
        groupId: groupId,
        title: title,
        description: description,
      );
      emit(AskQuestionSuccess(response: response));
    } catch (e) {
      emit(AskQuestionFail(error: e));
    }
  }

  void reset() {
    emit(AskQuestionInitial());
  }
}
