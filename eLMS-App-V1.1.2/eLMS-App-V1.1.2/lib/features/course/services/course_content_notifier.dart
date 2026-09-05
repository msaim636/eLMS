import 'package:elms/common/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Notifier to manage course content display in the main screen stack
/// This allows the mini player to work properly without navigation
class CourseContentNotifier extends ChangeNotifier {
  static final CourseContentNotifier instance = CourseContentNotifier._();

  CourseContentNotifier._();

  /// The currently displayed course
  CourseModel? _currentCourse;

  /// Whether the course content screen is visible
  bool _isVisible = false;

  /// Get the current course
  CourseModel? get currentCourse => _currentCourse;

  /// Check if course content is visible
  bool get isVisible => _isVisible;

  /// Show course content screen in the stack
  void showCourse(CourseModel course) {
    _currentCourse = course;
    _isVisible = true;
    notifyListeners();
  }

  /// Hide the course content screen
  void hide() {
    _isVisible = false;
    Get.keys.remove(1);
    notifyListeners();
  }

  /// Clear the course content
  void clear() {
    _currentCourse = null;
    _isVisible = false;
    notifyListeners();
  }

  /// Check if a specific course is currently showing
  bool isShowingCourse(int courseId) {
    return _currentCourse?.id == courseId && _isVisible;
  }
}
