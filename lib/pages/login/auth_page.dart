import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_actions/keyboard_actions.dart'; // Add this import
import '../../api/auth_controller.dart';
import '../../constants/input_formater.dart';
import '../../utils/utils.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  final _userName = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final ValueNotifier<int> _authNotifier = ValueNotifier<int>(0);
  final _formKey = GlobalKey<FormState>();

  // Focus nodes for keyboard actions
  final _cnicFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  // Keyboard actions configuration
  KeyboardActionsConfig _buildKeyboardConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS, // Target iOS only
      keyboardBarColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[200]
          : Colors.grey[800],
      nextFocus: false, // Prevent focus jumping
      actions: [
        KeyboardActionsItem(
          focusNode: _cnicFocusNode,
          toolbarButtons: [
            (node) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                    onPressed: () => node.unfocus(),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          ],
        ),
        KeyboardActionsItem(
          focusNode: _phoneFocusNode,
          toolbarButtons: [
            (node) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                    onPressed: () => node.unfocus(),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        return Material(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.09,
            ),
            child: KeyboardActions(
              config: _buildKeyboardConfig(
                  context), // Wrap entire column with KeyboardActions
              child: ValueListenableBuilder(
                valueListenable: _authNotifier,
                builder: (context, value, child) => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.12),
                    Center(
                      child: SvgPicture.asset(
                        'assets/logolight.svg',
                        height: screenWidth * 0.13,
                        width: screenWidth * 0.13,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.06),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            _authNotifier.value = 0;
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign In',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: value == 0
                                  ? colorScheme.primary
                                  : colorScheme.secondary,
                            ),
                          ),
                        ),
                        Container(
                          height: screenHeight * 0.018,
                          width: screenWidth * 0.003,
                          color: colorScheme.secondary,
                          margin: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02),
                        ),
                        TextButton(
                          onPressed: () {
                            _authNotifier.value = 1;
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign Up',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: value == 1
                                  ? colorScheme.primary
                                  : colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.06),
                    Text(
                      'Welcome \nto the M-TAG One Network',
                      style: theme.textTheme.displayLarge?.copyWith(
                        wordSpacing: screenWidth * 0.01,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (value == 1)
                            TextFormField(
                              keyboardType: TextInputType.text,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[A-Za-z ]")),
                              ],
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              style: const TextStyle(height: 1),
                              controller: _userName,
                              decoration:
                                  const InputDecoration(hintText: 'Full Name'),
                              validator: (v) {
                                if (value == 1 &&
                                    (v == null || v.isEmpty || v.length < 3)) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                          SizedBox(height: screenHeight * 0.02),
                          TextFormField(
                            focusNode: _cnicFocusNode, // Assign focus node
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                            decoration: const InputDecoration(
                              hintText: 'CNIC',
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          TextFormField(
                            focusNode: _phoneFocusNode, // Assign focus node
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.number,
                            // textInputAction: TextInputAction.done,
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
                            decoration: const InputDecoration(
                              hintText: 'Mobile Number',
                              counterText: "",
                            ),
                            onEditingComplete: () =>
                                FocusScope.of(context).unfocus(),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  var release =
                                      await DeviceInfo.getDeviceInfo();
                                  if (value == 0) {
                                    Get.find<AuthController>().login(
                                      cnic: _cnicController.text.trim(),
                                      mobileNumber:
                                          _phoneController.text.trim(),
                                      metaData:
                                          '"${Platform.isAndroid ? "Android" : 'iOS'} ""__"${release['release']} "__"${release['manufacturer']}""${release['model']} "__"android_id"__"fcmToken"__"3.1.4"',
                                    );
                                    return;
                                  } else {
                                    Get.find<AuthController>().registerUser(
                                      cnic: _cnicController.text,
                                      mobileNumber: _phoneController.text,
                                      fullName: _userName.text,
                                    );
                                  }
                                }
                              },
                              child: CircleAvatar(
                                radius: 25,
                                child: Icon(
                                  Icons.keyboard_arrow_right_outlined,
                                  color: colorScheme.scrim,
                                  size: 25,
                                ),
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
          ),
        );
      },
    );
  }
}
