import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
// ignore: library_prefixes
import 'package:dio/dio.dart' as apiClient;

import 'package:mtag_flutterapp/api/api_constants.dart';

sealed class ConnectionCheck {
  static Future<Map<String, dynamic>> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    log(connectivityResult.toList().toString());
    if ((connectivityResult.contains(ConnectivityResult.mobile) &&
            connectivityResult.contains(ConnectivityResult.vpn)) ||
        (connectivityResult.contains(ConnectivityResult.wifi) 
        && connectivityResult.contains(ConnectivityResult.vpn)
        )) {
      return {
        APIRESPONSE.ERROR: {'Message': 'Please disable vpn in order to use app'}
      };
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      return {
        APIRESPONSE.ERROR: {'Message': 'Check your internet connection & try again'}
      };
    } else {
      try {
        final result = await apiClient.Dio().get('https://www.google.com').timeout(const Duration(seconds: 15));
        if (result.statusCode == 200) {
          return {
            APIRESPONSE.SUCCESS: {'Message': 'Stable internet'}
          };
        }
      } catch (e) {
        return {
          APIRESPONSE.ERROR: {'Message': 'Try again later'}
        };
      }
    }
    return {};
  }
}
