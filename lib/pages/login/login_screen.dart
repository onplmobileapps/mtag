import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '/api/auth_controller.dart';
import '/base/app_data.dart';
import '/constants/analytics.dart';
import '/utils/utils.dart';
import '../../constants/auth_utils.dart';
import '../../constants/input_formater.dart';
import '../../widgets/elevated_button.dart';
import '../../widgets/textform_widget.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
   LoginScreen({super.key});
  static final _formKey1 = GlobalKey<FormState>();
  final _cnicFocusNode = FocusNode(), _phoneFocusNode = FocusNode();
  final _cnicControler = TextEditingController(), _phoneController = TextEditingController();
  var isFleet = Rx<bool>(false);
  @override
  Widget build(BuildContext context) {
    Analytics.loginScreenDisplayed();

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: CustomScrollView(shrinkWrap: true,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverList(
                      delegate: SliverChildListDelegate([
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height / 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: SvgPicture.asset(
                              'assets/logolight.svg',
                              height: MediaQuery.sizeOf(context).height / 20,
                              width: MediaQuery.sizeOf(context).width / 4,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height / 20,
                          ),
                          SvgPicture.asset(
                            'assets/login.svg',
                            height: MediaQuery.sizeOf(context).height / 5,
                            width: MediaQuery.sizeOf(context).width,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(
                            height: 20,
                          ), 
                          const Center(
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Color(0xffe73b3e),
                                height: 30 / 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Center(
                            child: Text(
                              'Enter your registered CNIC & Mobile Number to Sign In.',
                              style: Theme.of(context).textTheme.displaySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Form(
                            key: _formKey1,
                            child: Column(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 30,
                                ),
                                CustomTExtField(
                                  maxLines: 1,
                                  key: Key('cnic'),
                                  textInputAction: TextInputAction.next,
                                  controller: _cnicControler,
                                  validator: (v) {
                                    if (v!.isEmpty || v.length < 15 || v.contains('--')) {
                                      return 'Enter valid CNIC';
                                    }
                                    return null;
                                  },
                                  // onTapOutside: (p0) {
                                  //   FocusScope.of(context).unfocus();
                                  // },
                                  inputFormatters: [
                                    CnicMaskTextInputFormatter(),
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))
                                  ],
                                  onEditingComplete: () => FocusScope.of(context).requestFocus(_phoneFocusNode),
                                  focusNode: _cnicFocusNode,
                                  label: 'CNIC',
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: false,
                                    signed: true,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomTExtField(
                                  key:  Key('Phone'),
                                  textInputAction: TextInputAction.done,
                                  // ..text = '03115042001'
                                  controller: _phoneController,
                                  validator: (v) {
                                    if (v!.isEmpty || !v.startsWith('03') || v.length < 11) {
                                      return 'Enter valid Phone number';
                                    }
                                    return null;
                                  },
                                  maxLength: 11,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))],
                                  onEditingComplete: () => FocusScope.of(context).unfocus(),
                                  focusNode: _phoneFocusNode,
                                  label: 'Phone Number',
                                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                              ],
                            ),
                          ),
                          IntrinsicWidth(
                            child: Row(
                              children: [
                                Flexible(
                                  child: ElevatedButton1(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    width: MediaQuery.sizeOf(context).width,
                                    onclick: () async {
                                      Analytics.signInTapped();
      
                                      var release = await DeviceInfo.getDeviceInfo();
                                      log('$release');
                                      if (_formKey1.currentState!.validate()) {
                                        await Get.find<AuthController>().login(
                                          cnic: _cnicControler.text.trim(),
                                          mobileNumber: _phoneController.text.trim(),
                                          metaData:
                                              '"${Platform.isAndroid ? "Android" : 'iOS'} ""__"${release['release']} "__"${release['manufacturer']}""${release['model']} "__"android_id"__"fcmToken"__"3.1.4',
                                        );
                                      }
                                    },
                                    text: 'Sign In',
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                IconButton.filled(
                                    style: IconButton.styleFrom(
                                        backgroundColor: const Color(0xFF2C2E65),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                    onPressed: () async {
                                      var release = await DeviceInfo.getDeviceInfo();
                                      var cnic = AppData.getCNICNum();
                                      var mobile = AppData.getMobileNum();
                                      if (cnic == null && mobile == null) {
                                        showCupertinoModalPopup(
                                            context: Get.context!,
                                            builder: (_) => CupertinoAlertDialog(
                                                  content: Text(
                                                    'Sign in with your CNIC and mobile to set up biometrics. After that, use the biometric icon to log in.',
                                                    style: Theme.of(context).textTheme.displaySmall,
                                                  ),
                                                  actions: [
                                                    CupertinoDialogAction(
                                                      onPressed: Get.back,
                                                      child: const Text('Ok'),
                                                    )
                                                  ],
                                                ));
                                      } else if (await AuthenticationUtil.authenticate()) {
                                        await Get.find<AuthController>().login(
                                            cnic: AppData.getCNICNum().toString(),
                                            mobileNumber: AppData.getMobileNum().toString(),
                                            metaData:
                                                '"${Platform.isAndroid ? "Android" : 'iOS'} ""__"${release['release']} "__"${release['manufacturer']}""${release['model']} "__"android_id"__"fcmToken"__"3.1.3');
                                      }
                                    },
                                    icon: Platform.isAndroid
                                        ? const Icon(
                                            Icons.fingerprint,
                                            color: Colors.white,
                                          )
                                        : const Icon(
                                            Icons.face,
                                            color: Colors.white,
                                          ))
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child:
                                    Text('Don\'t have an account yet?', style: Theme.of(context).textTheme.displaySmall),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              InkWell(
                                onTap: () {
                                  Analytics.signUpOnLoginPageTapped();
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    Get.offAndToNamed('/signUp');
                                  });
                                },
                                child: Text(
                                  'Sign Up',
                                  style: Theme.of(context).textTheme.displayMedium,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                    ),
                  ]))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
