import 'dart:async';

import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/features/home/models/featured_section_model.dart';
import 'package:elms/utils/local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchFeaturedSectionsState {}

class FetchFeaturedSectionsInitial extends FetchFeaturedSectionsState {}

class FetchFeaturedSectionsInProgress extends FetchFeaturedSectionsState
    implements ProgressState {}

final class FetchFeaturedSectionsSuccess
    extends PaginatedApiSuccessState<FeaturedSectionModel>
    implements FetchFeaturedSectionsState {
  FetchFeaturedSectionsSuccess({
    required super.total,
    required super.data,
    required super.isLoadingMore,
    required super.hasLoadingMoreError,
    required super.currentPage,
    required super.totalPage,
  });

  @override
  PaginatedApiSuccessState<FeaturedSectionModel> copyWith({
    int? total,
    List<FeaturedSectionModel>? data,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasLoadingMoreError,
    int? currentPage,
    int? totalPage,
  }) {
    return FetchFeaturedSectionsSuccess(
      total: total ?? this.total,
      data: data ?? this.data,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadingMoreError: hasLoadingMoreError ?? this.hasLoadingMoreError,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
    );
  }
}

final class FetchFeaturedSectionsFail extends ErrorState
    implements FetchFeaturedSectionsState {
  FetchFeaturedSectionsFail({required super.error});
}

class FetchFeaturedSectionsCubit extends Cubit<FetchFeaturedSectionsState> {
  final CourseRepository _courseRepository;
  FetchFeaturedSectionsCubit(this._courseRepository)
    : super(FetchFeaturedSectionsInProgress());

  Future<void> fetch() async {
    try {
      emit(FetchFeaturedSectionsInProgress());
      final List<FeaturedSectionModel> response = await _courseRepository
          .fetchFeaturedSectionProducts();
      emit(
        FetchFeaturedSectionsSuccess(
          total: response.length,
          data: response,
          isLoadingMore: false,
          hasLoadingMoreError: false,
          currentPage: 1,
          totalPage: 1,
        ),
      );

      /// Cache section types for shimmer order on next app open
      unawaited(
        LocalStorage.setCachedSectionTypes(
          response.map((s) => s.type).toList(),
        ),
      );
    } catch (e) {
      emit(FetchFeaturedSectionsFail(error: e));
    }
  }
}
