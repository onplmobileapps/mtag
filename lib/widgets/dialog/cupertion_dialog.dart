import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

void showPopDialog(String message, Function()? onPressed) {
  showCupertinoModalPopup(
    barrierDismissible: false,
    useRootNavigator: false,
    context: Get.context!,
    builder: (context) => PopScope(
      canPop: false,
      child: CupertinoAlertDialog(
        actions: [
          CupertinoDialogAction(
            onPressed: onPressed,
            child: const Text('Ok'),
          )
        ],
        content: Text(message),
      ),
    ),
  );
}
