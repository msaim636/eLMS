import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/wishlist/repository/wishlist_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class WishlistActionState implements BaseState {}

class WishlistActionInitial extends WishlistActionState {}

class WishlistActionInProgress extends ProgressState
    implements WishlistActionState {
  final int courseId;

  WishlistActionInProgress({required this.courseId});
}

class WishlistActionSuccess extends WishlistActionState {
  final int courseId;
  final bool isWishlisted;
  final String message;

  WishlistActionSuccess({
    required this.courseId,
    required this.isWishlisted,
    required this.message,
  });
}

final class WishlistActionError extends ErrorState<String>
    implements WishlistActionState {
  final int courseId;
  final bool previousState;

  WishlistActionError({
    required super.error,
    required this.courseId,
    required this.previousState,
  });
}

class WishlistActionCubit extends Cubit<WishlistActionState> {
  final WishlistRepository _repository;
  final Map<int, bool> _toggledStates = {};

  WishlistActionCubit(this._repository) : super(WishlistActionInitial());

  bool? getToggledState(int courseId) => _toggledStates[courseId];

  Future<void> toggleWishlist({
    required int courseId,
    required bool currentWishlistState,
  }) async {
    try {
      emit(WishlistActionInProgress(courseId: courseId));
      final int status = currentWishlistState ? 0 : 1;

      final Map<String, dynamic> response = await _repository.toggleWishlist(
        courseId: courseId,
        status: status,
      );

      final bool newState = !currentWishlistState;
      _toggledStates[courseId] = newState;

      emit(
        WishlistActionSuccess(
          courseId: courseId,
          isWishlisted: newState,
          message: response['message'] ?? 'Wishlist updated successfully',
        ),
      );
    } catch (e) {
      emit(
        WishlistActionError(
          error: e.toString(),
          courseId: courseId,
          previousState: currentWishlistState,
        ),
      );
    }
  }
}
