
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showPopDialog(String message, Function()? onPressed) {
  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (context) => PopScope(
      canPop: false,
      child: AlertDialog.adaptive(
        content: Text(message),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                if (onPressed != null) {
                  onPressed();
                } else {
                  Get.back();
                }
              },
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    ),
  );
}
