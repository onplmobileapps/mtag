import 'package:connectivity_plus/connectivity_plus.dart';
// ignore: library_prefixes
import 'package:dio/dio.dart' as apiClient;

import '../api/api_constants.dart';

class ConnectionCheck {
  static DateTime? _lastCheck;
  static bool _lastStatus = true;

  static Future<Map<String, dynamic>> isConnected({bool force = false}) async {
    if (!force && _lastCheck != null && 
        DateTime.now().difference(_lastCheck!) < const Duration(seconds: 60)) {
      return _lastStatus
          ? {APIRESPONSE.SUCCESS: {'Message': 'Stable internet'}}
          : {APIRESPONSE.ERROR: {'Message': 'No internet'}};
    }

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      _lastStatus = false;
      _lastCheck = DateTime.now();
      return {APIRESPONSE.ERROR: {'Message': 'No internet'}};
    }

    try {
      final result = await apiClient.Dio()
          .get('https://www.google.com')
          .timeout(const Duration(seconds: 3)); // reduce timeout
      _lastStatus = result.statusCode == 200;
    } catch (_) {
      _lastStatus = false;
    }

    _lastCheck = DateTime.now();
    return _lastStatus
        ? {APIRESPONSE.SUCCESS: {'Message': 'Stable internet'}}
        : {APIRESPONSE.ERROR: {'Message': 'No internet'}};
  }
}

