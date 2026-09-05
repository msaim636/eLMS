import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/features/course/services/course_content_notifier.dart';
import 'package:elms/firebase_options.dart';

class NotificationManager {
  static bool initialized = false;

  /// Holds the initial notification message if the app was launched from a
  /// notification tap. Consumed once by [handleInitialMessage].
  static RemoteMessage? _pendingInitialMessage;

  static final FlutterLocalNotificationsPlugin instance =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default',
    'Default',
    description: 'Notification tests as alerts',
    importance: Importance.high,
    enableLights: true,
    ledColor: Colors.deepPurple,
  );

  static Future<void> checkPermissionAndInit() async {
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await init();
      }
    } catch (_) {}
  }

  static Future<void> requestPermissionAndInit() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      if (Platform.isIOS) {
        await instance
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
      await init();
    }
  }

  static Future<void> init() async {
    if (!initialized) {
      // Initialize flutter_local_notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings();

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await instance.initialize(
        initSettings,
        onDidReceiveNotificationResponse: onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            onBackgroundNotificationResponse,
      );

      // Create notification channel for Android
      if (Platform.isAndroid) {
        await instance
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(channel);
      }

      // Request permissions for iOS
      if (Platform.isIOS) {
        await instance
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
        await _showNotification(event);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((event) {
        onTap(event.data);
      });

      // Store the initial message so it can be handled AFTER the navigator
      // is ready (i.e., after splash navigation). Calling onTap() here would
      // block main() with an API call before runApp() is ever called.
      _pendingInitialMessage = await FirebaseMessaging.instance
          .getInitialMessage();

      initialized = true;
    }
  }

  /// Call this once after splash navigation is complete so the navigator is
  /// ready. Consumes and handles any notification the app was opened from.
  static Future<void> handleInitialMessage() async {
    final message = _pendingInitialMessage;
    _pendingInitialMessage = null;
    if (message != null) {
      await onTap(message.data);
    }
  }

  static Future<void> _showNotification(RemoteMessage event) async {
    final String? title = event.data['title'];
    final String body = event.data['body']?.toString() ?? '';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default',
          'Default',
          channelDescription: 'Notification tests as alerts',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.deepPurple,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Encode payload as JSON string
    final String payload = jsonEncode(event.data);

    await instance.show(
      Random().nextInt(5000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> onTap(Map<String, dynamic> data) async {
    final String? type = data['type']?.toString();

    if (type == null) {
      return;
    }

    switch (type) {
      case 'course':
        await _handleCourseNotification(data);
        break;
      case 'url':
        await _handleUrlNotification(data);
        break;
      default:
        break;
    }
  }

  /// Handle course type notifications
  /// Navigate to course content screen if user is enrolled, otherwise to details screen
  static Future<void> _handleCourseNotification(
    Map<String, dynamic> data,
  ) async {
    final int? courseId = int.tryParse(data['id']?.toString() ?? '');

    if (courseId == null) {
      return;
    }

    // Fetch course details to check enrollment status
    final repository = CourseRepository();
    final courseDetails = await repository.fetchCourseDetails(
      courseId: courseId,
    );

    // Navigate based on enrollment status
    if (courseDetails.isPurchased) {
      if (AppConstant.kEnableExperimentalMiniPlayer) {
        // User is enrolled - show course content in stack with mini player support
        CourseContentNotifier.instance.showCourse(courseDetails);
      } else {
        // User is enrolled - navigate to course content screen using push
        await Get.toNamed(
          AppRoutes.courseContentScreen,
          arguments: CourseContentScreenArguments(course: courseDetails),
        );
      }
    } else {
      // User is not enrolled - navigate to course details screen
      await Get.toNamed(
        AppRoutes.courseDetailsScreen,
        arguments: CourseDetailsScreenArguments(course: courseDetails),
      );
    }
  }

  /// Handle URL type notifications
  /// Open the link in external browser
  static Future<void> _handleUrlNotification(Map<String, dynamic> data) async {
    final String? urlString = data['link']?.toString();

    if (urlString == null || urlString.isEmpty) {
      return;
    }

    final Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  static void onNotificationResponse(NotificationResponse response) {
    _handleNotificationResponse(response);
  }

  @pragma("vm:entry-point")
  static void onBackgroundNotificationResponse(NotificationResponse response) {
    _handleNotificationResponse(response);
  }

  static void _handleNotificationResponse(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final Map<String, dynamic> payload =
            jsonDecode(response.payload!) as Map<String, dynamic>;
        onTap(payload);
      } catch (_) {}
    }
  }
}

@pragma("vm:entry-point")
Future<void> backgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('Firebase already initialized in background handler.');
    } else {
      rethrow;
    }
  }

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await NotificationManager.instance.initialize(
    initSettings,
    onDidReceiveNotificationResponse:
        NotificationManager.onNotificationResponse,
    onDidReceiveBackgroundNotificationResponse:
        NotificationManager.onBackgroundNotificationResponse,
  );

  if (Platform.isAndroid) {
    await NotificationManager.instance
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(NotificationManager.channel);
  }

  await NotificationManager._showNotification(message);
}
