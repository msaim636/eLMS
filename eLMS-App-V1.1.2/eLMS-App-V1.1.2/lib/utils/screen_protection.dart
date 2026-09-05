import 'package:elms/core/constants/app_constant.dart';
import 'package:flutter/widgets.dart';
import 'package:screen_protector/screen_protector.dart';

/// Mixin that enables screen capture prevention when the widget is active
/// and disables it when the widget is disposed.
///
/// Use this on screens that display sensitive content like videos, quizzes,
/// or documents.
mixin ScreenProtection<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    if (AppConstant.kPreventScreenCapture) {
      ScreenProtector.protectDataLeakageOn();
    }
  }

  @override
  void dispose() {
    if (AppConstant.kPreventScreenCapture) {
      ScreenProtector.protectDataLeakageOff();
    }
    super.dispose();
  }
}
