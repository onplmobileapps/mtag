import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../api/auth_controller.dart';
import '../../constants/analytics.dart';
import '../../pages/otp/sms_retriever.dart';
import 'package:smart_auth/smart_auth.dart';
import '../../base/app_data.dart';
import '../../constants/call_helper.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});
  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _pinputController = TextEditingController();
  final _focusNode = FocusNode();
  late Timer timer;
  late final SmsRetriever smsRetriever;
  int secondsRemaining = 60;
  bool timerComplete = false;
  Map<String, dynamic> args = Get.arguments;

  @override
  void initState() {
    super.initState();
    startTimer();
    smsRetriever = SmsRetrieverImpl(
SmartAuth()
    );
  }

  @override
  void dispose() {
    timer.cancel();
    _pinputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          timerComplete = true;
          timer.cancel();
        }
      });
    });
  }

  String getFormattedTime() {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void resetTimer() {
    setState(() {
      timerComplete = false;
      secondsRemaining = 60;
      startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).height / 10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Center(
                child: SvgPicture.asset(
                  'assets/logolight.svg',
                  height: 50,
                  width: 50,
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              Center(
                child: Text(
                  'OTP Verification',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('OTP has been sent to'),
                  Text(
                    ' +92${int.tryParse(args['mobileNum'])}',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              Text(
                'Enter Your PIN',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(
                height: 30,
              ),
              Pinput(
                smsRetriever: smsRetriever,
                // androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
                // listenForMultipleSmsOnAndroid: true,
                hapticFeedbackType: HapticFeedbackType.lightImpact,
                autofocus: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onCompleted: (value) {
                  Get.find<AuthController>().verifyOTP(value, int.parse('${args['loginKey']}'));
                  AppData.setCNICNum(args['cnic']);
                  AppData.setMobileNum(args['mobileNum']);
                },
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Enter Valid OTP';
                  }
                  return null;
                },
                focusNode: _focusNode,
                controller: _pinputController,
                focusedPinTheme: PinTheme(
                  textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 18),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor,
                    border: Border.all(color: Colors.black12, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                disabledPinTheme: PinTheme(
                  textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 18),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.black12, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                defaultPinTheme: PinTheme(
                  textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 18),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.black12, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                length: 6,
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getFormattedTime(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[500]),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    InkWell(
                      onTap: () async {
                        await Get.find<AuthController>().resendOTP(cnic: args['cnic'], islogin: args['loginKey']);
                        _pinputController.clear();
                        timerComplete ? resetTimer() : null;
                        Analytics.resendVerificationCodeTapped();
                      },
                      child: Text('Resend OTP',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: timerComplete ? Theme.of(context).primaryColor : Colors.grey[500])),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                'Didn\'t receive yet?',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(
                height: 15,
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: 'Please Call ', style: Theme.of(context).textTheme.labelMedium),
                    TextSpan(
                      recognizer: TapGestureRecognizer()..onTap = () async => await CallWhatsappUtil.openCall1313(),
                      text: '1313',
                      style: const TextStyle(
                        color: Colors.red,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
