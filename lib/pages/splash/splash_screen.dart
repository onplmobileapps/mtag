import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:in_app_update/in_app_update.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> checkForUpdates() async {
    try {
      final updateStatus = await InAppUpdate.checkForUpdate();

      if (updateStatus.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      // Handle any errors that occurred during the update check
      log('Error checking for updates: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) checkForUpdates();
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed('/pinPage');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset('assets/logolight.svg'),
      ),
    );
  }
}
