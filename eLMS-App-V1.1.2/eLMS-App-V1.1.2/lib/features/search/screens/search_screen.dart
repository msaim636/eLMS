import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/features/search/widgets/search_suggestion_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/scroll_extension.dart';
import 'package:elms/utils/utils.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/features/search/widgets/recent_search_item.dart';
import 'package:elms/features/search/widgets/search_suggestion_item.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elms/features/search/cubits/search_suggestions_cubit.dart';
import 'package:elms/features/search/repository/search_suggestion_repository.dart';
import 'package:elms/features/search/models/search_suggestion_model.dart'
    as search_model;
import 'package:elms/features/search/cubits/recent_searches_cubit.dart';
import 'package:elms/common/models/recent_search_model.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/course_list_dataclass.dart';
import 'package:elms/core/routes/routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static Widget route() => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) =>
            SearchSuggestionCubit(SearchSuggestionRepository()),
      ),
      BlocProvider(create: (context) => RecentSearchesCubit()),
    ],
    child: const SearchScreen(),
  );

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SearchSuggestionCubit>().fetchSuggestions('');
    _searchController.addDebouncedListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeDebouncedListener();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    context.read<SearchSuggestionCubit>().fetchSuggestions(query);
  }

  void _onTapRemoveItem(String searchText) {
    context.read<RecentSearchesCubit>().removeRecentSearch(searchText);
  }

  void _onTapSuggestion(search_model.SearchSuggestionItemModel suggestion) {
    // Add to recent searches with default course count (0 for suggestions)
    context.read<RecentSearchesCubit>().addRecentSearch(
      suggestion.text ?? '',
      0,
      imageUrl: suggestion.courseImage,
    );
    // Navigate immediately - the cubit will handle the state internally
    Get.toNamed(
      AppRoutes.courseListScreen,
      arguments: CourseListForSearch(searchQuery: suggestion.text ?? ''),
    );
  }

  void _onTapRecentSearch(String searchText) {
    // Navigate to course list screen without adding to recent searches again
    Get.toNamed(
      AppRoutes.courseListScreen,
      arguments: CourseListForSearch(searchQuery: searchText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLabels.search.tr, showBackButton: true),
      body: SingleChildScrollView(
        padding: const .all(16.0),
        child: Column(
          children: [
            _buildSearchBar(context),
            _buildSearchSuggestions(),
            _buildRecentSearches(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return CustomTextFormField(
      controller: _searchController,
      hintText: AppLabels.whatDoYouWantToLearn.tr,
      radius: 8,
      prefixIcon: AppIcons.search,
      requiredErrorMessage: AppLabels.fieldRequired.tr,
    );
  }

  Widget _buildRecentSearches() {
    return BlocBuilder<RecentSearchesCubit, BaseState>(
      builder: (context, state) {
        return switch (state) {
          ProgressState() => const Center(child: CircularProgressIndicator()),
          SuccessState<RecentSearchModel>() => _buildRecentSearchesList(
            state.data,
          ),
          ErrorState() => CustomErrorWidget(error: state.error),
          _ => const SizedBox(),
        };
      },
    );
  }

  Widget _buildRecentSearchesList(List<RecentSearchModel> recentSearches) {
    if (recentSearches.isEmpty) {
      return Center(
        child: CustomText(
          AppLabels.noRecentSearches.tr,
          style: TextStyle(fontSize: context.font.small),
          color: context.color.textSecondary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 16),
          child: CustomText(
            AppLabels.recent.tr,
            style: const TextStyle(fontSize: 18),
            fontWeight: .w500,
            color: context.color.onSurface,
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentSearches.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final RecentSearchModel search = recentSearches[index];

            final subtitle = search.courseCount > 0
                ? Utils.pluralize(
                    search.courseCount,
                    singular: AppLabels.course,
                    plural: AppLabels.courses,
                  )
                : AppLabels.recentSearch.tr;

            return RecentSearchItem(
              title: search.searchText,
              imageUrl: search.imageUrl,
              subtitle: subtitle,
              onTap: () => _onTapRecentSearch(search.searchText),
              onRemove: () => _onTapRemoveItem(search.searchText),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchSuggestions() {
    return BlocBuilder<SearchSuggestionCubit, SearchSuggestionState>(
      builder: (context, state) {
        return switch (state) {
          SearchSuggestionInitial() => const SizedBox(),
          SearchSuggestionLoading() => const SearchSuggestionShimmer(),
          SearchSuggestionSuccess() => _buildSuggestionsList(state.data),
          SearchSuggestionError() => CustomErrorWidget(error: state.error),
        };
      },
    );
  }

  Widget _buildSuggestionsList(search_model.SearchSuggestionDataModel data) {
    final suggestions = data.allSuggestions;

    if (suggestions.isEmpty) {
      return SearchSuggestionItem(
        suggestion: data.query,

        onTap: () => _onTapSuggestion(
          search_model.SearchSuggestionItemModel(
            authorName: '',
            text: data.query,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const .symmetric(vertical: 7),
      separatorBuilder: (context, index) =>
          const SizedBox(height: 12, child: Divider()),
      itemCount: suggestions.length + (data.query.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0 && data.query.isNotEmpty) {
          return SearchSuggestionItem(
            suggestion: data.query,
            onTap: () => _onTapSuggestion(
              search_model.SearchSuggestionItemModel(
                authorName: '',
                text: data.query,
              ),
            ),
          );
        }

        final search = suggestions[index > 0 ? index - 1 : index];
        return SearchSuggestionItem(
          suggestion: search.text ?? '',

          onTap: () => _onTapSuggestion(search),
        );
      },
    );
  }
}
