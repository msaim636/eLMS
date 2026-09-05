import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/features/home/models/slider_model.dart';
import 'package:elms/features/home/repositories/slider_repository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchSliderState {}

class FetchSliderInitial extends FetchSliderState {}

class FetchSliderInProgress extends FetchSliderState implements ProgressState {}

class FetchSliderSuccess extends PaginatedApiSuccessState<SliderModel>
    implements FetchSliderState {
  FetchSliderSuccess({
    required super.total,
    required super.data,
    required super.isLoadingMore,
    required super.hasLoadingMoreError,
    required super.currentPage,
    required super.totalPage,
  });

  @override
  PaginatedApiSuccessState<SliderModel> copyWith({
    int? total,
    List<SliderModel>? data,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasLoadingMoreError,
    int? currentPage,
    int? totalPage,
  }) {
    return FetchSliderSuccess(
      total: total ?? this.total,
      data: data ?? this.data,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadingMoreError: hasLoadingMoreError ?? this.hasLoadingMoreError,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
    );
  }
}

final class FetchSliderFail extends ErrorState implements FetchSliderState {
  FetchSliderFail({required super.error});
}

class FetchSliderCubit extends Cubit<FetchSliderState> {
  final SliderRepository sliderRepository;
  FetchSliderCubit(this.sliderRepository) : super(FetchSliderInitial());

  Future<void> fetch() async {
    try {
      emit(FetchSliderInProgress());
      final DataClass<SliderModel> result = await sliderRepository
          .fetchSliders();
      emit(
        FetchSliderSuccess(
          total: result.data.length,
          data: result.data,
          isLoadingMore: false,
          hasLoadingMoreError: false,
          currentPage: 1,
          totalPage: 1,
        ),
      );
    } catch (e) {
      emit(FetchSliderFail(error: e));
    }
  }
}
