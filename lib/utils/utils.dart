import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';

import 'package:mtag_flutterapp/controller/home_controller.dart';

// sealed class StatusBarUtils {
//   static void changeBarColor() {
//     var color = Colors.white;

//     if (AppData.theme == true) {
//       color = Colors.black;
//     } else if (AppData.theme == false) {
//       color = Colors.white;
//     } else {
//       if (Get.isDarkMode) {
//         color = Colors.black;
//       } else {
//         color = Colors.white;
//       }
//     }
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: color));
//   }
// }

sealed class AmountList{
  static final List<int> amountList = [500, 1000, 1500, 2000, 3000, 4000, 5000];
}


sealed class DeviceInfo {
  static getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    Map<String, dynamic> deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData['manufacturer'] = androidInfo.manufacturer;
        deviceData['model'] = androidInfo.model;
        deviceData['release'] = androidInfo.version.release;
        deviceData['deviceId'] = androidInfo.id;
        deviceData['buildVersion'] = androidInfo.version.sdkInt.toString();
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData['manufacturer'] = 'Apple';
        deviceData['model'] = iosInfo.model;
        deviceData['release'] = iosInfo.systemVersion;
        deviceData['deviceId'] = iosInfo.identifierForVendor;
        deviceData['buildVersion'] = iosInfo.utsname.version;
      }
    } catch (e) {
      log('Error: $e');
    }
    return deviceData;
  }
}

sealed class AppReviewUtils {
  static void requestAppReview() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }
}
sealed class AppUpdate{
 static Future<void> checkForUpdates() async {
    try {
      final updateStatus = await InAppUpdate.checkForUpdate();
      if (updateStatus.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      // Handle any errors that occurred during the update check
      log('Error checking for updates: $e');
    }
  }
}
 
void startTimer(ValueNotifier<Duration> timerNotifier) {
  Timer.periodic(Duration(seconds: 1), (timer) {
    if (timerNotifier.value > Duration.zero) {
      timerNotifier.value -= Duration(seconds: 1); // Decrement timer
    } else {
      timer.cancel(); // Stop the timer when it reaches zero
    }
  });
}
String? validateAmount(String? value) {
  if (value == null || value.isEmpty) {
    return 'Amount is required';
  }

  final parsedValue = int.tryParse(value);
  if (parsedValue == null) {
    return 'Amount must be a valid integer';
  }

  if (parsedValue <int.parse('${Get.find<HomeController>().dashboradData.value.rechargeMinAmount}')||parsedValue>int.parse('${Get.find<HomeController>().dashboradData.value.rechargeMaxAmount}')) {
    return 'Amount must be between ${Get.find<HomeController>().dashboradData.value.rechargeMinAmount} to ${Get.find<HomeController>().dashboradData.value.rechargeMaxAmount} PKR';
  }

  return null; // Return null if validation passes
}
String formatDateTime(String inputDateTime, {bool roundMinutes = false}) {
  try {
    // Parse the input date-time string
    DateTime dateTime = DateFormat("yy-MM-dd HH:mm:ss").parse(inputDateTime);

    // Optionally round the minutes to 00
    if (roundMinutes) {
      dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour);
    }

    // Format the date-time to the desired output format
    return DateFormat("dd MMM yy h:mm a").format(dateTime);
  } catch (e) {
    return 'Invalid date format';
  }
}
