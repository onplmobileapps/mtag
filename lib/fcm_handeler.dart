import 'dart:convert';
import 'dart:developer';
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

    if (actionKey == 'open_new_intent') {
      _navigateWithoutBackStack('/notificationIntent', title, body);
    } else {
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
  static const String _pendingNotificationKey = 'pending_notification';

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  bool isAppInitialized = false;

  Future<void> init(BuildContext context) async {
    await _requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    LocalNotificationsService(_notificationsPlugin).init();
    await _loadBadgeCount();

    _fcm.getInitialMessage().then((message) {
      if (message != null && context.mounted)
        _handleNotificationClick(context, message);
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (context.mounted) _handleNotificationClick(context, message);
      resetBadgeCount();
    });

    await Firebase.initializeApp();
    isAppInitialized = true;

    await _processPendingNotifications();
  }

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      fcmToken = await _fcm.getToken();
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

      final controller = Get.find<NotificationController>();
      await controller.addNotification(Data(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification?.title ?? '',
        body: notification?.body ?? '',
        dateTime: DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
        datetimeSmall: DateFormat('dd-MM HH:mm').format(DateTime.now()),
        imageLink: message.data['image_link'],
        isSelected: false,
      ));
    }
  }

  void _handleNotificationClick(
      BuildContext context, RemoteMessage message) async {
    if (!isAppInitialized) {
      log('App is not initialized yet. Waiting...');
      Future.delayed(Duration(seconds: 2), () {
        if (context.mounted) _handleNotificationClick(context, message);
      });
      return;
    }

    final notificationData = message.notification;
    log('Notification Data: $notificationData');

    final actionKey = message.data['bg_n'];

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
      log('Navigating to /notificationsExpandScreen with back stack');
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

  Future<void> _processPendingNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pendingJson = prefs.getString(_pendingNotificationKey);
    if (pendingJson != null) {
      final Map<String, dynamic> messageData = jsonDecode(pendingJson);
      final controller = Get.find<NotificationController>();
      await controller.addNotification(Data(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: messageData['notification']?['title'] ?? '',
        body: messageData['notification']?['body'] ?? '',
        dateTime: DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
        datetimeSmall: DateFormat('dd-MM HH:mm').format(DateTime.now()),
        imageLink: messageData['data']?['image_link'],
        isSelected: false,
      ));
      await prefs.remove(_pendingNotificationKey);
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  RemoteNotification? notification = message.notification;
  if (notification == null) return;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    MessagingService._pendingNotificationKey,
    jsonEncode(message.toMap()),
  );
}
