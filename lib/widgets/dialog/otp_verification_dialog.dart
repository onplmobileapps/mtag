import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import '../../constants/call_helper.dart';
import 'operator_selection_dialog.dart';

class OtpVerificationDialog extends StatelessWidget {
  final Function(String otp) onOtpSubmit;
  final Function(int? operatorId) onResendOtp;
  final String? mobileNumber, cnic;

  OtpVerificationDialog({
    super.key,
    required this.onOtpSubmit,
    required this.onResendOtp,
    this.mobileNumber,
    this.cnic,
  });

  final ValueNotifier<int> _secondsRemainingNotifier = ValueNotifier<int>(120);

  static void _startTimer(ValueNotifier<int> secondsRemainingNotifier) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemainingNotifier.value > 0) {
        secondsRemainingNotifier.value -= 1;
      } else {
        timer.cancel();
      }
    });
  }

  void _resetTimer() {
    _secondsRemainingNotifier.value = 120;
    _startTimer(_secondsRemainingNotifier);
  }

  @override
  Widget build(BuildContext context) {
    _startTimer(_secondsRemainingNotifier);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Image.asset(
                          'assets/padlock.png',
                          height: 64,
                          width: 64,
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: Text(
                            'OTP Verification',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'OTP has been sent to',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: const Color(0xff6C7278)),
                              ),
                              Text(
                                ' $mobileNumber',
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: "Wrong phone number? ",
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Edit",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Pinput(
                          closeKeyboardWhenCompleted: true,
                          length: 6,
                          defaultPinTheme: PinTheme(
                            width: 45,
                            height: 45,
                            textStyle: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontSize: 20,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 1.5,
                              ),
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 45,
                            height: 45,
                            textStyle: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontSize: 22,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                          submittedPinTheme: PinTheme(
                            width: 45,
                            height: 45,
                            textStyle: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontSize: 20,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 1.5,
                              ),
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                          errorPinTheme: PinTheme(
                            width: 45,
                            height: 45,
                            textStyle: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.error,
                                width: 2,
                              ),
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                          pinAnimationType: PinAnimationType.scale,
                          keyboardType: TextInputType.number,
                          showCursor: true,
                          onCompleted: onOtpSubmit,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 30),
                              ValueListenableBuilder<int>(
                                valueListenable: _secondsRemainingNotifier,
                                builder: (context, seconds, child) {
                                  final isTimerComplete = seconds <= 0;
                                  return InkWell(
                                    onTap: isTimerComplete
                                        ? () {
                                            OperatorSelectionDialog.show(
                                              context,
                                              (value) {},
                                              mobileNumber: mobileNumber ?? '',
                                              onResendOtp: (value) =>
                                                  onResendOtp(value),
                                              onResetTimer: () => _resetTimer(),
                                            );
                                          }
                                        : null,
                                    child: Text(
                                      'Send again in',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: isTimerComplete
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey[500],
                                          ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 5),
                              ValueListenableBuilder<int>(
                                valueListenable: _secondsRemainingNotifier,
                                builder: (context, seconds, child) {
                                  final minutes = seconds ~/ 60;
                                  final remainingSeconds = seconds % 60;
                                  final formattedTime =
                                      '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
                                  return Text(
                                    formattedTime,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 16.0,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 1.5,
                                ),
                            children: <InlineSpan>[
                              TextSpan(
                                text: 'OTP not received? Call ',
                                style: Theme.of(
                                  context,
                                ).textTheme.displayMedium,
                              ),
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async =>
                                      await CallWhatsappUtil.openCall1313(),
                                text: '1313',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text: ' or ',
                                style: Theme.of(
                                  context,
                                ).textTheme.displayMedium,
                              ),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () async =>
                                      await CallWhatsappUtil.openWhatsAppChat(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/whatsapp.png',
                                        width: 20.0,
                                        height: 20.0,
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        'WhatsApp',
                                        style: TextStyle(
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -8,
                  right: -8,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
