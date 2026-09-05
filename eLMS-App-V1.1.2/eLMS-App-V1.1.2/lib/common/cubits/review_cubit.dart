import 'package:elms/common/enums.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/repositories/review_repository.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class ReviewInitial extends BaseState {}

final class ReviewInProgress extends ProgressState {}

final class ReviewSubmitSuccess extends BaseState {}

final class ReviewSubmitFail extends ErrorState<String> {
  ReviewSubmitFail({required super.error});
}

class ReviewCubit extends Cubit<BaseState> {
  final ReviewRepository _repository;
  final ReviewType type;
  final int id;

  ReviewCubit({
    required this.type,
    required this.id,
    ReviewRepository? repository,
  }) : _repository = repository ?? ReviewRepository(),
       super(ReviewInitial());

  Future<void> submitReview({
    required int rating,
    required String review,
  }) async {
    emit(ReviewInProgress());
    try {
      await _repository.addReview(
        type: type,
        id: id,
        rating: rating,
        review: review,
      );
      emit(ReviewSubmitSuccess());
    } catch (e) {
      if (e is ApiException) {
        emit(ReviewSubmitFail(error: e.message ?? ''));
      } else {
        emit(ReviewSubmitFail(error: e.toString()));
      }
    }
  }
}
