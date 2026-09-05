import 'package:elms/core/login/login.dart';

class GuestLoginParameters extends LoginParameters {
  @override
  Map<String, dynamic> toMap() {
    return {};
  }
}

class GuestLoginResult {
  final bool success;

  GuestLoginResult(this.success);
}

class LoginAsGuest extends Login<GuestLoginResult> {
  @override
  void init() {}

  @override
  Future<LoginResponse<GuestLoginResult>> login() async {
    try {
      return LoginResponse(GuestLoginResult(true));
    } catch (e) {
      return LoginResponse(GuestLoginResult(false));
    }
  }
}
