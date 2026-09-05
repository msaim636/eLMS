// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/message_model.dart';
import 'package:elms/features/course/repositories/discussion_repository.dart';

abstract class CreateDiscussionState {}

class CreateDiscussionInitial extends CreateDiscussionState {}

class CreateDiscussionInProgress extends CreateDiscussionState {}

class CreateDiscussionSuccess extends CreateDiscussionState {
  final DiscussionModel discussion;
  CreateDiscussionSuccess({required this.discussion});
}

final class CreateDiscussionFail extends ErrorState
    implements CreateDiscussionState {
  CreateDiscussionFail({required super.error});
}

class CreateDiscussionCubit extends Cubit<CreateDiscussionState> {
  final DiscussionRepository _repository = DiscussionRepository();
  CreateDiscussionCubit() : super(CreateDiscussionInitial());

  void create({
    required String text,
    required int courseId,
    int? parentDiscussionId,
  }) async {
    try {
      emit(CreateDiscussionInProgress());
      final DiscussionModel discussion = await _repository.createDiscussion(
        text: text,
        courseId: courseId,
        parentDiscussionId: parentDiscussionId,
      );
      emit(CreateDiscussionSuccess(discussion: discussion));
    } catch (e) {
      emit(CreateDiscussionFail(error: e));
    }
  }
}
