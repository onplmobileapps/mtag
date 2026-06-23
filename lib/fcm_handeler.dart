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
      settings: initSettings,
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
    if (parts.length < 3) return;

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
    try {
      // Initialize Firebase FIRST (this is critical)
      await Firebase.initializeApp();
      log('✅ Firebase initialized successfully');

      // Set up notification presentation options
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Initialize local notifications
      await LocalNotificationsService(_notificationsPlugin).init();
      await _loadBadgeCount();

      // Set up message handlers BEFORE requesting permissions
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen(_handleForegroundNotification);
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (context.mounted) {
          _handleNotificationClick(context, message);
        }
        resetBadgeCount();
      });

      // Handle initial message
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null && context.mounted) {
        _handleNotificationClick(context, initialMessage);
      }

      // Request permissions (WITH NETWORK ERROR HANDLING)
      await _requestPermission();

      isAppInitialized = true;
      await _processPendingNotifications();

      log('✅ MessagingService initialized successfully');
    } catch (e, stack) {
      log('❌ MessagingService init failed: $e', error: e, stackTrace: stack);
      // Don't crash the app - continue without FCM
      isAppInitialized = true;
    }
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
      );

      log('📱 Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {

        // Try to get tokens with error handling
        await _getTokensWithRetry();
      } else {
        log('ℹ️ Notification permission not fully granted: ${settings.authorizationStatus}');
      }
    } catch (e, stack) {
      log('❌ Permission request failed (non-fatal): $e', error: e, stackTrace: stack);
      // Non-fatal error - app can work without FCM
    }
  }

  Future<void> _getTokensWithRetry({int maxRetries = 2}) async {
    try {
      // Try iOS APNS token first (if applicable)
      if (Platform.isIOS) {
        try {
          final apnsToken = await _fcm.getAPNSToken();
          if (apnsToken != null && apnsToken.isNotEmpty) {
            AppData.setFcmToken(apnsToken);
            log('✅ APNS token fetched: ${apnsToken.substring(0, 15)}...');
          } else {
            log('ℹ️ APNS token not available yet');
          }
        } catch (e) {
          log('⚠️ APNS token fetch failed: $e');
          // Non-fatal - continue with FCM token
        }
      }

      // Try to get FCM token with retry logic
      String? token;
      int retryCount = 0;

      while (retryCount < maxRetries && token == null) {
        try {
          token = await _fcm.getToken();
          if (token != null && token.isNotEmpty) {
            fcmToken = token;
            AppData.setFcmToken(token);
            log('✅ FCM token fetched: ${token.substring(0, 15)}...');
            break;
          }
        } catch (e) {
          log('⚠️ FCM token attempt ${retryCount + 1} failed: $e');
          if (retryCount < maxRetries - 1) {
            await Future.delayed(Duration(seconds: 1));
          }
        }
        retryCount++;
      }

      if (token == null) {
        log('ℹ️ FCM token not available - will retry later via onTokenRefresh');
        // Set up token refresh listener for when network is available
        _setupTokenRefreshListener();
      }
    } catch (e, stack) {
      log('❌ Token fetch failed completely: $e', error: e, stackTrace: stack);
      _setupTokenRefreshListener(); // Still set up listener for later
    }
  }

  void _setupTokenRefreshListener() {
    _fcm.onTokenRefresh.listen((token) {
      if (token.isNotEmpty) {
        fcmToken = token;
        AppData.setFcmToken(token);
        log('🔄 FCM token refreshed: ${token.substring(0, 15)}...');
      }
    });
  }

  Future<void> _handleForegroundNotification(RemoteMessage message) async {
    try {
      if (message.notification == null) return;

      badgeCountNotifier.value++;
      await _updateBadgeCountInUI();

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

      // Add to controller if available
      if (Get.isRegistered<NotificationController>()) {
        try {
          final controller = Get.find<NotificationController>();
          if (notification?.body != null) {
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
        } catch (e) {
          log('⚠️ Failed to add notification to controller: $e');
        }
      }

      if (notification?.android != null) {
        await _notificationsPlugin.show(
          id: notification.hashCode,
          title: notification?.title,
          body: notification?.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              androidChannel.id,
              androidChannel.name,
              channelDescription: androidChannel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload:
          '${notification?.title}|${notification?.body}|${message.data['bg_n'] ?? 'default'}',
        );
        log('📱 Foreground notification shown: ${notification?.title}');
      }
    } catch (e, stack) {
      log('❌ Foreground notification handling failed: $e', error: e, stackTrace: stack);
    }
  }

  void _handleNotificationClick(
      BuildContext context, RemoteMessage message) async {
    try {
      if (!isAppInitialized) {
        log('App is not initialized yet. Waiting...');
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) _handleNotificationClick(context, message);
        });
        return;
      }

      final notificationData = message.notification;
      final actionKey = message.data['bg_n'] ?? 'default';

      log('Notification clicked - Action: $actionKey, Title: ${notificationData?.title}');

      if (actionKey == 'open_new_intent') {
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
        log('Navigating to /notificationsExpandScreen');
        Get.toNamed(
          '/notificationsExpandScreen',
          arguments: Data(
            title: notificationData?.title ?? '',
            body: notificationData?.body ?? '',
            dateTime: DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now()),
          ),
        );
      }

      resetBadgeCount();
    } catch (e, stack) {
      log('❌ Notification click handling failed: $e', error: e, stackTrace: stack);
    }
  }

  Future<void> _loadBadgeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      badgeCountNotifier.value = prefs.getInt(_badgeCountKey) ?? 0;
    } catch (e) {
      log('⚠️ Failed to load badge count: $e');
      badgeCountNotifier.value = 0;
    }
  }

  Future<void> _updateBadgeCountInUI() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_badgeCountKey, badgeCountNotifier.value);
    } catch (e) {
      log('⚠️ Failed to update badge count: $e');
    }
  }

  Future<void> resetBadgeCount() async {
    badgeCountNotifier.value = 0;
    await _updateBadgeCountInUI();
  }

  Future<void> _processPendingNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? pendingJson = prefs.getString(_pendingNotificationKey);

      if (pendingJson != null) {
        final Map<String, dynamic> messageData = jsonDecode(pendingJson);

        if (Get.isRegistered<NotificationController>()) {
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
          log('📨 Processed pending notification');
        }

        await prefs.remove(_pendingNotificationKey);
      }
    } catch (e, stack) {
      log('❌ Failed to process pending notifications: $e', error: e, stackTrace: stack);
    }
  }

  // Optional: Check if FCM is available
  Future<bool> isFcmAvailable() async {
    try {
      await _fcm.getToken();
      return true;
    } catch (_) {
      return false;
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      MessagingService._pendingNotificationKey,
      jsonEncode(message.toMap()),
    );

    log('📱 Background notification saved for later processing');
  } catch (e) {
    log('❌ Background handler error: $e');
  }
}