import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/api/auth_controller.dart';
import 'package:mtag_flutterapp/constants/analytics.dart';
import '../../constants/input_formater.dart';
import '../../widgets/elevated_button.dart';
import '../../widgets/textform_widget.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final _nameFocusNode = FocusNode(), _cnicFocusNode = FocusNode(), _phoneFocusNode = FocusNode();
  final _nameController = TextEditingController(),
      _cnicController = TextEditingController(),
      _phoneController = TextEditingController();
  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Analytics.signupScreenDisplayed();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height / 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: Form(
                        key: _formKey,
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
                            const SizedBox(
                              height: 40,
                            ),
                            SvgPicture.asset(
                              'assets/signup.svg',
                              colorFilter: ColorFilter.mode(Theme.of(context).hintColor, BlendMode.srcIn),
                              fit: BoxFit.fill,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            const Center(
                              child: Text(
                                "Sign Up",
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
                              height: 10,
                            ),
                            CustomTExtField(
                              validator: (v) {
                                if (v!.isEmpty || v.length < 3) {
                                  return 'Enter valid name';
                                }
                                return null;
                              },
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
                              controller: _nameController, //..text = 'Najeeb U Allah'
                              focusNode: _nameFocusNode,
                              onEditingComplete: () => FocusScope.of(context).requestFocus(_cnicFocusNode),
                              label: 'Full Name',
                              keyboardType: TextInputType.name,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTExtField(
                              validator: (v) {
                                if (v!.isEmpty || v.length < 13) {
                                  return 'Enter valid cnic';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                              controller: _cnicController, //..text = "37405-5505272-5"
                              focusNode: _cnicFocusNode,
                              onEditingComplete: () => FocusScope.of(context).requestFocus(_phoneFocusNode),
                              inputFormatters: [
                                CnicMaskTextInputFormatter(),
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))
                              ],
                              label: 'CNIC',
                              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTExtField(
                              validator: (v) {
                                if (v!.isEmpty || !v.startsWith('03')) {
                                  return 'Enter Valid Phone Number';
                                }
                                return null;
                              },
                              maxLength: 11,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              controller: _phoneController, //..text = '03343433395'
                              focusNode: _phoneFocusNode,
                              onEditingComplete: () => FocusScope.of(context).unfocus(),
                              label: 'Phone Number',
                              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            ElevatedButton1(
                              backgroundColor: Theme.of(context).primaryColor,
                              width: MediaQuery.sizeOf(context).width,
                              onclick: () {
                                Analytics.signUpTapped();
                                if (_formKey.currentState!.validate()) {
                                  Get.find<AuthController>().registerUser(
                                      cnic: _cnicController.text.trim(),
                                      fullName: _nameController.text.trim(),
                                      mobileNumber: _phoneController.text.trim());
                                }
                              },
                              text: 'Sign Up',
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                Text('Already have an account?', style: Theme.of(context).textTheme.displaySmall),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    Analytics.signInOnSignUpPageTapped();
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      Get.offAndToNamed('/login');
                                    });
                                  },
                                  child: Text(
                                    'Sign In',
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
                    ),
                  ]),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
