import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/features/search/models/search_suggestion_model.dart';
import 'package:elms/features/search/repository/search_suggestion_repository.dart';

class SearchSuggestionCubit extends Cubit<SearchSuggestionState> {
  final SearchSuggestionRepository _repository;

  SearchSuggestionCubit(this._repository) : super(SearchSuggestionInitial());

  Future<void> fetchSuggestions(String query) async {
    emit(SearchSuggestionLoading());

    try {
      final response = await _repository.fetchSuggestions(query: query.trim());
      emit(SearchSuggestionSuccess(data: response));
    } catch (e) {
      emit(
        SearchSuggestionError(
          error: e is CustomException ? e : AppException(message: e.toString()),
        ),
      );
    }
  }

  void clearSuggestions() {
    emit(SearchSuggestionInitial());
  }
}

sealed class SearchSuggestionState extends BaseState {}

final class SearchSuggestionInitial extends SearchSuggestionState {}

final class SearchSuggestionLoading extends SearchSuggestionState {}

final class SearchSuggestionSuccess extends SearchSuggestionState {
  final SearchSuggestionDataModel data;

  SearchSuggestionSuccess({required this.data});
}

base class SearchSuggestionError extends SearchSuggestionState {
  final CustomException error;

  SearchSuggestionError({required this.error});
}
