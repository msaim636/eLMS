import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/features/help_support/models/discussion_group.dart';
import 'package:elms/features/help_support/repositories/help_desk_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchDiscussionGroupsState {}

class FetchDiscussionGroupsInitial extends FetchDiscussionGroupsState {}

class FetchDiscussionGroupsInProgress extends FetchDiscussionGroupsState {}

class FetchDiscussionGroupsSuccess
    extends SuccessState<HelpDeskDiscussionGroupModel>
    implements FetchDiscussionGroupsState {
  FetchDiscussionGroupsSuccess({required super.data});
}

base class FetchDiscussionGroupsFail extends ErrorState
    implements FetchDiscussionGroupsState {
  FetchDiscussionGroupsFail({required super.error});
}

class FetchDiscussionGroupsCubit extends Cubit<FetchDiscussionGroupsState> {
  final HelpDeskRepository _repository = HelpDeskRepository();
  FetchDiscussionGroupsCubit() : super(FetchDiscussionGroupsInitial());

  void fetch({String? search}) async {
    try {
      emit(FetchDiscussionGroupsInProgress());
      final DataClass<HelpDeskDiscussionGroupModel> result = await _repository
          .fetchGroups(search: search);
      emit(FetchDiscussionGroupsSuccess(data: result.data));
    } catch (e) {
      emit(FetchDiscussionGroupsFail(error: e));
    }
  }
}
