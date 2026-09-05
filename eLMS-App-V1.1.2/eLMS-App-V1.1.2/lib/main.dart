// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';
import 'dart:io';
import 'package:elms/core/app.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/debug/screen_width_tester.dart';
import 'package:elms/core/debug/production_devtools/error_logger/error_logger_service.dart';
import 'package:elms/core/error_management/exception_handler.dart';
import 'package:elms/core/localization/app_localization.dart';
import 'package:elms/core/notification/notification_manager.dart';
import 'package:elms/utils/local_storage.dart';
import 'package:elms/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:elms/firebase_options.dart';

///V-1.1.2
Future<void> main() async {
  ///This line is to enable api logging in dev tools
  HttpClient.enableTimelineLogging = true;
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([.portraitUp]);

  await LocalStorage.init();

  ///If you are facing error in this line that means firebase setup is missing
  ///Please follow documentation for this
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('Firebase already initialized.');
    } else {
      rethrow;
    }
  }

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await AppLocalization.instance.init();

  await Utils.getSIMCountry().timeout(
    const Duration(seconds: 3),
    onTimeout: () => null,
  );

  await NotificationManager.checkPermissionAndInit().timeout(
    const Duration(seconds: 5),
    onTimeout: () {},
  );

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  ExceptionHandler.overrideFlutterErrorWidget();

  // Initialize error logger and register global error handlers
  await ErrorLoggerService.instance.init();
  ExceptionHandler.registerErrorSnackbarService();

  runApp(
    const ScreenWidthTester(
      enabled: AppConstant.kEnableScreenWidthTester,
      child: App(),
    ),
  );
}
