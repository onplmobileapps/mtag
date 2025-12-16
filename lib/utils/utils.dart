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
  static Future<Map<String, dynamic>> getDeviceInfo() async {
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
  static void requestAppReview() {
    if (Platform.isAndroid) {
      _android();
    } else if (Platform.isIOS) {
      _ios();
    }
  }

  /// ✅ ANDROID — fire & forget (NO await)
  static void _android() {
    final review = InAppReview.instance;

    Future.delayed(const Duration(milliseconds: 300), () {
      try {
        review.requestReview(); // ❗ DO NOT await
      } catch (_) {
        review.openStoreListing();
      }
    });
  }

  /// ✅ IOS — safe to await
  static Future<void> _ios() async {
    final review = InAppReview.instance;
    if (!await review.isAvailable()) return;

    await Future.delayed(const Duration(milliseconds: 300));
    await review.requestReview();
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
      log('Error checking for updates: $e');
    }
  }
}

void startTimer(ValueNotifier<Duration> timerNotifier) {
  Timer.periodic(Duration(seconds: 1), (timer) {
    if (timerNotifier.value > Duration.zero) {
      timerNotifier.value -= Duration(seconds: 1);
    } else {
      timer.cancel();
    }
  });
}

String? validateJazzcashNumber(String? number) {
  if (number == null) {
    return 'Please enter valid jazzcash number';
  } else if (!number.startsWith('03')) {
    return 'Please enter 03XXXXXXXXX format Jazzcah Cash Number';
  } else if (number.length < 11) {
    return 'Please enter your 11 digit jazzcash number';
  }
  return null;
}

String? validateAmount(String? value) {
  if (value == null) {
    return 'Amount is required';
  }
  if (value.isEmpty) {
    return 'Amount is required';
  }

  final parsedValue = int.tryParse(value);
  if (parsedValue == null) {
    return 'Amount must be a valid integer';
  }

  final homeController = Get.find<HomeController>();
  final minAmount = int.tryParse(
    '${homeController.dashboradData.value.rechargeMinAmount}',
  );
  final maxAmount = int.tryParse(
    '${homeController.dashboradData.value.rechargeMaxAmount}',
  );

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
    DateTime dateTime = DateFormat("dd-MM-yy HH:mm:ss").parse(inputDateTime);

    if (roundMinutes) {
      dateTime = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
      );
    }

    // Format the date-time to the desired output format
    return DateFormat("dd MMM yy - h:mm a").format(dateTime);
  } catch (e) {
    return inputDateTime;
  }
}

String? validateMtag(String? value) {
  if (value == null) {
    return 'MTAG value cannot be null';
  }
  if (value.isEmpty) {
    return 'MTAG value is required';
  }
  if (value.length < 8) {
    return 'MTAG must be at least 8 digits';
  }
  if (value.startsWith('0')) {
    return 'MTAG cannot start with 0';
  }
  return null; // Valid input
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
final List<Map<String, dynamic>> operatorList = [
    {
      'text': 'Jazz',
      'value': 1,
      'image': 'assets/jazz-logo-1.png',
      'prefixes': [
        '0300',
        '0301',
        '0302',
        '0303',
        '0304',
        '0306',
        '0307',
        '0308',
        '0309',
      ],
    },
    {
      'text': 'Telenor',
      'value': 2,
      'image': 'assets/telenor.jpg',
      'prefixes': [
        '0340',
        '0341',
        '0342',
        '0343',
        '0344',
        '0345',
        '0346',
        '0347',
        '0348',
        '0349',
      ],
    },
    {
      'text': 'Ufone',
      'value': 3,
      'image': 'assets/ufone.png',
      'prefixes': [
        '0330',
        '0331',
        '0332',
        '0333',
        '0334',
        '0335',
        '0336',
        '0337',
        '0338',
      ],
    },
    {
      'text': 'Zong',
      'value': 5,
      'image': 'assets/zong.png',
      'prefixes': [
        '0310',
        '0311',
        '0312',
        '0313',
        '0314',
        '0315',
        '0316',
        '0317',
        '0318',
        '0319',
      ],
    },
    {
      'text': 'Warid',
      'value': 4,
      'image': 'assets/warid.png',
      'prefixes': [
        '0320',
        '0321',
        '0322',
        '0323',
        '0324',
        '0325',
        '0327',
        '0328',
        '0329',
      ],
    },
    {
      'text': 'SCO',
      'value': 6,
      'image': 'assets/sco.webp',
      'prefixes': ['0355'],
    },
  ];


