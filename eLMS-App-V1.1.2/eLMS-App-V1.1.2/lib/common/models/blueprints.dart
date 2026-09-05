// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/utils/extensions/scroll_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elms/common/models/category_model.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/features/video_player/video_source.dart';

/// Base abstract class that serves as the foundation for all blueprint classes in the application.
/// Blueprints define the contract and structure for different architectural components.
abstract class Blueprint {}

/// Abstract class representing the contract for all repository implementations.
/// Repositories are responsible for data access and manipulation operations.
/// Extends Blueprint to maintain architectural consistency.

/// Abstract class defining the contract for all model classes in the application.
/// Models represent the data structures and provide serialization capabilities.
/// Extends Blueprint to maintain architectural consistency.
abstract class Model extends Blueprint {
  // /// Converts the model instance to a JSON representation
  // /// @return A map containing the model's data in JSON format
  Map<String, dynamic> toJson();
}

/// Base class for all route arguments
abstract class RouteArguments implements Blueprint {
  const RouteArguments();
  Map<String, dynamic> toMap() {
    return {};
  }
}

///This is for implement new video source like if your video link requires pre-processing then you will need to do process inside the getSource method otherwise just implement and return the same url again
abstract class VideoSource implements Blueprint {
  Quality currentQuality = Quality.notSpecified();

  FutureOr<String> getSource();

  ///Optional but can be implemented in the child classes to get video quality option visible in video player
  List<Quality> getQualities() => <Quality>[];
}

abstract class BaseState implements Blueprint {}

class InitialState extends BaseState {}

class ProgressState extends BaseState {}

class SuccessState<T> extends BaseState {
  final List<T> data;

  SuccessState({required this.data});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuccessState<T> && listEquals(other.data, data);
  }

  @override
  int get hashCode => data.hashCode;
}

class SuccessDataState<T> extends BaseState {
  final T data;

  SuccessDataState({required this.data});
}

base class ErrorState<T> extends BaseState {
  final T error;
  ErrorState({required this.error});
}

//This is blueprint of success state so all the success states in the app will extend this for consistency
abstract class PaginatedApiSuccessState<T> extends BaseState {
  final int total;
  final List<T> data;
  bool isLoadingMore;
  final bool hasLoadingMoreError;
  final int currentPage;
  final int totalPage;

  PaginatedApiSuccessState({
    required this.total,
    required this.data,
    required this.isLoadingMore,
    required this.hasLoadingMoreError,
    required this.currentPage,
    required this.totalPage,
  });

  PaginatedApiSuccessState<T> copyWith({
    int? total,
    List<T>? data,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasLoadingMoreError,
    int? currentPage,
    int? totalPage,
  });

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    if (other is! PaginatedApiSuccessState<T>) return false;

    return other.total == total &&
        listEquals(other.data, data) &&
        other.isLoadingMore == isLoadingMore &&
        other.hasLoadingMoreError == hasLoadingMoreError &&
        other.currentPage == currentPage &&
        other.totalPage == totalPage;
  }

  @override
  int get hashCode {
    return total.hashCode ^
        data.hashCode ^
        isLoadingMore.hashCode ^
        hasLoadingMoreError.hashCode ^
        currentPage.hashCode ^
        totalPage.hashCode;
  }
}

/// use this class as mixin in Cubit with two parameters first is State and second is model name.
mixin PaginationCapability<T, D extends Model> on Cubit<T> {
  int currentPage = 1;
  final List<D> _resultList = [];

  set data(List<D> data) {
    if (currentPage > 1) {
      _resultList.addAll(data);
    } else {
      _resultList
        ..clear()
        ..addAll(data);
    }
  }

  List<D> get data {
    return _resultList;
  }

  ///This means if the page is not loading for pagination and state is not success
  bool isForceFetch() {
    return !(state is PaginatedApiSuccessState &&
        (state as PaginatedApiSuccessState).isLoadingMore);
  }

  @mustCallSuper
  Future<void> fetch() async {
    if (isForceFetch()) {
      currentPage = 1;
    }
  }

  @mustCallSuper
  void fetchMore() async {
    if (!hasMore()) {
      return;
    }

    if (state case final PaginatedApiSuccessState successState) {
      if (successState.isLoadingMore) return;
      emit(successState.copyWith(isLoadingMore: true) as T);
      currentPage = successState.currentPage + 1;
      await fetch();
    }
  }

  bool hasMore() {
    if (state case final PaginatedApiSuccessState successState) {
      return successState.currentPage < successState.totalPage;
    }
    return false;
  }
}

/// use this as mixin in state with the State and cubit name params
mixin Pagination<T extends StatefulWidget, P extends PaginationCapability>
    on State<T> {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.isEndReached) {
        context.read<P>().fetchMore();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }
}

abstract class IShimmer implements Blueprint {}

abstract interface class DataSource implements Blueprint {}

///[Repository Blueprints]
abstract class ICategoryRepository {
  Future<PaginatedDataClass<CategoryModel>> fetch({
    int? page,
    int? perPage,
    String? id,
    bool isTree = false,
  });
}

abstract class ICourseRepository {
  Future<PaginatedDataClass<CourseModel>> fetch({
    int? page,
    int? perPage,
    String? slug,
  });
}

abstract class FeaturedSection<T extends Model> {
  abstract final String type;
  abstract final String name;
  abstract final double height;
  abstract final double? width;
  abstract final List<Model> items;

  final Type dataType = T;
  Widget itemBuilder(BuildContext context, T data);

  VoidCallback? get onTapSeeAll => null;
}

class UnsupportedSection extends FeaturedSection {
  UnsupportedSection();

  @override
  double get height => 0;

  @override
  Widget itemBuilder(BuildContext context, Model data) {
    return const SizedBox();
  }

  @override
  String get name => '';

  @override
  String get type => '';

  @override
  double? get width => null;

  @override
  List<Model> get items => [];
}
