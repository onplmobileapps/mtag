import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../base/app_data.dart';
import '../../pages/notification/model/notification_model.dart';

class LocalNotificationsService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  LocalNotificationsService(this._notificationsPlugin);

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );

    final details =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      _onSelectNotification(details!.notificationResponse);
    }
  }

  Future<void> _onSelectNotification(NotificationResponse? response) async {
    if (response?.payload == null) return;

    final parts = response!.payload!.split('|');
    final title = parts[0];
    final body = parts[1];
    final actionKey = parts[2];

    log('Notification clicked: $actionKey');

    // If bg_n is present and 'open_new_intent', remove the back stack
    if (actionKey == 'open_new_intent') {
      _navigateWithoutBackStack('/notificationIntent', title, body);
    } else {
      // If bg_n is not present, navigate with back stack
      _navigateWithBackStack('/notificationsExpandScreen', title, body);
    }
  }

  void _navigateWithBackStack(String route, String title, String body) {
    Get.toNamed(
      route,
      arguments: Data(
        title: title,
        body: body,
        dateTime: DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
      ),
    );
  }

  void _navigateWithoutBackStack(String route, String title, String body) {
    Get.offNamed(
      route,
      arguments: Data(
        title: title,
        body: body,
        dateTime: DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
      ),
    );
  }
}

class MessagingService {
  static String? fcmToken;
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final badgeCountNotifier = ValueNotifier<int>(0);
  final _badgeCountKey = 'badge_count';

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  bool isAppInitialized = false; // Flag to track app initialization
  bool isAppKilled = false; // Flag to track if app was opened from killed state

  Future<void> init(BuildContext context) async {
    await _requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    LocalNotificationsService(_notificationsPlugin).init();
    await _loadBadgeCount();

    // Handling app launch from killed state
    _fcm.getInitialMessage().then((message) {
      if (message != null&&context.mounted) _handleNotificationClick(context, message);
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
     if(context.mounted) _handleNotificationClick(context, message);
      resetBadgeCount();
    });

    // Ensure the app is fully initialized before handling any notification clicks
    await Firebase.initializeApp();
    isAppInitialized = true; // Mark as initialized
  }

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      fcmToken =
          Platform.isIOS ? await _fcm.getAPNSToken() : await _fcm.getToken();
      if (fcmToken != null) {
        log('FCM Token: $fcmToken');
        AppData.setFcmToken(fcmToken!);
      }
    }
  }

  Future<void> _handleForegroundNotification(RemoteMessage message) async {
    if (message.notification == null) return;

    badgeCountNotifier.value++;
    _updateBadgeCountInUI();

    // Create the Android Notification channel
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Important notifications channel.',
      importance: Importance.max,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    final notification = message.notification;
    if (notification?.android != null) {
      _notificationsPlugin.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            androidChannel.id,
            androidChannel.name,
            channelDescription: androidChannel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload:
            '${notification?.title}|${notification?.body}|${message.data['bg_n']}',
      );
    }
  }

  void _handleNotificationClick(
      BuildContext context, RemoteMessage message) async {
    if (!isAppInitialized) {
      // Wait until the app is initialized before processing the notification click
      log('App is not initialized yet. Waiting...');
      Future.delayed(Duration(seconds: 2), () {
      if(context.mounted)  _handleNotificationClick(context, message); // Retry handling
      });
      return;
    }

    final notificationData = message.notification;
    log('Notification Data: $notificationData');

    final actionKey = message.data['bg_n'];

    // If the action key is 'open_new_intent', navigate with no back stack
    if (actionKey != null && actionKey == 'open_new_intent') {
      log('Navigating to /notificationIntent with no back stack');
      Get.offAllNamed(
        '/notificationIntent',
        arguments: Data(
          title: notificationData?.title ?? '',
          body: notificationData?.body ?? '',
          dateTime: DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
        ),
      );
    } else {
      // For notifications without 'bg_n', navigate to /notificationsExpandScreen and preserve the back stack
      log('Navigating to /notificationsExpandScreen with back stack');

      // Adding a small delay before navigation to ensure proper initialization
      Future.delayed(Duration(seconds: 1), () {
        if (navigatorKey.currentState != null) {
          Get.toNamed(
            '/notificationsExpandScreen',
            arguments: Data(
              title: notificationData?.title ?? '',
              body: notificationData?.body ?? '',
              dateTime: DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
            ),
          );
        }
      });
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
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  RemoteNotification? notification = message.notification;
  if (notification == null) return;

  final actionKey = message.data['bg_n'];

  // If the action key is 'open_new_intent', navigate with no back stack
  if (actionKey != null && actionKey == 'open_new_intent') {
    Get.offAllNamed('/notificationIntent',
        arguments: Data(
          title: notification.title ?? '',
          body: notification.body ?? '',
          dateTime: DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
        ));
    return;
  }

  // For notifications without 'bg_n', navigate to notificationsExpandScreen and preserve the back stack
  log('Navigating to /notificationsExpandScreen with back stack in background');
  Get.toNamed('/notificationsExpandScreen',
      arguments: Data(
        title: notification.title ?? '',
        body: notification.body ?? '',
        dateTime: DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
      ));
}