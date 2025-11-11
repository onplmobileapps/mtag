import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showPopDialog(
  String message,
  Function()? onPressed, {
  bool otpVerificationError = false,
}) {
  final context = Get.overlayContext ?? Get.context;
  if (context == null) return;

  showCupertinoModalPopup<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => CupertinoAlertDialog(
      content: DefaultTextStyle(
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).primaryColorLight,
        ),
        child: Text(message, textAlign: TextAlign.justify),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () {
            if (otpVerificationError) {
              Navigator.of(dialogContext).pop();
            }
            if (onPressed != null) onPressed();
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
