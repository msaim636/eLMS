import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/features/help_support/models/discussion_question_model.dart';
import 'package:elms/features/help_support/repositories/help_desk_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchQuestionsState {}

class FetchQuestionsInitial extends FetchQuestionsState {}

class FetchQuestionsProgress extends FetchQuestionsState {}

class FetchQuestionsSuccess
    extends PaginatedApiSuccessState<DiscussionQuestionModel>
    implements FetchQuestionsState {
  FetchQuestionsSuccess({
    required super.total,
    required super.data,
    required super.isLoadingMore,
    required super.hasLoadingMoreError,
    required super.currentPage,
    required super.totalPage,
  });

  @override
  FetchQuestionsSuccess copyWith({
    int? total,
    List<DiscussionQuestionModel>? data,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasLoadingMoreError,
    int? currentPage,
    int? totalPage,
  }) {
    return FetchQuestionsSuccess(
      total: total ?? this.total,
      data: data ?? this.data,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadingMoreError: hasLoadingMoreError ?? this.hasLoadingMoreError,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
    );
  }
}

base class FetchQuestionsError extends ErrorState
    implements FetchQuestionsState {
  FetchQuestionsError({required super.error});
}

class FetchQuestionsCubit extends Cubit<FetchQuestionsState>
    with PaginationCapability<FetchQuestionsState, DiscussionQuestionModel> {
  final HelpDeskRepository _repository;
  int? _groupId;

  FetchQuestionsCubit(this._repository) : super(FetchQuestionsInitial());

  @override
  Future<void> fetch({int? groupId}) async {
    try {
      // Call super to handle pagination logic
      await super.fetch();

      // Store groupId for pagination
      if (groupId != null) {
        _groupId = groupId;
      }

      if (_groupId == null) {
        emit(FetchQuestionsError(error: 'Group ID is required'));
        return;
      }

      // Emit progress state only for initial fetch
      if (currentPage == 1) {
        emit(FetchQuestionsProgress());
      }

      final PaginatedDataClass<DiscussionQuestionModel> result =
          await _repository.fetchQuestions(
            groupId: _groupId!,
            page: currentPage,
          );

      // Update data using pagination capability
      data = result.data;

      emit(
        FetchQuestionsSuccess(
          total: result.total,
          data: data,
          isLoadingMore: false,
          hasLoadingMoreError: false,
          currentPage: result.currentPage,
          totalPage: result.totalPage,
        ),
      );
    } catch (e) {
      if (state is FetchQuestionsSuccess && currentPage > 1) {
        // If error during pagination, update the success state
        final successState = state as FetchQuestionsSuccess;
        emit(
          successState.copyWith(
            isLoadingMore: false,
            hasLoadingMoreError: true,
          ),
        );
      } else {
        emit(FetchQuestionsError(error: e));
      }
    }
  }
}
