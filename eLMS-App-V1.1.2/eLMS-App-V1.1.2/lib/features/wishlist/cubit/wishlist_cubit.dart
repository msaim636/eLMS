import 'package:elms/common/cubits/paginated_api_cubit.dart';
import 'package:elms/common/cubits/paginated_api_states.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/core/api/api_client.dart';

class FetchWishlistCubit extends PaginatedApiCubit<CourseModel> {
  FetchWishlistCubit() {
    fetchData();
  }

  @override
  String get apiUrl => Apis.getWishlist;

  @override
  CourseModel Function(Map<String, dynamic>) get fromJson =>
      CourseModel.fromJson;

  @override
  bool get useAuthToken => true;

  void removeItemFromList(int courseId) {
    if (state is PaginatedApiSuccessState<CourseModel>) {
      final currentState = state as PaginatedApiSuccessState<CourseModel>;
      final updatedData = currentState.data
          .where((course) => course.id != courseId)
          .toList();

      emit(
        PaginatedApiSuccessState<CourseModel>(
          data: updatedData,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
        ),
      );
    }
  }
}
