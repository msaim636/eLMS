import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:elms/common/screens/deep_link_data_loader.dart';
import 'package:elms/core/configs/app_settings.dart';
import 'package:get/get.dart';

class DeepLinkManager {
  DeepLinkManager._();

  static final DeepLinkManager instance = DeepLinkManager._();

  late AppLinks _appLinks;
  StreamSubscription? _linkSubscription;
  bool _isInitialized = false;

  /// Initialize deep link handling
  /// Call this method in your app's initState or main function
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    _appLinks = AppLinks();

    // Handle initial link if app was opened from terminated state
    await _handleInitialLink();

    // Handle links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri.toString());
      }
    }, onError: (err) {});
  }

  String createDeepLink({required String slug}) {
    return '${AppSettings.webLink}/course-details/$slug?share=true';
  }

  Future<void> _handleInitialLink() async {
    final initialUri = await _appLinks.getInitialLink();

    if (initialUri == null) return;

    // Optional: prevent handling unwanted initial links
    if (!initialUri.toString().contains('course-details')) return;

    await Future.delayed(const Duration(milliseconds: 500));

    _handleDeepLink(initialUri.toString());
  }

  void _handleDeepLink(String link) {
    final Uri uri = Uri.parse(link);
    if (uri.pathSegments.isEmpty) {
      return;
    }

    Get.to(
      DeepLinkDataLoader(
        target: uri.pathSegments.first,
        params: {'slug': uri.pathSegments[1]},
      ),
    );
  }

  /// Dispose the deep link subscription
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _isInitialized = false;
  }
}
