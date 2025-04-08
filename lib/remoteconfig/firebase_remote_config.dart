// import 'dart:developer';
//
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:get/get.dart';
//
// import '../constants/other_consts.dart';
//
// class FirebaseRemoteConfigService {
//   FirebaseRemoteConfigService._()
//       : _remoteConfig = FirebaseRemoteConfig.instance; // MODIFIED
//
//   static FirebaseRemoteConfigService? _instance; // NEW
//   factory FirebaseRemoteConfigService() =>
//       _instance ??= FirebaseRemoteConfigService._(); // NEW
//   final _otherConstants = OtherConsts();
//   final FirebaseRemoteConfig _remoteConfig;
//   RemoteConfigSettings configSettings = RemoteConfigSettings(
//     minimumFetchInterval: const Duration(seconds: 30),
//     fetchTimeout:
//         const Duration(seconds: 30), // Set the cache duration to 30 sec
//   );
//   Future<void> fetchRemoteConfig() async {
//     try {
//       await _remoteConfig.ensureInitialized();
//       await _remoteConfig.fetch();
//       await _remoteConfig.activate();
//       await _remoteConfig.fetchAndActivate();
//       await _remoteConfig.setConfigSettings(configSettings);
//       await _remoteConfig.setDefaults({
//         'enableMaintenceMood': 'false',
//       });
//
//       var val = _remoteConfig.getValue("enableMaintenceMood");
//       _otherConstants.emergencySwitchProd.value =
//           _remoteConfig.getValue('emergency_switch_prod').asString();
//       _otherConstants.emergencySwitchDebug.value =
//           _remoteConfig.getValue('emergency_switch_debug').asString();
//       _otherConstants.discountText.value =
//           _remoteConfig.getValue('promotional_message').asString();
//       _otherConstants.promoPopUp.value =
//           _remoteConfig.getValue("promo_popup").asString();
//       log(' Prod--->${_otherConstants.emergencySwitchProd} Debugg-->${_otherConstants.emergencySwitchDebug}');
//
//       log(val.asString().toString());
//       if (val.asBool() == true) {
//         Get.offAndToNamed('/maintenancePage');
//       }
//     } catch (e) {
//       throw Exception(e);
//     }
//   }
// }

// import 'dart:developer';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import '../constants/other_consts.dart';
//
// class FirebaseRemoteConfigService {
//   FirebaseRemoteConfigService._()
//       : _remoteConfig = FirebaseRemoteConfig.instance;
//
//   static FirebaseRemoteConfigService? _instance;
//   factory FirebaseRemoteConfigService() => _instance ??= FirebaseRemoteConfigService._();
//
//   final _otherConstants = OtherConsts();
//   final FirebaseRemoteConfig _remoteConfig;
//   final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   RemoteConfigSettings configSettings = RemoteConfigSettings(
//     minimumFetchInterval: const Duration(seconds: 30),
//     fetchTimeout: const Duration(seconds: 30),
//   );
//
//   Future<void> initializeNotifications() async {
//     const AndroidInitializationSettings androidSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     await _notificationsPlugin.initialize(
//       InitializationSettings(
//         android: androidSettings,
//         iOS: iosSettings,
//       ),
//     );
//   }
//
//   Future<void> fetchRemoteConfig() async {
//     try {
//       await Firebase.initializeApp();
//       await _remoteConfig.ensureInitialized();
//
//       // Set defaults before fetching
//       await _remoteConfig.setDefaults({
//         'enableMaintenceMood': 'false',
//         'emergency_switch_prod': 'false',
//         'emergency_switch_debug': 'false',
//         'promotional_message': '',
//         'promo_popup': '',
//         'enable_notification': 'true',
//         'notification_title': 'New Update!',
//         'notification_body': 'Check out our latest features',
//       });
//
//       await _remoteConfig.setConfigSettings(configSettings);
//       await _remoteConfig.fetchAndActivate();
//
//       // Get values using your original approach
//       var val = _remoteConfig.getValue("enableMaintenceMood");
//       _otherConstants.emergencySwitchProd.value =
//           _remoteConfig.getValue('emergency_switch_prod').asString();
//       _otherConstants.emergencySwitchDebug.value =
//           _remoteConfig.getValue('emergency_switch_debug').asString();
//       _otherConstants.discountText.value =
//           _remoteConfig.getValue('promotional_message').asString();
//       _otherConstants.promoPopUp.value =
//           _remoteConfig.getValue("promo_popup").asString();
//
//       log('Prod--->${_otherConstants.emergencySwitchProd} Debugg-->${_otherConstants.emergencySwitchDebug}');
//       log(val.asString().toString());
//
//       // Check if notification should be shown
//       if (_remoteConfig.getBool('enable_notification')) {
//         await _triggerNotification(
//           _remoteConfig.getString('notification_title'),
//           _remoteConfig.getString('notification_body'),
//         );
//       }
//
//       if (val.asBool() == true) {
//         Get.offAndToNamed('/maintenancePage');
//       }
//     } catch (e, stack) {
//       log('Remote Config Error', error: e, stackTrace: stack);
//       throw Exception(e);
//     }
//   }
//
//   Future<void> _triggerNotification(String title, String body) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'remote_config_channel',
//       'Remote Config Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//
//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
//
//     await _notificationsPlugin.show(
//       0,
//       title,
//       body,
//       const NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:developer' show log;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import '../constants/other_consts.dart';

