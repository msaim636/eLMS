import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/category_model.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class CategoryRepository extends ICategoryRepository {
  @override
  Future<PaginatedDataClass<CategoryModel>> fetch({
    int? page,
    int? perPage,
    String? id,
    bool isTree = false,
  }) async {
    return PaginatedDataClass.fromResponse(
      CategoryModel.fromJson,
      await Api.get(
        isTree ? Apis.categoriesTree : Apis.categories,
        data: {
          ApiParams.page: page,
          ApiParams.perPage: perPage,
          if (id != null) ApiParams.id: id,
          if (id != null) ApiParams.getSubcategory: 1,
        }.removeEmptyKeys(),
      ),
    );
  }
}
