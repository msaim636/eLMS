import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/features/wallet/models/wallet_transaction_model.dart';
import 'package:elms/features/wallet/models/withdrawal_request_model.dart';

/// Repository for managing wallet operations
/// Follows the Repository pattern extending Blueprint base class
class WalletRepository extends Blueprint {
  /// Fetches the wallet transaction history with pagination
  /// [page] - The page number to fetch
  /// [perPage] - Number of items per page
  /// Returns PaginatedDataClass containing list of WalletTransactionModel
  /// Throws exception if API call fails
  Future<PaginatedDataClass<WalletTransactionModel>> fetchWalletHistory({
    int? page,
    int? perPage,
    String? filterType,
  }) async {
    final Map<String, dynamic> params = {};

    if (page != null) params['page'] = page;
    if (perPage != null) params['per_page'] = perPage;
    if (filterType != null && filterType.isNotEmpty && filterType != 'all') {
      params['filter_type'] = filterType;
    }

    final response = await Api.get(Apis.walletHistory, data: params);

    return PaginatedDataClass.fromResponse(
        WalletTransactionModel.fromJson,
        response,
      )
      ..extraData = {
        'hasWithdrawalRequestPending':
            (response['data'] as Map)['is_withdrawal_request_pending'],
      };
  }

  /// Submits a withdrawal request
  /// [request] - The withdrawal request model containing all necessary details
  /// Returns the API response
  /// Throws exception if API call fails
  Future<Map<String, dynamic>> submitWithdrawalRequest({
    required WithdrawalRequestModel request,
  }) async {
    final response = await Api.post(
      Apis.withdrawalRequest,
      data: request.toMap(),
    );
    return response;
  }
}
