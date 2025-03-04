import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

void showPopDialog(String message, Function()? onPressed) {
  showCupertinoModalPopup(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      return CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              if (onPressed != null) {
                onPressed();
              } else {
                Get.back();
              }
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
