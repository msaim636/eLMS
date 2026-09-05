import 'package:elms/common/models/data_class.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';

class CommonApiRepository {
  static Future<PaginatedDataClass<T>> fetchPaginatedData<T>({
    required String apiUrl,
    required Function(Map<String, dynamic> p1) fromJson,
    Map<String, dynamic>? extraParams,
    required int page,
    required bool hasAuthToken,
  }) async {
    try {
      final Map<String, dynamic> params = {
        ApiParams.page: page,
        ApiParams.perPage: 10,
        ...?extraParams,
      };
      final Map<String, dynamic> response = await Api.get(apiUrl, data: params);
      final data = response['data'] as Map<String, dynamic>;
      return PaginatedDataClass(
        data: List<T>.from(
          (data['data'] as List)
              .map((e) => fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        total: data['total'] as int,
        totalPage: data['last_page'] as int,
        currentPage: data['current_page'] as int,
      );
    } catch (e) {
      rethrow;
    }
  }
}
