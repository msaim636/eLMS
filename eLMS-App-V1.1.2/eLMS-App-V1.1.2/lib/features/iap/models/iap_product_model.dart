import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

/// Represents a single in-app purchase product returned by the backend.
///
/// API endpoint : GET  iap/products
/// Sample JSON  :
/// ```json
/// {
///   "id": 1,
///   "product_id": "com.wrteam.elms.100",
///   "credit_value": "100.00",
///   "description": "100 Credits"
/// }
/// ```
class IapProductModel extends Model {
  /// Backend database ID
  final int? id;

  /// Store product identifier — used to query the platform store (Play / AppStore)
  final String? productId;

  /// Credits the user receives after a successful purchase
  final num? creditValue;

  /// Human-readable description, e.g. "100 Credits"
  final String? description;

  IapProductModel({
    this.id,
    this.productId,
    this.creditValue,
    this.description,
  });

  factory IapProductModel.fromJson(Map<String, dynamic> json) {
    return IapProductModel(
      id: json.optional<int>('id'),
      productId: json.optional<String>('product_id'),
      // credit_value comes as a String from the API ("100.00") — parse safely
      creditValue: num.tryParse(json.optional<String>('credit_value') ?? ''),
      description: json.optional<String>('description'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'credit_value': creditValue,
      'description': description,
    };
  }

  @override
  String toString() =>
      'IapProductModel(id: $id, productId: $productId, '
      'creditValue: $creditValue, description: $description)';
}
