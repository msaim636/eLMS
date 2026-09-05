import 'package:elms/common/models/message_model.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/course/cubits/fetch_discussion_cubit.dart';
import 'package:elms/features/course/features/discussion/widgets/discussion_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:elms/utils/utils.dart';

class DiscussionSection extends StatefulWidget {
  const DiscussionSection({super.key});

  @override
  State<DiscussionSection> createState() => _DiscussionSectionState();
}

class _DiscussionSectionState extends State<DiscussionSection> {
  final TextEditingController _messageController = TextEditingController();

  // Approximate collapsed height of the overlaid message input bar.
  static const double _messageBarClearance = 80;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<FetchDiscussionCubit, FetchDiscussionState>(
        builder: (context, state) {
          if (state is FetchDiscussionInProgress) {
            return CustomScrollView(
              slivers: [
                SliverList.separated(
                  itemCount: 5,
                  itemBuilder: (context, index) =>
                      const CustomShimmer(height: 150),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                ),
              ],
            );
          }

          if (state is FetchDiscussionFail) {
            return CustomErrorWidget(
              error: UiUtils.friendlyErrorMessage(state.error),
              onRetry: () => context.read<FetchDiscussionCubit>().fetch(),
            );
          }

          if (state is FetchDiscussionSuccess) {
            final List<DiscussionModel> discussions = state.data;

            if (discussions.isEmpty) {
              return Center(
                child: CustomText(
                  AppLabels.noDiscussionsYet.tr,
                  style: TextStyle(fontSize: context.font.medium),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    CustomText(
                      Utils.pluralize(
                        discussions.length,
                        singular: AppLabels.discussion,
                        plural: AppLabels.discussions,
                      ),
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.copyWith(fontWeight: .w600),
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
                SliverList.separated(
                  itemBuilder: (context, index) {
                    return DiscussionCard(discussion: discussions[index]);
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 16);
                  },
                  itemCount: discussions.length,
                ),
                // Bottom clearance so the last message isn't hidden behind the
                // overlaid message input bar.
                SliverToBoxAdapter(
                  child: SizedBox(
                    height:
                        _messageBarClearance +
                        MediaQuery.paddingOf(context).bottom,
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
