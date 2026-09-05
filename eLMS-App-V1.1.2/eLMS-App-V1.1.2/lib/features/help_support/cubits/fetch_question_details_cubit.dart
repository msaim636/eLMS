import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/help_support/models/help_desk_reply_model.dart';
import 'package:elms/features/help_support/repositories/help_desk_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchQuestionDetailsState {}

class FetchQuestionDetailsInitial extends BaseState
    implements FetchQuestionDetailsState {}

class FetchQuestionDetailsInProgress extends ProgressState
    implements FetchQuestionDetailsState {}

class FetchQuestionDetailsSuccess extends SuccessState<HelpDeskReplyModel>
    implements FetchQuestionDetailsState {
  final int repliesCount;
  FetchQuestionDetailsSuccess({
    required super.data,
    required this.repliesCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FetchQuestionDetailsSuccess &&
        other.repliesCount == repliesCount &&
        other.data.length == data.length;
  }

  @override
  int get hashCode => repliesCount.hashCode ^ data.length.hashCode;
}

final class FetchQuestionDetailsFailure extends ErrorState<String>
    implements FetchQuestionDetailsState {
  FetchQuestionDetailsFailure({required super.error});
}

class FetchQuestionDetailsCubit extends Cubit<FetchQuestionDetailsState> {
  final HelpDeskRepository _repository = HelpDeskRepository();
  List<HelpDeskReplyModel> _replies = [];
  int _repliesCount = 0;

  FetchQuestionDetailsCubit() : super(FetchQuestionDetailsInitial());

  Future<void> fetch({required int questionId, int? page, int? perPage}) async {
    try {
      if (page == 1 || page == null) {
        emit(FetchQuestionDetailsInProgress());
      }

      final response = await _repository.fetchQuestionDetails(
        questionId: questionId,
        page: page,
        perPage: perPage,
      );

      final data = response['data'] as Map<String, dynamic>;
      final repliesList = (data['replies'] as List<dynamic>)
          .map(
            (reply) =>
                HelpDeskReplyModel.fromJson(reply as Map<String, dynamic>),
          )
          .toList()
          .reversed
          .toList();

      if (page == 1 || page == null) {
        _replies = repliesList;
      } else {
        _replies.addAll(repliesList);
      }

      _repliesCount =
          (data['replies_count'] as int?) ?? (data['total'] as int?) ?? 0;

      emit(
        FetchQuestionDetailsSuccess(
          data: _replies,
          repliesCount: _repliesCount,
        ),
      );
    } catch (e) {
      emit(FetchQuestionDetailsFailure(error: e.toString()));
    }
  }

  void insertReply(HelpDeskReplyModel reply) {
    _replies.add(reply);
    _repliesCount++;
    emit(
      FetchQuestionDetailsSuccess(
        data: [..._replies],
        repliesCount: _repliesCount,
      ),
    );
  }

  void clear() {
    _replies.clear();
    _repliesCount = 0;
    emit(FetchQuestionDetailsInitial());
  }
}
