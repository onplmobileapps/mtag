import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

sealed class AppData {
  static late SharedPreferences _preferences;

  static SharedPreferences get preference => _preferences;

  static const _themeModeKey = 'theme-mode';

  static Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static bool? get theme => _preferences.getBool(_themeModeKey);
  static String? get fcmToken => _preferences.getString('fcm_token');

  static Future<bool> setThemeMode(bool? value) async {
    var result = false;
    if (value == null) {
      result = await _preferences.remove(_themeModeKey);
    } else {
      result = await _preferences.setBool(_themeModeKey, value);
    }
    // StatusBarUtils.changeBarColor();
    return result;
  }

  static setCount(int? val) {
    if (val != null) {
      var count = _preferences.getInt('app_count');
      if (count != null && count < 5) {
        count = 1 + count;
      }
      _preferences.setInt('app_count', count ?? 0);
      return;
    }
  }

  static int? getAppCount() {
    return _preferences.getInt('app_count');
  }

  static void setFcmToken(String fcmToken) async {
    log(fcmToken);
    await _preferences.setString('fcm_token', fcmToken);
  }

  static String? getFcmToken() {
    return _preferences.getString('fcm_token');
  }
 static Future<void> savePinData({Map<String, dynamic>? pinData}) async {
    if (pinData != null) {
      await _preferences.setString('pin_data', jsonEncode(pinData));
    }
  }
 static Future<void> clearPinData() async {
  if (_preferences.containsKey('pin_data')) {
    await _preferences.remove('pin_data');
  }
}

    static Map<String, dynamic>? getPinData() {
    final String? data = _preferences.getString('pin_data');
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }


  static String? getDeviceId() {
    return _preferences.getString('android_id');
  }

  static void setCNICNum(String cnic) async {
    await _preferences.setString('cnic_num', cnic);
  }

  static String? getCNICNum() {
    return _preferences.getString('cnic_num');
  }

  static void setMobileNum(String mobileNum) async {
    await _preferences.setString('mobile_num', mobileNum);
  }

  static String? getMobileNum() {
    return _preferences.getString('mobile_num');
  }
}
