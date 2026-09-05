import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/recent_search_model.dart';
import 'package:elms/utils/local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentSearchesCubit extends Cubit<BaseState> {
  static const int _maxSearches = 10;

  RecentSearchesCubit() : super(InitialState()) {
    loadRecentSearches();
  }

  Future<void> addRecentSearch(
    String searchText,
    int courseCount, {
    String? imageUrl,
  }) async {
    try {
      final RecentSearchModel newSearch = RecentSearchModel(
        searchText: searchText.trim(),
        courseCount: courseCount,
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
      );

      final List<Map<String, dynamic>> storedSearches =
          LocalStorage.getRecentSearches();
      List<RecentSearchModel> searches = storedSearches
          .map((json) => RecentSearchModel.fromJson(json))
          .toList();

      // Remove if already exists (to avoid duplicates)
      searches.removeWhere(
        (search) =>
            search.searchText.toLowerCase() ==
            newSearch.searchText.toLowerCase(),
      );

      // Add to the beginning (most recent first)
      searches.insert(0, newSearch);

      // Keep only the latest 10 searches
      if (searches.length > _maxSearches) {
        searches = searches.take(_maxSearches).toList();
      }

      // Store back to LocalStorage
      await LocalStorage.storeRecentSearches(
        searches.map((search) => search.toJson()).toList(),
      );

      emit(SuccessState<RecentSearchModel>(data: searches));
    } catch (e) {
      emit(ErrorState(error: 'Failed to add recent search: $e'));
    }
  }

  Future<void> loadRecentSearches() async {
    try {
      emit(ProgressState());
      final storedSearches = LocalStorage.getRecentSearches();
      final searches = storedSearches
          .map((json) => RecentSearchModel.fromJson(json))
          .toList();
      emit(SuccessState<RecentSearchModel>(data: searches));
    } catch (e) {
      emit(ErrorState(error: 'Failed to load recent searches: $e'));
    }
  }

  Future<void> clearRecentSearches() async {
    try {
      await LocalStorage.clearRecentSearches();
      emit(SuccessState<RecentSearchModel>(data: []));
    } catch (e) {
      emit(ErrorState(error: 'Failed to clear recent searches: $e'));
    }
  }

  Future<void> removeRecentSearch(String searchText) async {
    try {
      final storedSearches = LocalStorage.getRecentSearches();
      final List<RecentSearchModel> searches = storedSearches
          .map((json) => RecentSearchModel.fromJson(json))
          .toList();
      searches.removeWhere(
        (search) => search.searchText.toLowerCase() == searchText.toLowerCase(),
      );

      await LocalStorage.storeRecentSearches(
        searches.map((search) => search.toJson()).toList(),
      );
      emit(SuccessState<RecentSearchModel>(data: searches));
    } catch (e) {
      emit(ErrorState(error: 'Failed to remove recent search: $e'));
    }
  }
}
