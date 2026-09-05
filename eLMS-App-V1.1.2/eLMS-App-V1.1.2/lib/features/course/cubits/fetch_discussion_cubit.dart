import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/common/models/message_model.dart';
import 'package:elms/features/course/repositories/discussion_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchDiscussionState implements BaseState {}

class FetchDiscussionInitial extends FetchDiscussionState {}

base class FetchDiscussionInProgress extends ProgressState
    implements FetchDiscussionState {}

final class FetchDiscussionSuccess
    extends PaginatedApiSuccessState<DiscussionModel>
    implements FetchDiscussionState {
  FetchDiscussionSuccess({
    required super.total,
    required super.data,
    required super.isLoadingMore,
    required super.hasLoadingMoreError,
    required super.currentPage,
    required super.totalPage,
  });

  @override
  PaginatedApiSuccessState<DiscussionModel> copyWith({
    List<DiscussionModel>? data,
    int? total,
    bool? hasMore,
    bool? hasLoadingMoreError,
    bool? isLoadingMore,
    int? currentPage,
    int? totalPage,
  }) {
    return FetchDiscussionSuccess(
      total: total ?? this.total,
      data: data ?? this.data,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadingMoreError: hasLoadingMoreError ?? this.hasLoadingMoreError,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
    );
  }
}

final class FetchDiscussionFail<T> extends ErrorState<T>
    implements FetchDiscussionState {
  FetchDiscussionFail({required super.error});
}

class FetchDiscussionCubit extends Cubit<FetchDiscussionState>
    with PaginationCapability<FetchDiscussionState, DiscussionModel> {
  final DiscussionRepository _repository;
  final int courseId;

  FetchDiscussionCubit(this._repository, {required this.courseId})
    : super(FetchDiscussionInitial()) {
    fetch();
  }

  @override
  Future<void> fetch() async {
    await super.fetch();
    try {
      if (isForceFetch()) emit(FetchDiscussionInProgress());
      final PaginatedDataClass<DiscussionModel> result = await _repository
          .fetch(courseId: courseId, page: currentPage);

      data = result.data;

      emit(
        FetchDiscussionSuccess(
          total: result.total,
          data: data,
          currentPage: result.currentPage,
          totalPage: result.totalPage,
          isLoadingMore: false,
          hasLoadingMoreError: false,
        ),
      );
    } catch (e) {
      emit(FetchDiscussionFail(error: e));
    }
  }

  void insert(DiscussionModel discussion) {
    if (state case final FetchDiscussionSuccess discussionSuccess) {
      emit(
        discussionSuccess.copyWith(
              data: [...discussionSuccess.data]..insert(0, discussion),
            )
            as FetchDiscussionSuccess,
      );
    }
  }

  void insertReply(Message reply, String parentDiscussionId) {
    if (state case final FetchDiscussionSuccess discussionSuccess) {
      final updatedData = discussionSuccess.data.map((discussion) {
        if (discussion.id == parentDiscussionId) {
          return DiscussionModel(
            id: discussion.id,
            content: discussion.content,
            senderId: discussion.senderId,
            receiverId: discussion.receiverId,
            timestamp: discussion.timestamp,
            type: discussion.type,
            profile: discussion.profile,
            userName: discussion.userName,
            userSubtitle: discussion.userSubtitle,
            timesAgo: discussion.timesAgo,
            replies: [...discussion.replies, reply],
          );
        }
        return discussion;
      }).toList();

      emit(
        discussionSuccess.copyWith(data: [...updatedData])
            as FetchDiscussionSuccess,
      );
    }
  }
}
