import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/widgets/custom_keyboard_actions.dart';
import 'package:mtag_flutterapp/widgets/elevated_button.dart';
import 'package:mtag_flutterapp/widgets/footer_widget.dart';
import '../../api/auth_controller.dart';
import '../../constants/input_formater.dart';
import '../../utils/utils.dart';
import 'controller/auth_page_controller.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  final controller = Get.put(AuthPageController());
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final mainContent = LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Obx(
            () => Padding(
              padding: EdgeInsets.symmetric(
                vertical: 26,
                horizontal: screenWidth * 0.05,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.12),
                          Center(
                            child: Image(
                              image: AssetImage(
                                isDarkMode
                                    ? 'assets/darklogo.png'
                                    : 'assets/logolight.png',
                              ),
                              height: 60.0,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.06),
                          SizedBox(height: screenHeight * 0.02),
                          Form(
                            key: formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (controller.authIndex.value == 1) ...[
                                  Text(
                                    'Full Name',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp("[A-Za-z ]"),
                                      ),
                                    ],
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    style: const TextStyle(height: 1),
                                    focusNode: controller.fullNameFocusNode,
                                    controller: controller.userName,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                      hintText: 'Full Name',
                                    ),
                                    validator: (v) {
                                      if (controller.authIndex.value == 1 &&
                                          (v == null ||
                                              v.isEmpty ||
                                              v.length < 3)) {
                                        return 'Please enter your full name';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                                SizedBox(height: screenHeight * 0.02),

                                Text(
                                  'CNIC',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                SizedBox(height: screenHeight * 0.004),
                                TextFormField(
                                  style: TextStyle(height: 1),
                                  focusNode: controller.cnicFocusNode,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    CnicMaskTextInputFormatter(),
                                  ],

                                  validator: (v) {
                                    if (v == null ||
                                        v.isEmpty ||
                                        v.length < 15) {
                                      return 'Please enter your CNIC';
                                    }
                                    return null;
                                  },
                                  controller: controller.cnicController,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.credit_card_outlined,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    hintText: 'CNIC',
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  'Phone Number',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                SizedBox(height: screenHeight * 0.004),
                                TextFormField(
                                  focusNode: controller.phoneFocusNode,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  keyboardType: TextInputType.number,
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
                                  controller: controller.phoneController,
                                  decoration: InputDecoration(
                                    hintText: 'Mobile Number',
                                    counterText: "",
                                    prefixIcon: Icon(
                                      Icons.phone,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                  onEditingComplete: () =>
                                      FocusScope.of(context).unfocus(),
                                ),
                                if (controller.authIndex.value == 1) ...[
                                  SizedBox(height: screenHeight * 0.02),
                                  Text(
                                    'Select Operator',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  SizedBox(height: screenHeight * 0.004),
                                  DropdownButtonFormField<Map<String, dynamic>>(
                                    initialValue:
                                        controller.selectedOperator.value,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        // child: SvgPicture.asset(
                                        //   'assets/simcard.svg',
                                        //   height: 20,
                                        //   width: 20,
                                        // ),
                                        child: Icon(
                                          Icons.sim_card,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      hintText: 'Select Operator',
                                    ),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,

                                      size: 18,
                                    ),
                                    isExpanded: true,
                                    onChanged: (newValue) {
                                      controller.selectedOperator.value =
                                          newValue;
                                    },
                                    validator: (v) {
                                      if (v == null) {
                                        return 'Please select your operator';
                                      }
                                      return null;
                                    },
                                    selectedItemBuilder: (context) {
                                      return operatorList.map((operator) {
                                        return Row(
                                          children: [
                                            Image.asset(
                                              operator['image'],
                                              height: 20,
                                              width: 20,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.sim_card,
                                                    size: 20,
                                                  ),
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                operator['text'],
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          colorScheme.onSurface,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList();
                                    },
                                    items: operatorList.map((operator) {
                                      return DropdownMenuItem<
                                        Map<String, dynamic>
                                      >(
                                        value: operator,
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              operator['image'],
                                              height: 24,
                                              width: 24,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.sim_card,
                                                    size: 20,
                                                  ),
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                operator['text'],
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          colorScheme.onSurface,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    dropdownColor: theme.colorScheme.surface,
                                    menuMaxHeight: 300,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ],
                                SizedBox(height: screenHeight * 0.02),
                                if (controller.authIndex.value == 0)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            controller.authIndex.value = 1;
                                          },
                                          child: Text('Sign Up'),
                                        ),
                                      ),
                                      const SizedBox(width: 40),
                                      Expanded(
                                        child: ElevatedButton1(
                                          text: 'Login',
                                          onclick: () async {
                                            if (formKey.currentState
                                                    ?.validate() ??
                                                false) {
                                              var release =
                                                  await DeviceInfo.getDeviceInfo();
                                              if (controller.authIndex.value ==
                                                  0) {
                                                String metaData = '${Platform.isAndroid ? "Android" : 'iOS'}__${release['release']}__${release['manufacturer']} ${release['model']}__${release['deviceId']}__fcmToken__${release['appVersion']}';
                                                print("MetaData: $metaData");
                                                Get.find<AuthController>().login(
                                                  cnic: controller
                                                      .cnicController
                                                      .text
                                                      .trim(),
                                                  mobileNumber: controller
                                                      .phoneController
                                                      .text
                                                      .trim(),
                                                  metaData: metaData,
                                                  deviceId: release['deviceId'],
                                                  operator:
                                                      controller
                                                              .selectedOperator
                                                              .value?['value']
                                                          as int?,
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),

                                    ],
                                  ),
                                SizedBox(height: screenHeight * 0.02),
                                if (controller.authIndex.value == 1) ...[
                                  Center(
                                    child: ElevatedButton1(
                                      onclick: () async {
                                        if (formKey.currentState?.validate() ??
                                            false) {
                                          await Get.find<AuthController>()
                                              .registerUser(
                                                cnic: controller
                                                    .cnicController
                                                    .text,
                                                mobileNumber: controller
                                                    .phoneController
                                                    .text,
                                                fullName:
                                                    controller.userName.text,
                                                operator:
                                                    controller
                                                            .selectedOperator
                                                            .value?['value']
                                                        as int?,
                                              );
                                        }
                                      },
                                      text: 'Sign Up',
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Align(
                                    alignment: .center,
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Already have an account? ',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                          ),
                                          TextSpan(
                                            text: 'Login',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelMedium,
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // Navigate to login screen
                                                controller.authIndex.value = 0;
                                              },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(child: FooterWidget()),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (Platform.isIOS) {
      return CustomKeyboardActions(
        focusNodes: [
          controller.cnicFocusNode,
          controller.phoneFocusNode,
          controller.fullNameFocusNode,
        ],
        child: mainContent,
      );
    } else {
      return mainContent;
    }
  }
}
