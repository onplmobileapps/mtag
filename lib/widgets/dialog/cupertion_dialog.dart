import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

void showPopDialog(String message, Function()? onPressed) {
  final context = Get.overlayContext ?? Get.context;
  if (context == null) return;

  showCupertinoModalPopup<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => CupertinoAlertDialog(
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          onPressed:onPressed,
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
