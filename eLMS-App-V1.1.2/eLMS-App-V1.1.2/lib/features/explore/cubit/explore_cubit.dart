import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/course_language_model.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/features/course/cubits/fetch_course_languages_cubit.dart';
import 'package:elms/features/course/models/filter.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/features/course/screens/filter_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ExploreCubit extends Cubit<ExploreState>
    with PaginationCapability<ExploreState, CourseModel> {
  final CourseRepository _repository;
  String _searchQuery = '';

  ExploreCubit(this._repository) : super(ExploreInitial());

  List<Filter> courseFilters = [
    Filter(
      apiKey: ApiParams.level,
      titleKey: AppLabels.courseLevels.tr,
      values: [
        FilterValue(titleKey: AppLabels.beginner, apiValue: 'beginner'),
        FilterValue(titleKey: AppLabels.intermediate, apiValue: 'intermediate'),
        FilterValue(titleKey: AppLabels.advanced, apiValue: 'advanced'),
      ],
      selectedValues: [],
    ),
    Filter(
      apiKey: 'course_type',
      titleKey: AppLabels.price,
      values: [
        FilterValue(titleKey: AppLabels.free, apiValue: 'free'),
        FilterValue(titleKey: AppLabels.paid, apiValue: 'paid'),
      ],
      selectedValues: [],
    ),
    Filter(
      titleKey: 'languages'.tr,
      apiKey: 'language_id',
      values:
          Get.context
              ?.read<FetchCourseLanguagesCubit>()
              .getCourseLanguages()
              .map((e) {
                return FilterValue(
                  titleKey: e.name,
                  apiValue: e.id.toString(),
                );
              })
              .toList() ??
          [],
      selectedValues: [],
    ),
    Filter(
      apiKey: 'duration_filter',
      titleKey: AppLabels.courseDuration,
      values: [
        FilterValue(titleKey: '1-4 Weeks', apiValue: '1-4_weeks'),
        FilterValue(titleKey: '4-12 Weeks', apiValue: '4-12_weeks'),
        FilterValue(titleKey: '3-6 Months', apiValue: '3-6_months'),
        FilterValue(titleKey: '6-12 Months', apiValue: '6-12_months'),
      ],
      selectedValues: [],
    ),
    RatingFilter(
      titleKey: 'rating'.tr,
      apiKey: 'rating_filter',
      values: [
        FilterValue(titleKey: '5', apiValue: '5'),
        FilterValue(titleKey: '4', apiValue: '4'),
        FilterValue(titleKey: '3', apiValue: '3'),
        FilterValue(titleKey: '2', apiValue: '2'),
        FilterValue(titleKey: '1', apiValue: '1'),
      ],
      selectedValues: [],
    ),
  ];

  void updateLanguageValues(List<CourseLanguageModel> languages) {
    final languageFilter = courseFilters.firstWhereOrNull(
      (f) => f.apiKey == 'language_id',
    );
    if (languageFilter != null) {
      languageFilter.values = languages
          .map((e) => FilterValue(titleKey: e.name, apiValue: e.id.toString()))
          .toList();
    }
  }

  void search(String query) {
    _searchQuery = query;
    fetch();
  }

  void applyFilters(List<Filter> filters) {
    courseFilters = filters;
    fetch();
  }

  void refresh() {
    currentPage = 1;
    fetch();
  }

  @override
  Future<void> fetch() async {
    await super.fetch();

    try {
      if (isForceFetch()) {
        emit(ExploreProgress());
      }

      final Map<String, dynamic> params = {
        if (_searchQuery.isNotEmpty) ApiParams.search: _searchQuery,
        ...courseFilters.apiExtraParams,
      };

      final PaginatedDataClass<CourseModel> result = await _repository.fetch(
        page: currentPage,
        extraParams: CourseParams(params),
      );

      data = result.data;

      emit(
        ExploreSuccess(
          total: result.total,
          data: List.from(data),
          isLoadingMore: false,
          hasLoadingMoreError: false,
          currentPage: currentPage,
          totalPage: result.totalPage,
        ),
      );
    } catch (e) {
      if (state is ExploreSuccess) {
        final currentState = state as ExploreSuccess;
        emit(
          currentState.copyWith(
            isLoadingMore: false,
            hasLoadingMoreError: true,
          ),
        );
      } else {
        if (e is CustomException) {
          emit(ExploreError(error: e));
        } else {
          emit(ExploreError(error: AppException.from(e as Exception)));
        }
      }
    }
  }
}

abstract base class ExploreState extends BaseState {}

final class ExploreInitial extends ExploreState {}

final class ExploreProgress extends ProgressState implements ExploreState {}

final class ExploreSuccess extends PaginatedApiSuccessState<CourseModel>
    implements ExploreState {
  ExploreSuccess({
    required super.total,
    required super.data,
    required super.isLoadingMore,
    required super.hasLoadingMoreError,
    required super.currentPage,
    required super.totalPage,
  });

  @override
  ExploreSuccess copyWith({
    int? total,
    List<CourseModel>? data,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasLoadingMoreError,
    int? currentPage,
    int? totalPage,
  }) {
    return ExploreSuccess(
      total: total ?? this.total,
      data: data ?? this.data,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadingMoreError: hasLoadingMoreError ?? this.hasLoadingMoreError,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
    );
  }
}

final class ExploreError extends ErrorState<CustomException>
    implements ExploreState {
  ExploreError({required super.error});
}
