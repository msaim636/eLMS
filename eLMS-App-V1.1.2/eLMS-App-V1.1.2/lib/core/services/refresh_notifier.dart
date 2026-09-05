import 'package:get/get.dart';

/// Service to notify screens when they need to refresh their data
/// Used when data is modified in another screen and needs to update parent screens
class RefreshNotifier extends GetxController {
  static RefreshNotifier get instance => Get.find<RefreshNotifier>();

  final _shouldRefreshMyLearning = false.obs;

  bool get shouldRefreshMyLearning => _shouldRefreshMyLearning.value;

  /// Mark that My Learning screen needs to refresh
  void markMyLearningForRefresh() {
    _shouldRefreshMyLearning.value = true;
  }

  /// Clear the refresh flag for My Learning
  void clearMyLearningRefresh() {
    _shouldRefreshMyLearning.value = false;
  }

  /// Check if My Learning needs refresh and clear the flag
  bool consumeMyLearningRefresh() {
    if (_shouldRefreshMyLearning.value) {
      _shouldRefreshMyLearning.value = false;
      return true;
    }
    return false;
  }
}
