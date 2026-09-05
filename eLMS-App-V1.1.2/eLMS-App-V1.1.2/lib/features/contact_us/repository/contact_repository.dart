import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';

class ContactRepository {
  Future<Map<String, dynamic>> submitContactForm({
    required String firstName,
    required String email,
    required String message,
  }) async {
    try {
      final response = await Api.post(
        Apis.contactUs,
        data: {
          ApiParams.firstName: firstName,
          ApiParams.email: email,
          ApiParams.message: message,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
