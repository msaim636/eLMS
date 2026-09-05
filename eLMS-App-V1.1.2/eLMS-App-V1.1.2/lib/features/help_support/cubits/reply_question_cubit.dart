import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/message_model.dart';
import 'package:elms/features/help_support/repositories/help_desk_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ReplyQuestionState {}

class ReplyQuestionInitial extends ReplyQuestionState {}

class ReplyQuestionInProgress extends ReplyQuestionState {}

class ReplyQuestionSuccess extends ReplyQuestionState {
  final Message reply;
  ReplyQuestionSuccess({required this.reply});
}

final class ReplyQuestionFail extends ErrorState implements ReplyQuestionState {
  ReplyQuestionFail({required super.error});
}

class ReplyQuestionCubit extends Cubit<ReplyQuestionState> {
  final HelpDeskRepository _helpDeskRepository = HelpDeskRepository();
  ReplyQuestionCubit() : super(ReplyQuestionInitial());

  void reply({required int id, required String reply}) async {
    try {
      emit(ReplyQuestionInProgress());
      final response = await _helpDeskRepository.replyQuestion(
        id: id,
        reply: reply,
      );
      final replyMessage = Message.fromJson(response['data']);
      emit(ReplyQuestionSuccess(reply: replyMessage));
    } catch (e) {
      emit(ReplyQuestionFail(error: e));
    }
  }
}
