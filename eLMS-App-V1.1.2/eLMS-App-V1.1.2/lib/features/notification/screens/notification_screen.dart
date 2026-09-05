import 'package:elms/common/cubits/paginated_api_states.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_no_data_widget.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/tappable_image.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/notification/cubits/fetch_notifications_cubit.dart';
import 'package:elms/features/notification/models/notification_model.dart';
import 'package:elms/features/notification/widgets/notification_tile_shimmer.dart';
import 'package:elms/features/notification/widgets/team_invitation_dialog.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/scroll_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreen extends StatefulWidget {
  static Widget route() {
    return BlocProvider(
      create: (context) => FetchNotificationsCubit(),
      child: const NotificationScreen(),
    );
  }

  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<FetchNotificationsCubit>().fetchData();
    _scrollController.addEndListener(() {
      if (context.read<FetchNotificationsCubit>().hasMore) {
        context.read<FetchNotificationsCubit>().fetchMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<FetchNotificationsCubit>().fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLabels.notification.tr,
        showBackButton: true,
      ),
      body: BlocBuilder<FetchNotificationsCubit, PaginatedApiState>(
        builder: (context, state) {
          if (state is PaginatedApiLoadingState) {
            return const ShimmerBuilder(
              padding: EdgeInsets.all(16),
              spacing: 16,
              shimmer: NotificationTileShimmer(),
            );
          }
          if (state is PaginatedApiFailureState) {
            return CustomErrorWidget(
              error: state.exception,
              onRetry: _onRefresh,
            );
          }
          if (state is PaginatedApiSuccessState<NotificationModel>) {
            if (state.data.isEmpty) {
              return const CustomNoDataWidget(titleKey: AppLabels.noDataFound);
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                    itemCount: state.data.length,
                    padding: const .all(16),
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 16);
                    },
                    itemBuilder: (context, index) {
                      final NotificationModel notification = state.data[index];

                      return _buildNotificationTile(
                        context,
                        notification: notification,
                        title: notification.title,
                        image: notification.image,
                        description: notification.message,
                        time: notification.timeAgo,
                        type: notification.notificationType,
                      );
                    },
                  ),
                ),
                if (state is PaginatedApiLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: NotificationTileShimmer(),
                  ),
              ],
            );
          }

          return Container();
        },
      ),
    );
  }

  void _onTapViewRequest(NotificationModel notification) {
    // Capture cubit before dialog opens — the screen context may not be reachable
    // from inside the dialog's own context.
    final notificationsCubit = context.read<FetchNotificationsCubit>();
    TeamInvitationDialog.show(
      context,
      notification,
      onDone: () => notificationsCubit.fetchData(),
    );
  }

  Future<void> _onTapNotification(NotificationModel notification) async {
    if (notification.notificationType == 'url') {
      final typeLink = notification.typeLink;
      if (typeLink != null && typeLink.isNotEmpty) {
        final uri = Uri.parse(typeLink);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

  Widget _buildNotificationTile(
    BuildContext context, {
    required NotificationModel notification,
    required String title,
    String? description,
    String? image,
    String? time,
    String? type,
  }) {
    final bool isTeamInvitation =
        type == 'team_invitation' && notification.invitationStatus == 'pending';

    return GestureDetector(
      onTap: isTeamInvitation ? null : () => _onTapNotification(notification),
      child: CustomCard(
        padding: const .all(10),
        child: Row(
          spacing: 10,
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          children: [
            Expanded(
              flex: 7,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onTapNotification(notification),
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: [
                    CustomText(
                      title,
                      maxLines: 1,
                      ellipsis: true,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.copyWith(fontWeight: .w500),
                    ),
                    if (description != null)
                      CustomText(
                        "$description\n\n",
                        maxLines: 3,
                        ellipsis: true,
                        style: TextStyle(
                          fontSize: context.font.small,
                          fontWeight: .w400,
                          color: context.color.textSecondary,
                        ),
                      ),
                    const Divider(height: 8),
                    if (time != null)
                      CustomText(
                        time,
                        style: TextStyle(
                          fontSize: context.font.xSmall,
                          fontWeight: .w400,
                          color: context.color.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 90,
              child: Column(
                mainAxisSize: .min,
                spacing: 4,
                children: [
                  TappableImage(
                    image ?? '',
                    height: 90,
                    width: 90,
                    fit: BoxFit.cover,
                    radius: 4,
                  ),
                  if (isTeamInvitation) ...[
                    CustomButton(
                      height: 26,
                      title: AppLabels.viewRequest.tr,
                      backgroundColor: context.color.onSurface,
                      textSize: 12,
                      radius: 4,
                      onPressed: () => _onTapViewRequest(notification),
                      padding: .zero,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
