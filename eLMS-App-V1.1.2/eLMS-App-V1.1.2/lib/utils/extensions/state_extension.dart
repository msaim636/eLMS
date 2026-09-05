import 'package:flutter/material.dart' show State, WidgetsBinding;
import 'package:flutter/scheduler.dart';

extension StateExtension on State {
  void postFrame(FrameCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback(fn);
  }
}
