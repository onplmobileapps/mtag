import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../constants/other_consts.dart';
import 'elevated_button.dart';

class JazzResponseDialog extends StatelessWidget {
  final String? message;
  final Color? color;
  final bool isSuccess;
  final String? lottiepath;

  const JazzResponseDialog({
    super.key,
    required this.message,
    required this.isSuccess,
    required this.color,
    this.lottiepath,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: ColorScheme.of(context).surface,
      surfaceTintColor:  ColorScheme.of(context).surfaceTint,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              isSuccess ? 'assets/lottie/done_new.json' : 'assets/lottie/cancel_1.json',
              height: 70,
            ),
            const SizedBox(height: 10),
            Text(
              message ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton1(
              backgroundColor: color,
              width: 100,
              onclick: () async {
                OtherConsts().isRefresh(isSuccess);
                Get.back(); // Close the dialog
                // Replace the entire stack with /dashboard to clear previous routes
                await Get.offAllNamed('/dashboard');
              },
              text: 'Ok',
            ),
          ],
        ),
      ),
    );
  }
}
Future<void> jazzLoader() {
  return showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor:  ColorScheme.of(context).surface,surfaceTintColor:  ColorScheme.of(context).surfaceTint,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: PopScope(
          onPopInvokedWithResult: (didPop, _) {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/jazzcash.png',
                height: 70,
                cacheHeight: 150,
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 20,
                width: 20,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    semanticsValue: '2323',
                    backgroundColor: Colors.grey,
                    color: Colors.white.withAlpha( 80),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Please wait',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Please verify your MPIN Once MPIN\n will be verified your transaction will\n be completed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}