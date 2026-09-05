import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/widgets/restricted_widget.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/course/services/course_content_notifier.dart';
import 'package:elms/features/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CourseNavigationHelper {
  /// Navigate to the appropriate screen based on course enrollment status.
  /// [context] is required to check wallet balance for the negative-wallet guard.
  static Future<void> navigateToCourse(
    CourseModel course, {
    required BuildContext context,
    int? initialChapterIndex,
    int? initialLectureIndex,
  }) async {
    if (course.isEnrolled) {
      // Guard: if wallet is negative (iOS refund), block access and show warning.
      final authCubit = context.read<AuthenticationCubit>();
      if ((authCubit.totalBalance ?? 0) < 0) {
        await NegativeWalletCourseAccessDialog.show(context);
        return;
      }

      if (AppConstant.kEnableExperimentalMiniPlayer) {
        // User is enrolled - show course content in stack with mini player support
        CourseContentNotifier.instance.showCourse(course);
      } else {
        // User is enrolled - navigate to course content screen using push

        courseContentNavigator.value = CourseContentScreenArguments(
          course: course,
          initialChapterIndex: initialChapterIndex,
          initialLectureIndex: initialLectureIndex,
        );

        // await Get.toNamed(
        //   AppRoutes.courseContentScreen,
        //   arguments: CourseContentScreenArguments(
        //     course: course,
        //     initialChapterIndex: initialChapterIndex,
        //     initialLectureIndex: initialLectureIndex,
        //   ),
        // );
      }
    } else {
      // User is not enrolled - navigate to course details screen
      await Get.toNamed(
        AppRoutes.courseDetailsScreen,
        arguments: CourseDetailsScreenArguments(course: course),
      );
    }
  }

  static void pop() {
    if (AppConstant.kEnableExperimentalMiniPlayer) {
      Get.nestedKey(1)?.currentState?.pop();
    } else {
      Get.back();
    }
  }

  /// Pop back to the course content screen
  /// This is useful when you want to return to the main course content from nested screens
  static void popToCourseContent() {
    if (AppConstant.kEnableExperimentalMiniPlayer) {
      // In nested navigator mode, pop until we reach the root (course content screen)
      final nestedNavigator = Get.nestedKey(1)?.currentState;
      if (nestedNavigator != null) {
        nestedNavigator.popUntil((route) => route.isFirst);
      }
    } else {
      // In regular navigation mode, pop until we reach the course content screen
      Get.until(
        (route) =>
            route.settings.name == AppRoutes.courseContentScreen ||
            route.isFirst,
      );
    }
  }

  /// Check if user can access course content
  static bool canAccessCourseContent(CourseModel course) {
    return course.isEnrolled;
  }

  /// Get appropriate route for course based on enrollment status
  static String getCourseRoute(CourseModel course) {
    return course.isEnrolled
        ? AppRoutes.courseContentScreen
        : AppRoutes.courseDetailsScreen;
  }

  /// Get appropriate arguments for course navigation
  static dynamic getCourseArguments(
    CourseModel course, {
    int? initialChapterIndex,
    int? initialLectureIndex,
  }) {
    if (course.isEnrolled) {
      return CourseContentScreenArguments(
        course: course,
        initialChapterIndex: initialChapterIndex,
        initialLectureIndex: initialLectureIndex,
      );
    } else {
      return CourseDetailsScreenArguments(course: course);
    }
  }

  /// Navigate to course content routes using nested navigator if available, otherwise use root navigator
  /// This intelligently chooses between nested and root routing based on the experimental feature flag
  static Future<T?> navigateToCourseContentRoute<T, TO>({
    required String nestedRoute,
    String? rootRoute,
    dynamic arguments,
    bool replace = false,
  }) async {
    // Check if we should use nested navigator based on experimental feature flag
    final nestedNavigator = Get.nestedKey(1)?.currentState;
    final useNestedNavigator =
        AppConstant.kEnableExperimentalMiniPlayer && nestedNavigator != null;

    if (useNestedNavigator) {
      // Use nested navigator for course content routes
      if (replace) {
        return nestedNavigator.pushReplacementNamed<T, TO>(
          nestedRoute,
          arguments: arguments,
        );
      }
      return nestedNavigator.pushNamed<T>(nestedRoute, arguments: arguments);
    } else {
      // Fall back to root navigator if nested navigator is not available
      // or experimental feature is disabled
      final routeToUse = rootRoute ?? nestedRoute;
      if (replace) {
        await Get.offNamed<T>(routeToUse, arguments: arguments);
        return null;
      }
      return Get.toNamed<T>(routeToUse, arguments: arguments);
    }
  }

  /// Get the next accessible lecture in sequential access mode
  static Map<String, int>? getNextAccessibleLecture({
    required bool sequentialAccess,
    required List<ChapterModel> chapters,
    required int currentChapterIndex,
    required int currentLectureIndex,
  }) {
    if (!sequentialAccess) {
      return null; // No restriction when sequential access is disabled
    }

    // Find the next lecture in the current chapter
    if (currentChapterIndex < chapters.length) {
      final currentChapter = chapters[currentChapterIndex];

      if (currentLectureIndex + 1 < currentChapter.curriculum.length) {
        return {
          'chapterIndex': currentChapterIndex,
          'lectureIndex': currentLectureIndex + 1,
        };
      }

      // Look for the first lecture in the next chapter
      if (currentChapterIndex + 1 < chapters.length) {
        final nextChapter = chapters[currentChapterIndex + 1];
        if (nextChapter.curriculum.isNotEmpty) {
          return {'chapterIndex': currentChapterIndex + 1, 'lectureIndex': 0};
        }
      }
    }

    return null; // No next lecture found
  }
}

/// Extension on CourseModel for convenient navigation
extension CourseNavigationExtension on CourseModel {
  /// Navigate to the appropriate screen based on enrollment status
  Future<void> navigateTo({
    required BuildContext context,
    int? initialChapterIndex,
    int? initialLectureIndex,
  }) async {
    await CourseNavigationHelper.navigateToCourse(
      this,
      context: context,
      initialChapterIndex: initialChapterIndex,
      initialLectureIndex: initialLectureIndex,
    );
  }

  /// Check if user can access course content
  bool get canAccessContent => isEnrolled;

  /// Get appropriate route based on enrollment status
  String get navigationRoute => isEnrolled
      ? AppRoutes.courseContentScreen
      : AppRoutes.courseDetailsScreen;
}
