import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';

import '../constants/other_consts.dart';

class FirebaseRemoteConfigService {
  FirebaseRemoteConfigService._()
      : _remoteConfig = FirebaseRemoteConfig.instance; // MODIFIED

  static FirebaseRemoteConfigService? _instance; // NEW
  factory FirebaseRemoteConfigService() =>
      _instance ??= FirebaseRemoteConfigService._(); // NEW
  final _otherConstants = OtherConsts();
  final FirebaseRemoteConfig _remoteConfig;
  RemoteConfigSettings configSettings = RemoteConfigSettings(
    minimumFetchInterval: const Duration(seconds: 0),
    fetchTimeout:
    const Duration(seconds: 10), // Set the cache duration to 30 sec
  );
  Future<void> fetchRemoteConfig() async {
    try {
  
      await _remoteConfig.ensureInitialized();
      await _remoteConfig.fetch();
      await _remoteConfig.activate();
      await _remoteConfig.fetchAndActivate();
      await _remoteConfig.setConfigSettings(configSettings);
      await _remoteConfig.setDefaults({
        'enableMaintenceMood': 'false',
      });

      var val = _remoteConfig.getValue("enableMaintenceMood");
      _otherConstants.emergencySwitchProd.value =
          _remoteConfig.getValue('emergency_switch_prod').asString();
      _otherConstants.emergencySwitchDebug.value =
          _remoteConfig.getValue('emergency_switch_debug').asString();
      _otherConstants.discountText.value =
          _remoteConfig.getValue('promotional_message').asString();
      _otherConstants.promoPopUp.value =
          _remoteConfig.getValue("promo_popup").asString();
      log(' Prod--->${_otherConstants.emergencySwitchProd} Debugg-->${_otherConstants.emergencySwitchDebug}');

      log(val.asString().toString());
      if (val.asBool() == true) {
        Get.offAndToNamed('/maintenancePage');
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}