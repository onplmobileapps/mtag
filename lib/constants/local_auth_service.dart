
import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuth {


  static final auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async =>
      await auth.canCheckBiometrics || await auth.isDeviceSupported();

  static Future<bool> authenticate() async {
    try {
      if (!await canAuthenticate()) return false;

      return await auth.authenticate(
        localizedReason: "Scan your fingerprint to proceed.",
        options: const AuthenticationOptions(
            biometricOnly: true, stickyAuth: true, useErrorDialogs: true
        ),
      );
    } catch (e) {
      debugPrint('error $e');
      return false;
    }
  }
}
