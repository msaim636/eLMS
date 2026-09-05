import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/rating_bar_widget.dart';
import 'package:elms/common/widgets/wishlist_button.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/features/settings/cubit/app_settings_cubit.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CourseCard extends StatelessWidget {
  final Widget Function(BuildContext context, CourseCardStyle style) builder;
  final CourseCardStyle style;
  final CourseModel course;

  const CourseCard._({
    required this.builder,
    required this.style,
    required this.course,
  });

  ///Styles of card
  factory CourseCard.vertical({
    required CourseModel course,
    VoidCallback? onTap,
  }) {
    return CourseCard._(
      style: CourseCardStyle.vertical,
      course: course,
      builder: (BuildContext context, CourseCardStyle style) {
        return GestureDetector(
          onTap: onTap,
          child: CustomCard(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                _buildImage(
                  course,
                  height: 152,
                  fitWidth: true,
                  positioned: Positioned(
                    top: 10,
                    right: 10,
                    child: _buildBookmarkButton(course),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const .all(8),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Flexible(
                              child: _buildChip(
                                context,
                                course.categoryName ?? '',
                                radius: 20,
                                fontSize: context.font.small,
                              ),
                            ),
                            if (course.ratings != 0) _buildRatings(course),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildTitle(
                          context,
                          course,
                          style: TextStyle(
                            fontSize: context.font.medium,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        _buildInstructor(
                          context,
                          course,
                          fontSize: context.font.small,
                          maxLines: 1,
                        ),

                        const SizedBox(height: 8),
                        _buildDivider(context),
                        const SizedBox(height: 8),
                        _buildPriceVertical(
                          context,
                          course,
                          fontSize: context.font.medium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  factory CourseCard.horizontal({
    required CourseModel course,
    double? width,
    double? height,
    double? radius,
    VoidCallback? onTap,
  }) {
    return CourseCard._(
      style: CourseCardStyle.horizontal,
      course: course,
      builder: (BuildContext context, CourseCardStyle style) {
        return GestureDetector(
          onTap: onTap,
          child: CustomCard(
            width: width,
            height: height,
            borderRadius: radius ?? 10,
            padding: const .all(12),
            child: Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisAlignment: .spaceEvenly,
                    mainAxisSize: .min,
                    children: [
                      _buildChip(
                        context,
                        course.categoryName ?? '',
                        radius: 20,
                        fontSize: context.font.xSmall,
                      ),
                      const SizedBox(height: 8),
                      _buildTitle(
                        context,
                        course,
                        style: TextStyle(
                          fontSize: context.font.small,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: .start,
                          mainAxisAlignment: .end,
                          children: [
                            _buildInstructor(
                              context,
                              course,
                              fontSize: context.font.xSmall,
                              maxLines: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: _buildDivider(context, hasHeight: true),
                            ),
                            Flexible(
                              child: _buildPriceHorizontal(
                                context,
                                course,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      _buildImage(
                        course,
                        fitHeight: true,
                        radius: 8,
                        positioned: course.ratings != 0
                            ? Positioned(
                                bottom: 4,
                                right: 4,
                                child: CustomCard(
                                  borderRadius: 4,
                                  padding:
                                      const EdgeInsetsDirectional.symmetric(
                                        vertical: 2,
                                        horizontal: 8,
                                      ),
                                  child: _buildRatings(course),
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: _buildBookmarkButton(course),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  factory CourseCard.learning({
    required CourseModel course,
    VoidCallback? onTap,
    bool otherOptions = false,
  }) {
    return CourseCard._(
      style: .learning,
      course: course,
      builder: (BuildContext context, CourseCardStyle style) {
        return GestureDetector(
          onTap: onTap,
          behavior: .opaque,
          child: CustomCard(
            width: context.screenWidth,
            padding: const .all(8),
            borderRadius: 10,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        _buildChip(
                          context,
                          course.categoryName ?? '',
                          fontSize: 11,
                          radius: 20,
                        ),
                        const SizedBox(height: 6),
                        _buildCourseName(context, course),
                        const SizedBox(height: 2),
                        CustomText(
                          course.currentChapter.toString(),
                          maxLines: 1,
                          ellipsis: true,
                          style: TextStyle(
                            fontSize: context.font.medium,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        _buildCourseProgress(course),
                      ],
                    ),
                  ),
                ),
                _buildImage(
                  course,
                  width: 108,
                  height: double.maxFinite,
                  radius: 6,
                  positioned: otherOptions
                      ? Positioned(
                          top: 6,
                          right: 6,
                          child: _buildOtherOptionsMenu(context, course),
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  factory CourseCard.withCourseDetails({
    required CourseModel course,
    double? width,
    double? height,
    double? radius,
    VoidCallback? onTap,
  }) {
    Widget buildDetail(
      BuildContext context, {
      required String title,
      required String icon,
      MainAxisAlignment alignment = .center,
    }) {
      return Row(
        spacing: 6,
        mainAxisAlignment: alignment,
        children: [
          CustomImage(
            icon,
            height: 16,
            width: 16,
            color: context.color.primary,
            radius: 4,
          ),
          CustomText(title, style: TextStyle(fontSize: context.font.small)),
        ],
      );
    }

    Widget buildVerticalDivider() {
      return const VerticalDivider(indent: 6, endIndent: 6, width: 1);
    }

    return CourseCard._(
      style: CourseCardStyle.withCourseDetails,
      course: course,
      builder: (BuildContext context, CourseCardStyle style) {
        return CustomCard(
          padding: const .all(8),
          child: Column(
            mainAxisSize: .min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const .symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Rating.number(
                            rating: course.averageRating,
                            ratingCount: course.ratings,
                          ),
                          _buildTitle(
                            context,
                            course,
                            style: TextStyle(
                              fontSize: context.font.medium,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                          ),
                          _buildInstructor(context, course, fontSize: 14),
                          _buildPriceVertical(
                            context,
                            course,
                            showDiscountPercentage: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // CustomImage(course.imageUrl),
                  // if (false)
                  Expanded(
                    flex: 3,
                    child: _buildImage(
                      course,
                      radius: 6,
                      height: 100,
                      width: 150,
                      positioned: Positioned.directional(
                        end: 6,
                        top: 6,
                        textDirection: Directionality.of(context),
                        child: _buildBookmarkButton(course),
                      ),
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: .symmetric(vertical: 8),
                child: Divider(height: 1),
              ),

              ///Details here
              Container(
                height: 25,
                padding: const .symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: buildDetail(
                        context,
                        title: AppLabels.time.tr,
                        icon: AppIcons.clock,
                        alignment: .start,
                      ),
                    ),
                    buildVerticalDivider(),
                    Expanded(
                      child: buildDetail(
                        context,
                        title: AppLabels.chapter.tr,
                        icon: AppIcons.chapter,
                      ),
                    ),
                    buildVerticalDivider(),
                    Expanded(
                      child: buildDetail(
                        context,
                        title: AppLabels.students.tr,
                        icon: AppIcons.hat,
                        alignment: .end,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return builder(context, style);
  }

  static Widget _buildTitle(
    BuildContext context,
    CourseModel course, {
    required TextStyle style,
    int? maxLines,
  }) {
    return CustomText(
      "${course.title}\n",
      style: style,
      maxLines: maxLines ?? 2,
      ellipsis: true,
    );
  }

  static Widget _buildInstructor(
    BuildContext context,
    CourseModel course, {
    double? fontSize,
    int? maxLines,
  }) {
    final isMulti = context.read<AppSettingsCubit>().isMultiInstructorMode;
    return CustomText(
      isMulti ? course.authorName : course.shortDescription,
      maxLines: maxLines ?? 1,
      ellipsis: true,
      style: TextStyle(
        fontSize: fontSize,
        color: context.color.textSecondary,
        fontWeight: .w400,
      ),
    );
  }

  static Widget _buildCourseName(BuildContext context, CourseModel course) {
    return CustomText(
      course.title,
      maxLines: 1,
      ellipsis: true,
      style: TextStyle(
        fontSize: context.font.xSmall,
        fontWeight: FontWeight.w400,
        color: context.color.textSecondary,
      ),
    );
  }

  static Widget _buildChip(
    BuildContext context,
    String text, {
    double? fontSize,
    double? radius,
  }) {
    return Container(
      padding: const .symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.color.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(radius ?? 4),
      ),
      child: CustomText(
        text,
        maxLines: 1,
        ellipsis: true,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
          color: context.color.primary,
        ),
      ),
    );
  }

  static Widget _buildOtherOptionsMenu(
    BuildContext context,
    CourseModel course,
  ) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'review') {
          Get.toNamed(AppRoutes.reviewsScreen, arguments: course.id);
        } else if (value == 'assignments') {
          Get.toNamed(AppRoutes.assignmentScreen, arguments: course.id);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'review', child: Text(AppLabels.review.tr)),
        PopupMenuItem(
          value: 'assignments',
          child: Text(AppLabels.assignments.tr),
        ),
      ],
      surfaceTintColor: context.color.primary,
      child: CustomCard(
        width: 24,
        height: 24,
        borderColor: context.color.textSecondary,
        borderRadius: 100,
        child: CustomImage(
          AppIcons.hamburgerMenu,
          fit: .none,
          color: context.color.onSurface,
        ),
      ),
    );
  }

  static Widget _buildCourseProgress(CourseModel course) {
    final num progressPercentage = course.progressPercentage!;
    final bool isCompleted = course.progressStatus == 'completed';
    final context = Get.context!;

    return Column(
      spacing: 5,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            CustomText(
              isCompleted ? AppLabels.completed.tr : '$progressPercentage%',
              style: TextStyle(fontSize: context.font.xSmall),
            ),
            if (isCompleted)
              CustomImage(AppIcons.correct)
            else
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${course.completedChapters}',
                      style: TextStyle(
                        fontSize: context.font.xSmall,
                        color: context.color.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '/${course.totalChapters} ${AppLabels.chapters.tr}',
                      style: TextStyle(
                        fontSize: context.font.xSmall,
                        color: context.color.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        LinearProgressIndicator(
          value: course.progressPercentage! / 100,
          color: Colors.green,
          minHeight: 9,
          borderRadius: BorderRadius.circular(8),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ],
    );
  }

  static Widget _buildImage(
    CourseModel course, {
    Positioned? positioned,
    bool fitWidth = false,
    bool fitHeight = false,
    double? width,
    double? height,
    double? radius,
  }) {
    return Stack(
      clipBehavior: .antiAlias,
      children: [
        CustomImage(
          course.image,
          radius: radius,
          width: fitWidth ? double.infinity : width,
          height: fitHeight ? double.infinity : height,
          fit: .cover,
        ),
        positioned ?? const SizedBox.shrink(),
      ],
    );
  }

  static Widget _buildBookmarkButton(CourseModel course) {
    return WishlistButton(
      courseId: course.id,

      isWishlisted: course.isWishlisted,
    );
  }

  static Widget _buildRatings(CourseModel course) {
    return Rating.number(
      rating: course.averageRating.toDouble(),
      ratingCount: course.ratings,
      divider: (count) {
        return '| $count';
      },
    );
  }

  static Widget _buildDivider(BuildContext context, {bool hasHeight = false}) =>
      Divider(
        height: hasHeight ? 1 : 0,
        thickness: 1,
        color: context.color.outline,
      );

  static Widget _buildPriceVertical(
    BuildContext context,
    CourseModel course, {
    double? fontSize,
    bool showDiscountPercentage = true,
  }) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Column(
          crossAxisAlignment: .start,
          children: [
            if (course.isEnrolled) ...[
              CustomText(
                AppLabels.enrolled.tr,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: fontSize,
                  fontWeight: .w600,
                ),
              ),
            ] else if (course.isFree) ...[
              CustomText(
                AppLabels.free.tr,
                style: TextStyle(
                  color: context.color.primary,
                  fontSize: fontSize,
                  fontWeight: .w600,
                ),
              ),
            ] else ...[
              CustomText(
                course.finalPrice.toString().currency,
                maxLines: 1,
                ellipsis: true,
                style: TextStyle(fontSize: fontSize, fontWeight: .w600),
              ),
            ],
          ],
        ),
        if (!course.isEnrolled && course.hasDiscount)
          Padding(
            padding: const .symmetric(horizontal: 10),
            child: CustomText(
              course.price.toString().currency,
              style: TextStyle(
                fontSize: 14,
                color: context.color.textSecondary,
                decoration: TextDecoration.lineThrough,
                decorationThickness: 2,
                decorationColor: Colors.grey,
              ),
            ),
          ),
        const Spacer(),
        // if (!course.isEnrolled && showDiscountPercentage && course.hasDiscount)
        // _buildDiscount(context, course, CourseCardStyle.vertical),
      ],
    );
  }

  static Widget _buildPriceHorizontal(
    BuildContext context,
    CourseModel course, {
    double? fontSize,
  }) {
    return Row(
      spacing: 6,
      children: [
        if (course.isEnrolled)
          CustomText(
            AppLabels.enrolled.tr,
            style: TextStyle(
              color: Colors.green,
              fontSize: fontSize,
              fontWeight: .w600,
            ),
          )
        else if (course.isFree)
          CustomText(
            AppLabels.free.tr,
            style: TextStyle(
              color: context.color.primary,
              fontSize: fontSize,
              fontWeight: .w600,
            ),
          )
        else
          Flexible(
            child: CustomText(
              course.finalPrice.toString().currency,
              maxLines: 1,
              ellipsis: true,
              style: TextStyle(fontSize: fontSize, fontWeight: .w600),
            ),
          ),
        if (!course.isEnrolled && course.hasDiscount)
          Expanded(
            child: CustomText(
              course.price.toString().currency,
              maxLines: 1,
              ellipsis: true,
              style: TextStyle(
                fontSize: 12,
                color: context.color.textSecondary,
                decoration: TextDecoration.lineThrough,
                decorationThickness: 2,
                decorationColor: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}
