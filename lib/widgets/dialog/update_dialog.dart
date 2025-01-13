import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../elevated_button.dart';

void showUpdateDialog(String message) {
  Get.back();
  Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        contentPadding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
        surfaceTintColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.white,
        content: Text(
          message,
          style: const TextStyle(fontSize: 15, color: Colors.black, fontFamily: 'Poppins'),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton1(
            onclick: () {
              launchUrl(Uri.parse('https://apps.apple.com/us/app/m-tag-one-network/id1574366732'));
            },
            text: 'Update Now',
            backgroundColor: primarSwatch,
          )
        ],
      ));
}
