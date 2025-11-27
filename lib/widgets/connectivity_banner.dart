import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/connection_controller.dart';


class ConnectionBanner extends StatelessWidget {
  final Widget child;

  const ConnectionBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConnectionController());

    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Obx(
                () => AnimatedSlide(
              offset: (!controller.isConnected || controller.showGreenBanner)
                  ? Offset.zero
                  : const Offset(0, -1),
              duration: const Duration(milliseconds: 300),
              child: AnimatedOpacity(
                opacity: (!controller.isConnected || controller.showGreenBanner)
                    ? 1.0
                    : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  height: 60,
                  color: controller.isConnected ? Colors.greenAccent.shade700 : Colors.redAccent.shade700,
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    controller.isConnected
                        ? 'Back Online'
                        : 'No Internet Connection',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      decoration: TextDecoration.none,
                    ),
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