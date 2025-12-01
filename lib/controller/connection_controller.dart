import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ConnectionController extends GetxController {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  final RxBool _isConnected = true.obs;
  final RxBool _showGreenBanner = false.obs;

  bool get isConnected => _isConnected.value;
  bool get showGreenBanner => _showGreenBanner.value;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = !results.contains(ConnectivityResult.none);
      if (hasConnection != _isConnected.value) {
        _isConnected.value = hasConnection;
        _showGreenBanner.value = hasConnection;

        if (hasConnection) {
          Future.delayed(const Duration(seconds: 2), () {
            _showGreenBanner.value = false;
          });
        }
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    _isConnected.value = !results.contains(ConnectivityResult.none);
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
