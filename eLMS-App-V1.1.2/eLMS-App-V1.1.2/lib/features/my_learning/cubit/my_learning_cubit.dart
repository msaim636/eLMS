import 'package:elms/common/cubits/paginated_api_cubit.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/core/api/api_lists.dart';

class MyLearningCubit extends PaginatedApiCubit<CourseModel> {
  final String status;
  MyLearningCubit(this.status);
  @override
  String get apiUrl => Apis.myLearning;

  @override
  CourseModel Function(Map<String, dynamic>) get fromJson =>
      CourseModel.fromJson;

  @override
  Map<String, dynamic>? get extraParams => {'progress_status': status};

  @override
  bool get useAuthToken => true;
}
