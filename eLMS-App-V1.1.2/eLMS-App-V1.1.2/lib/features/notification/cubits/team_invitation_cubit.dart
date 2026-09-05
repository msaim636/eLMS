import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/notification/repository/team_invitation_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TeamInvitationState {}

class TeamInvitationInitial extends TeamInvitationState {}

class TeamInvitationInProgress extends TeamInvitationState {}

class TeamInvitationSuccess extends TeamInvitationState {
  final String message;
  final String action;
  TeamInvitationSuccess({required this.message, required this.action});
}

final class TeamInvitationFail extends ErrorState
    implements TeamInvitationState {
  TeamInvitationFail({required super.error});
}

class TeamInvitationCubit extends Cubit<TeamInvitationState> {
  final TeamInvitationRepository _repository = TeamInvitationRepository();
  TeamInvitationCubit() : super(TeamInvitationInitial());

  void handleInvitation({
    required String action,
    required String invitationToken,
  }) async {
    try {
      emit(TeamInvitationInProgress());
      final response = await _repository.handleInvitation(
        action: action,
        invitationToken: invitationToken,
      );
      final message = response['message'] ?? '';
      emit(TeamInvitationSuccess(message: message, action: action));
    } catch (e) {
      emit(TeamInvitationFail(error: e));
    }
  }
}
