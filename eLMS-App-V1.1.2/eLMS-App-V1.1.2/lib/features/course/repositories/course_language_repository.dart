import 'package:elms/common/models/course_language_model.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/core/api/api_client.dart';

class CourseLanguageRepository {
  Future<DataClass<CourseLanguageModel>> fetchCourseLanguages() async {
    final Map<String, dynamic> response = await Api.get(
      Apis.getCourseLanguages,
    );

    return DataClass.fromResponse(CourseLanguageModel.fromJson, response);
  }
}
