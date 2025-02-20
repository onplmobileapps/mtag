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

sealed class AmountList {
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

sealed class AppUpdate {
  static Future<void> checkForUpdates() async {
    try {
      final updateStatus = await InAppUpdate.checkForUpdate();
      if (updateStatus.updateAvailability ==
          UpdateAvailability.updateAvailable) {
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
      timer.cancel();
    }
  });
}

String ?validateJazzcashNumber(String ?number){
  if(number==null){
    return 'Please enter valid jazzcash number';

  }
  else if(!number.startsWith('03')){
    return 'Please enter 03XXXXXXXXX format Jazzcah Cash Number';
  }
  else if(number.length<11){
   return 'Please enter your 11 digit jazzcash number';
  }
  return null;
}
String? validateAmount(String? value) {
  if (value == null || value.isEmpty) {
    return 'Amount is required';
  }

  final parsedValue = int.tryParse(value);
  if (parsedValue == null) {
    return 'Amount must be a valid integer';
  }

  final homeController = Get.find<HomeController>();
  final minAmount =
      int.tryParse('${homeController.dashboradData.value.rechargeMinAmount}');
  final maxAmount =
      int.tryParse('${homeController.dashboradData.value.rechargeMaxAmount}');

  if (minAmount == null || maxAmount == null) {
    return 'Invalid amount range';
  }
  if (parsedValue < minAmount || parsedValue > maxAmount) {
    return 'Amount must be between $minAmount and $maxAmount PKR';
  }

  return null;
}

String formatDateTime(String inputDateTime, {bool roundMinutes = false}) {
  try {
    DateTime dateTime = DateFormat("yy-MM-dd HH:mm:ss").parse(inputDateTime);

    if (roundMinutes) {
      dateTime =
          DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour);
    }

    // Format the date-time to the desired output format
    return DateFormat("dd MMM yy h:mm a").format(dateTime);
  } catch (e) {
    return inputDateTime;
  }
}

String? validateMtag(String? value) {
  // Check if the value is null or empty
  if (value == null || value.isEmpty || value.length < 8 || value.length > 8) {
    return 'Enter 8 digit value'; // Localizable message for "Amount required"
  }
  return null;
}
String maskString(String value) {
  if (value.isEmpty || value == '') {
    return '';
  }

  if (value.length == 11 || value.length == 19) {
    return value.substring(value.length - 4);
  }

  return '';
}