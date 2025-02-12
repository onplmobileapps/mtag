import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

void showPopDialog(String message, Function()? onPressed) {
  showCupertinoModalPopup(
    barrierDismissible: false,
    useRootNavigator: true,
    context: Get.context!,
    builder: (context) => PopScope(
      canPop: false,
      child: CupertinoAlertDialog(
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
            child: const Text('Ok'),
          ),
        ],
      ),
    ),
  );
}
