import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_no_data_widget.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/help_support/cubits/fetch_discussion_groups_cubit.dart';
import 'package:elms/features/help_support/models/discussion_group.dart';
import 'package:elms/features/help_support/widgets/discussion_group_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class DiscussionGroupsScreen extends StatefulWidget {
  final String? searchQuery;
  const DiscussionGroupsScreen({super.key, this.searchQuery});

  static Widget route() {
    final String? searchQuery = Get.arguments as String?;
    return BlocProvider(
      create: (context) =>
          FetchDiscussionGroupsCubit()..fetch(search: searchQuery),
      child: DiscussionGroupsScreen(searchQuery: searchQuery),
    );
  }

  @override
  State<DiscussionGroupsScreen> createState() => _DiscussionGroupsScreenState();
}

class _DiscussionGroupsScreenState extends State<DiscussionGroupsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.searchQuery != null && widget.searchQuery!.isNotEmpty
            ? AppLabels.searchResults.tr
            : AppLabels.joinConversation.tr,
        showBackButton: true,
      ),
      body: BlocBuilder<FetchDiscussionGroupsCubit, FetchDiscussionGroupsState>(
        builder: (context, state) {
          if (state is FetchDiscussionGroupsInProgress) {
            return ListView.separated(
              padding: const .all(16),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) => const CustomShimmer(height: 120),
            );
          }

          if (state is FetchDiscussionGroupsFail) {
            return CustomErrorWidget(error: state.error);
          }

          if (state is FetchDiscussionGroupsSuccess) {
            if (state.data.isEmpty) {
              return const CustomNoDataWidget();
            }

            return ListView.separated(
              padding: const .all(16),
              itemBuilder: (context, index) {
                final HelpDeskDiscussionGroupModel group = state.data[index];
                return DiscussionGroupCard(
                  variant: DiscussionCardVariant.horizontal,
                  discussionGroup: group,
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16);
              },
              itemCount: state.data.length,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
