import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/features/iap/models/iap_product_model.dart';

/// Handles all backend calls related to in-app purchases.
///
/// Follows the same [Blueprint] repository pattern used everywhere else
/// in the app (e.g. [WalletRepository]).
class IapRepository extends Blueprint {
  /// Fetches the list of IAP products defined in the backend.
  ///
  /// Endpoint : GET  iap/products
  ///
  /// Returns a [DataClass] containing the list of [IapProductModel].
  /// Throws if the API call fails (handled by [ErrorHandlerInterceptor]).
  Future<DataClass<IapProductModel>> fetchProducts() async {
    final Map<String, dynamic> response = await Api.get(Apis.iapProducts);

    return DataClass.fromResponse(IapProductModel.fromJson, response);
  }
}
