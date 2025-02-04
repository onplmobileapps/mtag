import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationUtil {
  static final AuthenticationUtil _instance = AuthenticationUtil._internal();
  AuthenticationUtil._internal();
  factory AuthenticationUtil() => _instance;
  static String formatedDate(DateTime? dateTime) {
    return intl.DateFormat('yyyy-MM-dd').parse('$dateTime').toString().replaceAll('00:00:00.000', '');
  }

  static String formatedDateToDD(DateTime? dateTime) {
    var f = intl.DateFormat('dd MMM yyyy HH:mm:ss');
    return f.format(dateTime!.toUtc());
  }

  static final auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async => await auth.canCheckBiometrics || await auth.isDeviceSupported();
  getauth() async {}

 static Future<bool> authenticate() async {
  var available = await auth.getAvailableBiometrics();
  log(available.toString());
  try {
    if (!await canAuthenticate()) return false;

    final result = await auth.authenticate(
      localizedReason: "Scan your fingerprint to proceed.",
      options: const AuthenticationOptions(stickyAuth: true, useErrorDialogs: true),
    );

    if (result) {
      return true;
    } else {
      log('User canceled authentication or it failed');
      return false;
    }
  } catch (e) {
    debugPrint('error $e');
    return false;
  }
}


  static Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.first == ConnectivityResult.mobile || connectivityResult.first == ConnectivityResult.wifi) {
      return true;
    }
    log('false internet');
    return false;
  }
}
