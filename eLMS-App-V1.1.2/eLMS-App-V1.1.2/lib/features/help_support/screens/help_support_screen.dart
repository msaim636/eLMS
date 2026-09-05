import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/help_support/cubits/fetch_discussion_groups_cubit.dart';
import 'package:elms/features/help_support/cubits/fetch_faqs_cubit.dart';
import 'package:elms/features/help_support/models/discussion_group.dart';
import 'package:elms/features/help_support/repositories/help_desk_repository.dart';
import 'package:elms/features/help_support/widgets/discussion_group_card.dart';
import 'package:elms/features/help_support/widgets/faq_item.dart';
import 'package:elms/features/help_support/widgets/support_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  static Widget route() => MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => FetchDiscussionGroupsCubit()),
      BlocProvider(create: (context) => FetchFaqsCubit(HelpDeskRepository())),
    ],
    child: const HelpSupportScreen(),
  );

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with Pagination<HelpSupportScreen, FetchFaqsCubit> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FetchDiscussionGroupsCubit>().fetch();
    context.read<FetchFaqsCubit>().fetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      Get.toNamed(AppRoutes.discussionGroupListScreen, arguments: value.trim());
    }
  }

  Widget _buildSearchBar() {
    return CustomTextFormField(
      controller: _searchController,
      hintText: AppLabels.searchForQuery.tr,
      prefixIcon: AppIcons.search,
      inputType: TextInputType.text,
      radius: 8,
      onFieldSubmitted: _onSearchSubmitted,
      requiredErrorMessage: AppLabels.fieldRequired.tr,
    );
  }

  Widget _buildSupportCardRow() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      children: [
        SupportInfoCard(
          title: AppLabels.startConversation.tr,
          description: AppLabels.startConversationDesc.tr,
          iconPath: AppIcons.startConversation,
          onTap: () {},
        ),
        SupportInfoCard(
          title: AppLabels.shareKnowledge.tr,
          description: AppLabels.shareKnowledgeDesc.tr,
          iconPath: AppIcons.shareKnowledge,
          onTap: () {},
        ),
        SupportInfoCard(
          title: AppLabels.collaborateTogether.tr,
          description: AppLabels.collaborateTogetherDesc.tr,
          iconPath: AppIcons.collaborateTogether,
          onTap: () {},
        ),
        SupportInfoCard(
          title: AppLabels.findQuickFaqs.tr,
          description: AppLabels.findQuickFaqsDesc.tr,
          iconPath: AppIcons.findQuickFaq,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildConversationSection() {
    return BlocBuilder<FetchDiscussionGroupsCubit, FetchDiscussionGroupsState>(
      builder: (context, state) {
        if (state case final FetchDiscussionGroupsSuccess success
            when success.data.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                CustomText(
                  AppLabels.joinConversation.tr,
                  style: const TextStyle(fontWeight: .w500, fontSize: 18),
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.discussionGroupListScreen);
                  },
                  child: CustomText(
                    AppLabels.seeAll.tr,
                    style: const TextStyle(fontWeight: .w400, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state is FetchDiscussionGroupsFail)
              CustomErrorWidget(error: state.error),

            if (state is FetchDiscussionGroupsInProgress)
              SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: .horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (BuildContext context, int index) {
                    return const DiscussionGroupCardShimmer();
                  },
                ),
              )
            else if (state is FetchDiscussionGroupsSuccess)
              SizedBox(
                height: 218,
                child: ListView.separated(
                  scrollDirection: .horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.data.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (BuildContext context, int index) {
                    final HelpDeskDiscussionGroupModel group =
                        state.data[index];
                    return DiscussionGroupCard(discussionGroup: group);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFaqSection() {
    return BlocBuilder<FetchFaqsCubit, FetchFaqsState>(
      builder: (context, state) {
        if (state case final FetchFaqsSuccess success
            when success.data.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: .start,
          children: [
            CustomText(
              AppLabels.haveQuestionsAnswers.tr,
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontWeight: .w500, fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (state is FetchFaqsError) CustomErrorWidget(error: state.error),
            if (state is FetchFaqsProgress)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) => const FaqItemShimmer(),
              )
            else if (state is FetchFaqsSuccess)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.data.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == state.data.length && state.isLoadingMore) {
                    return const Center(
                      child: Padding(
                        padding: .all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final faq = state.data[index];
                  return FaqItem(
                    question: faq.question,
                    answer: faq.answer,
                    initialExpanded: index == 0,
                  );
                },
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLabels.helpAndSupport.tr,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        padding: const .only(bottom: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            CustomCard(
              padding: const .all(16),
              borderRadius: 0,
              borderColor: Colors.transparent,
              child: Column(
                crossAxisAlignment: .start,
                spacing: 16,
                children: [_buildSearchBar(), _buildSupportCardRow()],
              ),
            ),
            Padding(
              padding: const .all(16),
              child: Column(
                crossAxisAlignment: .start,
                spacing: 16,
                children: [
                  _buildConversationSection(),
                  _buildFaqSection(),
                  // _buildTopicSuggestions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildTopicSuggestions() {
  //   // Get popular discussion groups
  //   final List<HelpDeskDiscussionGroupModel> allGroups = contex
  //       .getDiscussionGroups();
  //   final List<HelpDeskDiscussionGroupModel> popularGroups = allGroups
  //       .where((group) => group.isActiveGroup)
  //       .toList();

  //   return Column(
  //     crossAxisAlignment: .start,
  //     children: [
  //       CustomText(
  //         AppLabels.popularTopics.tr,
  //         style: TextStyle(//           fontWeight: .w500,
  //           fontSize: 18,
  //),
  //       ),
  //       const SizedBox(height: 16),
  //       ListView.separated(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         itemCount: popularGroups.length,
  //         separatorBuilder: (context, index) => const SizedBox(height: 12),
  //         itemBuilder: (context, index) {
  //           final group = popularGroups[index];
  //           return DiscussionGroupCard(
  //             variant: DiscussionCardVariant.horizontal,
  //             discussionGroup: group,
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }
}
