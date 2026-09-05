import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/help_support/models/group_approval_status_model.dart';
import 'package:elms/features/help_support/repositories/help_desk_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CheckGroupApprovalState {}

class CheckGroupApprovalInitial extends CheckGroupApprovalState {}

class CheckGroupApprovalProgress extends CheckGroupApprovalState {}

class CheckGroupApprovalSuccess
    extends SuccessDataState<GroupApprovalStatusModel>
    implements CheckGroupApprovalState {
  CheckGroupApprovalSuccess({required super.data});
}

base class CheckGroupApprovalError extends ErrorState
    implements CheckGroupApprovalState {
  CheckGroupApprovalError({required super.error});
}

class CheckGroupApprovalCubit extends Cubit<CheckGroupApprovalState> {
  final HelpDeskRepository _repository;

  CheckGroupApprovalCubit(this._repository)
    : super(CheckGroupApprovalInitial());

  Future<void> checkApproval({required String groupSlug}) async {
    try {
      emit(CheckGroupApprovalProgress());

      final GroupApprovalStatusModel result = await _repository
          .checkGroupApproval(groupSlug: groupSlug);

      emit(CheckGroupApprovalSuccess(data: result));
    } catch (e) {
      emit(CheckGroupApprovalError(error: e));
    }
  }

  /// Refresh approval status after sending a request
  Future<void> refresh({required String groupSlug}) async {
    await checkApproval(groupSlug: groupSlug);
  }
}
