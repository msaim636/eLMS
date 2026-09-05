import 'package:elms/common/models/data_class.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/features/home/models/slider_model.dart';

class SliderRepository {
  Future<DataClass<SliderModel>> fetchSliders() async {
    return DataClass<SliderModel>.fromResponse(
      SliderModel.fromJson,
      await Api.get(Apis.slider),
    );
  }
}
