import 'package:elms/common/models/blueprints.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/features/cart/models/billing_details_model.dart';

/// Repository for managing billing details data operations
/// Follows the Repository pattern extending Blueprint base class
class BillingDetailsRepository extends Blueprint {
  /// Fetches the billing details from the API
  /// Returns [BillingDetailsModel] if billing details exist, null otherwise
  /// Throws exception if API call fails
  Future<BillingDetailsModel?> get() async {
    final Map<String, dynamic> response = await Api.get(Apis.billingDetails);

    if (response[ApiParams.data] != null) {
      return BillingDetailsModel.fromJson(
        response[ApiParams.data] as Map<String, dynamic>,
      );
    }

    return null;
  }

  /// Creates new billing details
  /// Returns [BillingDetailsModel] with the created billing details
  /// Throws exception if API call fails or billing details already exist
  Future<BillingDetailsModel> create({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String address,
    required String city,
    required String state,
    String? postalCode,
    String? taxId,
  }) async {
    final Map<String, dynamic> params = {
      'first_name': firstName,
      'last_name': lastName,
      'country_code': countryCode,
      'address': address,
      'city': city,
      'state': state,
    };

    if (postalCode != null) {
      params['postal_code'] = postalCode;
    }

    if (taxId != null) {
      params['tax_id'] = taxId;
    }

    final Map<String, dynamic> response = await Api.post(
      Apis.billingDetails,
      data: params,
    );

    return BillingDetailsModel.fromJson(
      response[ApiParams.data] as Map<String, dynamic>,
    );
  }

  /// Updates existing billing details
  /// Returns [BillingDetailsModel] with the updated billing details
  /// Throws exception if API call fails
  Future<BillingDetailsModel> update({
    String? firstName,
    String? lastName,
    String? countryCode,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? taxId,
  }) async {
    final Map<String, dynamic> params = {};

    if (firstName != null) params['first_name'] = firstName;
    if (lastName != null) params['last_name'] = lastName;
    if (countryCode != null) params['country_code'] = countryCode;
    if (address != null) params['address'] = address;
    if (city != null) params['city'] = city;
    if (state != null) params['state'] = state;
    if (postalCode != null) params['postal_code'] = postalCode;
    if (taxId != null) params['tax_id'] = taxId;

    final Map<String, dynamic> response =
        await Api.patch(Apis.billingDetails, data: params)
            as Map<String, dynamic>;

    return BillingDetailsModel.fromJson(
      response[ApiParams.data] as Map<String, dynamic>,
    );
  }
}
