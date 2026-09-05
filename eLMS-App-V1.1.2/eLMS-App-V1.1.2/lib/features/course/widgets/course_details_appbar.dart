import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/widgets/custom_icon_button.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/wishlist_button.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/deep_linking/deep_link_manager.dart';
import 'package:elms/core/services/refresh_notifier.dart';
import 'package:elms/features/course/services/course_content_notifier.dart';
import 'package:elms/features/main/main_screen.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elms/utils/share_helper.dart';

class CourseDetailsAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final CourseModel course;
  final bool? isWishlisted;
  const CourseDetailsAppBar({
    super.key,
    required this.course,
    this.isWishlisted,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  @override
  State<CourseDetailsAppBar> createState() => _CourseDetailsAppBarState();
}

class _CourseDetailsAppBarState extends State<CourseDetailsAppBar> {
  void _onBackPressed() {
    if (CourseContentNotifier.instance.isVisible) {
      CourseContentNotifier.instance.hide();
      return;
    }
    if (courseContentNavigator.value != null) {
      courseContentNavigator.value = null;
      return;
    }

    RefreshNotifier.instance.markMyLearningForRefresh();
    Get.back();
  }

  Future<void> _onTapShareButton(BuildContext iconContext) async {
    await ShareHelper.shareUri(
      iconContext,
      Uri.parse(
        DeepLinkManager.instance.createDeepLink(slug: widget.course.slug!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _onBackPressed,
        icon: CustomImage(
          AppIcons.arrowLeft,
          height: 24,
          width: 24,
          color: context.color.onSurface,
        ),
      ),
      actions: [
        Builder(
          builder: (iconContext) {
            return CustomIconButton(
              image: AppIcons.share,
              onTap: () => _onTapShareButton(iconContext),
              size: const Size.square(38),
              padding: const EdgeInsets.all(8),
              color: context.color.onSurface,
            );
          },
        ),
        const SizedBox(width: 16),
        WishlistButton(
          courseId: widget.course.id,
          isWishlisted: widget.isWishlisted ?? widget.course.isWishlisted,
          size: 40,
          isCircular: false,
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
