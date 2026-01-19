import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/pages/notification/controller/notificationcontroller.dart';
import '/pages/notification/model/notification_model.dart';
import '../../base/app_data.dart';

class MessagingService {
  static String? fcmToken;
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final badgeCountNotifier = ValueNotifier<int>(0);
  static const String _badgeCountKey = 'badge_count';
  static const String _pendingNotificationKey = 'pending_notification';

  bool isAppInitialized = false;

  /// 🔒 PROD SAFE INIT
  Future<void> init(BuildContext context) async {
    try {
      await Firebase.initializeApp();
    } catch (_) {}

    await _safeRequestPermission();
    _initLocalNotifications();
    await _loadBadgeCount();

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (context.mounted) {
        _handleNotificationClick(context, message);
      }
      resetBadgeCount();
    });

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null && context.mounted) {
      _handleNotificationClick(context, initialMessage);
    }

    isAppInitialized = true;
    await _processPendingNotifications();
  }

  /// 🔒 NEVER CRASH
  Future<void> _safeRequestPermission() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        await _safeFetchToken();
      }
    } catch (e, s) {
      log('FCM permission failed (non-fatal): $e', stackTrace: s);
    }
  }

  /// 🔒 TOKEN FETCH MUST NEVER THROW
  Future<void> _safeFetchToken() async {
    try {
      if (Platform.isIOS) {
        try {
          final apnsToken = await _fcm.getAPNSToken();
          if (apnsToken != null) {
            AppData.setFcmToken(apnsToken);
          }
        } catch (_) {}
      }

      final token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        fcmToken = token;
        AppData.setFcmToken(token);
        log('FCM token fetched');
      }
    } catch (e, s) {
      // 🔥 THIS IS THE CRASH YOU WERE SEEING — NOW SAFE
      log('FCM token fetch failed (non-fatal): $e', stackTrace: s);
    }
  }

  void _initLocalNotifications() {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _onNotificationTap(response);
      },
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;

    final parts = response.payload!.split('|');
    if (parts.length < 3) return;

    final title = parts[0];
    final body = parts[1];
    final actionKey = parts[2];

    if (actionKey == 'open_new_intent') {
      Get.offAllNamed('/notificationIntent',
          arguments: _buildData(title, body));
    } else {
      Get.toNamed('/notificationsExpandScreen',
          arguments: _buildData(title, body));
    }
  }

  Data _buildData(String title, String body) {
    return Data(
      title: title,
      body: body,
      dateTime: DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
    );
  }

  Future<void> _handleForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    badgeCountNotifier.value++;
    await _updateBadgeCountInUI();

    try {
      final controller = Get.isRegistered<NotificationController>()
          ? Get.find<NotificationController>()
          : null;

      if (controller != null) {
        await controller.addNotification(
          Data(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: notification.title ?? '',
            body: notification.body ?? '',
            dateTime:
            DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
            datetimeSmall:
            DateFormat('dd-MM HH:mm').format(DateTime.now()),
            imageLink: message.data['image_link'],
            isSelected: false,
          ),
        );
      }

      _notificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
          ),
        ),
        payload:
        '${notification.title}|${notification.body}|${message.data['bg_n']}',
      );
    } catch (e) {
      log('Foreground notification error (ignored): $e');
    }
  }

  void _handleNotificationClick(
      BuildContext context, RemoteMessage message) {
    final notification = message.notification;
    final actionKey = message.data['bg_n'];

    if (actionKey == 'open_new_intent') {
      Get.offAllNamed(
        '/notificationIntent',
        arguments: _buildData(
          notification?.title ?? '',
          notification?.body ?? '',
        ),
      );
    } else {
      Get.toNamed(
        '/notificationsExpandScreen',
        arguments: _buildData(
          notification?.title ?? '',
          notification?.body ?? '',
        ),
      );
    }
  }

  Future<void> _loadBadgeCount() async {
    final prefs = await SharedPreferences.getInstance();
    badgeCountNotifier.value = prefs.getInt(_badgeCountKey) ?? 0;
  }

  Future<void> _updateBadgeCountInUI() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_badgeCountKey, badgeCountNotifier.value);
  }

  Future<void> resetBadgeCount() async {
    badgeCountNotifier.value = 0;
    await _updateBadgeCountInUI();
  }

  Future<void> _processPendingNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_pendingNotificationKey);
    if (json == null) return;

    try {
      final data = jsonDecode(json);
      if (Get.isRegistered<NotificationController>()) {
        await Get.find<NotificationController>().addNotification(
          Data(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: data['notification']?['title'] ?? '',
            body: data['notification']?['body'] ?? '',
            dateTime:
            DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
            datetimeSmall:
            DateFormat('dd-MM HH:mm').format(DateTime.now()),
            imageLink: data['data']?['image_link'],
            isSelected: false,
          ),
        );
      }
      await prefs.remove(_pendingNotificationKey);
    } catch (_) {}
  }
}
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      MessagingService._pendingNotificationKey,
      jsonEncode(message.toMap()),
    );
  } catch (_) {}
}
