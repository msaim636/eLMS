import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/models/course_details_model.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourseDetailsCubit extends Cubit<CourseDetailsState> {
  final CourseRepository _repository;

  CourseDetailsCubit(this._repository) : super(CourseDetailsInitial());

  CourseDetailsModel? _courseDetails;
  CourseDetailsModel? get courseDetails => _courseDetails;

  Future<void> fetchCourseDetails(
    CourseModel initialCourse, {
    String? slug,
    int? id,
  }) async {
    try {
      emit(
        CourseDetailsProgress(
          initialData: CourseDetailsModel.fromCourseModel(initialCourse),
        ),
      );

      // Use courseId by default, but use slug when explicitly provided (e.g., for wishlist where id may be incorrect)
      // When slug is explicitly provided, don't pass courseId to ensure slug is used
      final result = await _repository.fetchCourseDetails(
        courseId: id ?? (slug != null ? null : initialCourse.id),
        slug: slug,
      );
      final apiCourseDetails = result;

      final mergedCourseDetails = CourseDetailsModel.fromCourseModel(
        initialCourse,
      ).mergeWithApiData(apiCourseDetails);

      _courseDetails = mergedCourseDetails;
      if (!isClosed) emit(CourseDetailsSuccess(data: mergedCourseDetails));
    } catch (e) {
      if (!isClosed) emit(CourseDetailsError(error: e.toString()));
    }
  }

  List<PreviewVideoModel> getPreviews() {
    if (state case final CourseDetailsSuccess success) {
      return success.data.previewVideos;
    }
    return [];
  }

  void reset() {
    _courseDetails = null;
    emit(CourseDetailsInitial());
  }

  void setInitialData(CourseDetailsModel courseDetails) {
    _courseDetails = courseDetails;
    emit(CourseDetailsSuccess(data: courseDetails));
  }

  Future<void> markCurriculumCompleted({
    required int chapterId,
    required int courseId,
    required CurriculumModel curriculum,
  }) async {
    if (state is! CourseDetailsSuccess) return;
    try {
      await _repository.markCurriculumCompleted(
        chapterId: chapterId,
        modelId: curriculum.id,
        modelType: curriculum.type ?? 'lecture',
      );
      final result = await _repository.fetchCourseDetails(courseId: courseId);
      if (!isClosed) {
        _courseDetails = result;
        emit(CourseDetailsSuccess(data: result));
      }
    } catch (_) {}
  }

  Future<void> refresh(int courseId) async {
    try {
      final result = await _repository.fetchCourseDetails(courseId: courseId);
      if (!isClosed) {
        _courseDetails = result;
        emit(CourseDetailsSuccess(data: result));
      }
    } catch (_) {}
  }

  int getChapterCount() {
    if (state case final CourseDetailsSuccess success) {
      return success.data.chapterCount;
    }
    return 0;
  }

  String getFormattedDuration() {
    if (state case final CourseDetailsSuccess success) {
      return success.data.totalDurationFormatted;
    }
    return '';
  }
}

abstract base class CourseDetailsState extends BaseState {}

final class CourseDetailsInitial extends CourseDetailsState {}

final class CourseDetailsProgress extends ProgressState
    implements CourseDetailsState {
  final CourseDetailsModel? initialData;

  CourseDetailsProgress({this.initialData});
}

final class CourseDetailsSuccess extends BaseState
    implements CourseDetailsState {
  final CourseDetailsModel data;

  CourseDetailsSuccess({required this.data});
}

final class CourseDetailsError extends ErrorState<String>
    implements CourseDetailsState {
  CourseDetailsError({required super.error});
}
