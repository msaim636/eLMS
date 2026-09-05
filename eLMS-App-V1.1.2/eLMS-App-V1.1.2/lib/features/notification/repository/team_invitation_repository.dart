import 'package:elms/core/api/api_client.dart';

class TeamInvitationRepository {
  Future<Map<String, dynamic>> handleInvitation({
    required String action,
    required String invitationToken,
  }) async {
    final response = await Api.post(
      Apis.teamInvitationAction,
      data: {'action': action, 'invitation_token': invitationToken},
    );

    return response;
  }
}
