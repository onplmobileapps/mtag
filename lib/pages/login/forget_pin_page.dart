import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/auth_controller.dart';
import '../../constants/input_formater.dart';
import '../../widgets/elevated_button.dart';
import '../../utils/utils.dart';

class ForgetPinPage extends StatelessWidget {
  ForgetPinPage({super.key});

  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final ValueNotifier<int> _authNotifier = ValueNotifier<int>(0);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        return Material(
          child: ValueListenableBuilder(
            valueListenable: _authNotifier,
            builder: (context, value, child) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight / 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.arrow_back_ios_outlined),
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.09),
                  child: Text(
                    'Forgot Login PIN',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.09),
                  child: Text(
                    'Verify your information to reset your login PIN',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.09,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (value == 1) SizedBox(height: screenHeight * 0.02),

                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.number,
                          inputFormatters: [CnicMaskTextInputFormatter()],
                          style: const TextStyle(height: 1),
                          validator: (v) {
                            if (v == null || v.isEmpty || v.length < 15) {
                              return 'Please enter your CNIC';
                            }
                            return null;
                          },
                          controller: _cnicController,
                          decoration: InputDecoration(hintText: 'CNIC'),
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          inputFormatters: numberInputFormatters,
                          maxLength: 11,
                          validator: (v) {
                            if (v == null ||
                                v.isEmpty ||
                                !v.startsWith('03') ||
                                v.length < 11) {
                              return 'Please enter your mobile number';
                            }
                            return null;
                          },
                          style: const TextStyle(height: 1),
                          controller: _phoneController,
                          decoration: InputDecoration(
                            hintText: 'Mobile Number',
                            counterText: "",
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.04),
                        ElevatedButton1(
                          onclick: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              var release = await DeviceInfo.getDeviceInfo();
                              Get.find<AuthController>().login(
                                cnic: _cnicController.text.trim(),
                                mobileNumber: _phoneController.text.trim(),
                                isForgetPin: 1,
                                metaData:
                                    '"${Platform.isAndroid ? "Android" : 'iOS'} ""__"${release['release']} "__"${release['manufacturer']}""${release['model']} "__"android_id"__"fcmToken"__"3.1.4',
                              );
                            }
                          },
                          text: 'Reset PIN',
                          width: double.infinity,
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
