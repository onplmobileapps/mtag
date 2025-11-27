import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectionBanner extends StatefulWidget {
  final Widget child;

  const ConnectionBanner({super.key, required this.child});

  @override
  State<ConnectionBanner> createState() => _ConnectionBannerState();
}

class _ConnectionBannerState extends State<ConnectionBanner> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isConnected = true;
  bool _showGreenBanner = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = !results.contains(ConnectivityResult.none);
      if (hasConnection != _isConnected) {
        setState(() {
          _isConnected = hasConnection;
          _showGreenBanner = hasConnection;
        });
        if (hasConnection) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _showGreenBanner = false;
              });
            }
          });
        }
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = !results.contains(ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSlide(
            offset: (!_isConnected || _showGreenBanner) ? Offset.zero : const Offset(0, -1),
            duration: const Duration(milliseconds: 300),
            child: AnimatedOpacity(
              opacity: (!_isConnected || _showGreenBanner) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(

                height: Platform.isIOS ? 60 :20,
                color: _isConnected ? Colors.green : Colors.red,
                alignment: Alignment.bottomCenter,
                child: Text(
                  _isConnected ? 'Back Online' : 'No Internet Connection',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