class FirebaseRemoteConfigService {
  static final FirebaseRemoteConfigService _instance = FirebaseRemoteConfigService._();
  factory FirebaseRemoteConfigService() => _instance;

  FirebaseRemoteConfigService._() : _remoteConfig = FirebaseRemoteConfig.instance;

  final _otherConstants = OtherConsts();
  final FirebaseRemoteConfig _remoteConfig;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  RemoteConfigSettings configSettings = RemoteConfigSettings(
    minimumFetchInterval: const Duration(hours: 1), // Adjust for production
    fetchTimeout: const Duration(seconds: 60),
  );

  static const String immediateChannelId = 'immediate_notifications';
  static const String scheduledChannelId = 'scheduled_notifications';
  static const String repeatingChannelId = 'repeating_notifications';

  Future<void> initializeNotifications() async {
    const AndroidNotificationChannel immediateChannel = AndroidNotificationChannel(
      immediateChannelId,
      'Immediate Notifications',
      importance: Importance.max,
    );

    const AndroidNotificationChannel scheduledChannel = AndroidNotificationChannel(
      scheduledChannelId,
      'Scheduled Notifications',
      importance: Importance.max,
    );

    const AndroidNotificationChannel repeatingChannel = AndroidNotificationChannel(
      repeatingChannelId,
      'Repeating Notifications',
      importance: Importance.max,
    );


    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(immediateChannel);
    await androidPlugin?.createNotificationChannel(scheduledChannel);
    await androidPlugin?.createNotificationChannel(repeatingChannel);

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notificationsPlugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapHandler,
    );
  }

  Future<void> fetchRemoteConfig() async {
    try {
      await _remoteConfig.ensureInitialized();
      log('Remote Config initialized');
      await _remoteConfig.setConfigSettings(configSettings);
      log('Config settings applied');
      await _remoteConfig.setDefaults({
        'enableMaintenanceMode': false,
        'enable_notification': true, // Default is false
        'notification_title': 'New Update!',
        'notification_body': 'Check out our latest features',
        'enable_scheduled_notification': false,
        'scheduled_notification_date': '',
        'enable_repeating_notification': false,
        'repeating_notification_interval': 86400,
        'repeating_notification_start_date': '',
      });
      log('Defaults set');

      try {
        final bool fetchSuccess = await _remoteConfig.fetchAndActivate();
        if (!fetchSuccess) {
          log('Failed to fetch and activate remote config');
          log('Last fetch time: ${_remoteConfig.lastFetchTime}');
          log('Last fetch status: ${_remoteConfig.lastFetchStatus}');
          log('Using cached values if available');
        } else {
          log('Config fetched and activated successfully');
        }
      } on FirebaseException catch (e) {
        log('FirebaseException: ${e.code} - ${e.message}');
      }

      _otherConstants.emergencySwitchProd.value =
          _remoteConfig.getString('emergency_switch_prod');
      _otherConstants.emergencySwitchDebug.value =
          _remoteConfig.getString('emergency_switch_debug');
      _otherConstants.discountText.value =
          _remoteConfig.getString('promotional_message');
      _otherConstants.promoPopUp.value =
          _remoteConfig.getString('promo_popup');

      final bool maintenanceMode = _remoteConfig.getBool('enableMaintenanceMode');

      log('enable_notification value: ${_remoteConfig.getBool('enable_notification')}');
      await _handleNotifications();

      if (maintenanceMode) {
        Get.offAndToNamed('/maintenancePage');
      }
    } catch (e) {
      log('Error in fetchRemoteConfig: $e', level: 1000);
      rethrow;
    }
  }
  Future<void> _handleNotifications() async {
    try {
      if (_remoteConfig.getBool('enable_notification')) {
        await _triggerNotification(
          _remoteConfig.getString('notification_title'),
          _remoteConfig.getString('notification_body'),
          immediateChannelId,
        );
      }

      if (_remoteConfig.getBool('enable_scheduled_notification')) {
        final dateString = _remoteConfig.getString('scheduled_notification_date');
        if (dateString.isNotEmpty) {
          await _scheduleFlexibleNotification(
            title: _remoteConfig.getString('notification_title'),
            body: _remoteConfig.getString('notification_body'),
            dateString: dateString,
            channelId: scheduledChannelId,
            isRepeating: false,
          );
        }
      }

      if (_remoteConfig.getBool('enable_repeating_notification')) {
        final interval = _remoteConfig.getInt('repeating_notification_interval');
        final startDateString = _remoteConfig.getString('repeating_notification_start_date');

        await _scheduleFlexibleNotification(
          title: _remoteConfig.getString('notification_title'),
          body: _remoteConfig.getString('notification_body'),
          dateString: startDateString,
          interval: Duration(seconds: interval),
          channelId: repeatingChannelId,
          isRepeating: true,
        );
      }
    } catch (e) {
      log('Error handling notifications: $e', level: 900);
    }
  }

  Future<void> _triggerNotification(
      String title,
      String body,
      String channelId,
      ) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelId.replaceAll('_', ' ').capitalizeFirst!,
        importance: Importance.max,
        enableLights: true,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      _generateNotificationId(),
      title,
      body,
      notificationDetails,
      payload: 'notification_payload',
    );
  }

  Future<void> _scheduleFlexibleNotification({
    required String title,
    required String body,
    required String dateString,
    required String channelId,
    Duration? interval,
    bool isRepeating = false,
  }) async {
    try {
      DateTime scheduledDate = dateString.isNotEmpty
          ? DateTime.parse(dateString)
          : DateTime.now().add(const Duration(seconds: 10));

      final now = DateTime.now();
      if (scheduledDate.isBefore(now) && isRepeating == false) {
        await _triggerNotification(title, body, channelId);
        return;
      }

      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId.replaceAll('_', ' ').capitalizeFirst!,
          importance: Importance.max,
          enableLights: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      final id = _generateNotificationId();

      if (isRepeating && interval != null) {
        await _notificationsPlugin.periodicallyShow(
          id,
          title,
          body,
          _getRepeatInterval(interval),
          notificationDetails,
          payload: 'repeating_notification',
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } else {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      log('Error scheduling notification: $e', level: 900);
      rethrow;
    }
  }

  RepeatInterval _getRepeatInterval(Duration duration) {
    if (duration.inDays >= 1) return RepeatInterval.daily;
    if (duration.inHours >= 1) return RepeatInterval.hourly;
    return RepeatInterval.everyMinute;
  }

  int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch % 100000;
  }

  void _handleNotificationTap(String? payload) {
    log('Notification tapped with payload: $payload');
  }

  void _handleNotificationInForeground(String? title, String? body) {
    log('Notification received in foreground - Title: $title, Body: $body');
    Get.snackbar(title ?? 'Notification', body ?? '');
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    log('All notifications cancelled');
  }

  Future<void> cancelScheduledNotifications() async {
    await _notificationsPlugin.cancelAll();
    log('Scheduled notifications cancelled');
  }
}

@pragma('vm:entry-point')
void notificationTapHandler(NotificationResponse response) {
  log('Background notification tapped with payload: ${response.payload}');
}