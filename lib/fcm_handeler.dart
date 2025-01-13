import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mtag_flutterapp/api/auth_controller.dart';

import '../../base/app_data.dart';
import '../../pages/notification/model/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagingService {
  static String? fcmToken;
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  ValueNotifier<int> badgeCountNotifier = ValueNotifier<int>(0);
  final String _badgeCountKey = 'badge_count';
bool _isPermissionRequestInProgress = false;
Future<void> _requestPermission() async {
  if (_isPermissionRequestInProgress) {
    return; // Prevent concurrent permission requests
  }
  
  _isPermissionRequestInProgress = true;

  try {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
if(Platform.isIOS){
  fcmToken=await _fcm.getAPNSToken();

      log("FCM token --> ${fcmToken.toString()}");
      AppData.setFcmToken(fcmToken.toString());
}
else if(Platform.isAndroid){
   fcmToken = await _fcm.getToken();
      log("FCM token --> ${fcmToken.toString()}");
      AppData.setFcmToken(fcmToken.toString());
}
     
    } else if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        await _requestPermission(); // Retry if not determined
      });
    }
  } finally {
    _isPermissionRequestInProgress = false; // Reset flag after completion
  }
}


  Future<void> init(BuildContext context) async {
    await _requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _fcm.setAutoInitEnabled(true);

    LocalNoticationsService(_notificationsPlugin).init();
    await _loadBadgeCount();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        badgeCountNotifier.value++;
        _updateBadgeCountInUI();

        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.max,
          playSound: true,
        );

        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);

        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (android != null) {
          _notificationsPlugin.show(
            notification.hashCode,
            notification?.title,
            notification?.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: '@mipmap/ic_launcher',
                priority: Priority.high,
                importance: Importance.max,
              ),
            ),
            payload: '${notification?.title}|${notification?.body}',
          );
        }
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null && context.mounted) {
        _handleNotificationClick(context, message);
        resetBadgeCount();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (context.mounted) {
        _handleNotificationClick(context, message);
        resetBadgeCount();
      }
    });
  }

  Future<void> _loadBadgeCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    badgeCountNotifier.value = prefs.getInt(_badgeCountKey) ?? 0;
  }

  Future<void> _updateBadgeCountInUI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_badgeCountKey, badgeCountNotifier.value);
  }

  Future<void> resetBadgeCount() async {
    badgeCountNotifier.value = 0;
    await _updateBadgeCountInUI();
  }

  @pragma('vm:entry-point')
  void _handleNotificationClick(BuildContext context, RemoteMessage message) async {
    await Future.delayed(Duration(milliseconds: 300));
    final notificationData = message.notification;
    log('Notification Data: $notificationData');

 Get.find<AuthController>().getLoginUserData()?.data!=null?   Get.toNamed('/notificationsExpandScreen',
        arguments: Data(
          body: notificationData?.body ?? '',
          dateTime: DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
          title: notificationData?.title ?? 'No title',
        )):null;
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  RemoteNotification? notification = message.notification;

  if (notification != null) {
    await Future.delayed(Duration(milliseconds: 500));
   Get.find<AuthController>().getLoginUserData()?.data!=null?   Get.toNamed('/notificationsExpandScreen',
        arguments: Data(
          body: notification.body ?? 'No message body',
          dateTime: DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
          title: notification.title ?? 'No title',
        )):null;
  }
}

class LocalNoticationsService {
  LocalNoticationsService(this._notificationsPlugin);
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );

    final notificationAppLaunchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      onSelectNotification(notificationAppLaunchDetails!.notificationResponse);
    }
  }

  Future<void> onSelectNotification(NotificationResponse? notificationResponse) async {
    if (notificationResponse != null) {
      await Future.delayed(Duration(milliseconds: 300));
      log("Notification clicked: ${notificationResponse.payload}");
      final payloadParts = notificationResponse.payload?.split('|');
      String? title = payloadParts?[0];
      String? body = payloadParts?[1];

     Get.find<AuthController>().getLoginUserData()?.data!=null?   Get.toNamed('/notificationsExpandScreen',
          arguments: Data(
            body: body,
            dateTime: DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
            title: title,
          )):null;
    }
  }
}
