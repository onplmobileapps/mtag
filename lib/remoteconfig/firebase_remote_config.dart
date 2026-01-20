import 'dart:developer';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import '../constants/other_consts.dart';

class FirebaseRemoteConfigService {
  FirebaseRemoteConfigService._()
      : _remoteConfig = FirebaseRemoteConfig.instance;

  static FirebaseRemoteConfigService? _instance;
  factory FirebaseRemoteConfigService() =>
      _instance ??= FirebaseRemoteConfigService._();

  final FirebaseRemoteConfig _remoteConfig;
  final OtherConsts _otherConstants = OtherConsts();

  final RemoteConfigSettings _configSettings = RemoteConfigSettings(
    minimumFetchInterval: Duration(minutes: 10), // PROD SAFE
    fetchTimeout: Duration(seconds: 10),
  );

  /// 🔒 PROD SAFE — NEVER THROWS
  Future<void> fetchRemoteConfig() async {
    try {
      // 1️⃣ Settings first
      await _remoteConfig.setConfigSettings(_configSettings);

      // 2️⃣ Defaults (prevents nulls)
      await _remoteConfig.setDefaults({
        'enableMaintenceMood': false,
        'emergency_switch_prod': 'false',
        'emergency_switch_debug': 'false',
        'promotional_message': '',
        'promo_popup': 'false',
      });

      // 3️⃣ Init
      await _remoteConfig.ensureInitialized();

      // 4️⃣ Fetch + activate (safe even offline)
      await _remoteConfig.fetchAndActivate();

      // 5️⃣ Read values
      final bool maintenance =
      _remoteConfig.getBool('enableMaintenceMood');

      _otherConstants.emergencySwitchProd.value =
          _remoteConfig.getString('emergency_switch_prod');
      _otherConstants.emergencySwitchDebug.value =
          _remoteConfig.getString('emergency_switch_debug');
      _otherConstants.discountText.value =
          _remoteConfig.getString('promotional_message');
      _otherConstants.promoPopUp.value =
          _remoteConfig.getString('promo_popup');

      log(
        'RemoteConfig OK | '
            'maint=$maintenance | '
            'prod=${_otherConstants.emergencySwitchProd.value}',
      );

      // 6️⃣ Maintenance routing (non-fatal)
      if (maintenance) {
        Get.offAllNamed('/maintenancePage');
      }
    } catch (e, s) {
      // ❌ NEVER crash app for RemoteConfig
      log(
        'RemoteConfig failed (non-fatal): $e',
        stackTrace: s,
      );
    }
  }
}
