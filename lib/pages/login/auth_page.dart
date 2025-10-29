import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import '../../api/auth_controller.dart';
import '../../constants/input_formater.dart';
import '../../utils/utils.dart';
import 'controller/auth_page_controller.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  final controller = Get.put(AuthPageController());

  final List<Map<String, dynamic>> operatorList = [
    {
      'text': 'Jazz',
      'value': 1,
      'image': 'assets/jazz-logo-1.png',
      'prefixes': [
        '0300',
        '0301',
        '0302',
        '0303',
        '0304',
        '0306',
        '0307',
        '0308',
        '0309',
      ],
    },
    {
      'text': 'Telenor',
      'value': 2,
      'image': 'assets/telenor.jpg',
      'prefixes': [
        '0340',
        '0341',
        '0342',
        '0343',
        '0344',
        '0345',
        '0346',
        '0347',
        '0348',
        '0349',
      ],
    },
    {
      'text': 'Ufone',
      'value': 3,
      'image': 'assets/ufone.png',
      'prefixes': [
        '0330',
        '0331',
        '0332',
        '0333',
        '0334',
        '0335',
        '0336',
        '0337',
        '0338',
      ],
    },
    {
      'text': 'Zong',
      'value': 5,
      'image': 'assets/zong.png',
      'prefixes': [
        '0310',
        '0311',
        '0312',
        '0313',
        '0314',
        '0315',
        '0316',
        '0317',
        '0318',
        '0319',
      ],
    },
    {
      'text': 'Warid',
      'value': 4,
      'image': 'assets/warid.png',
      'prefixes': [
        '0320',
        '0321',
        '0322',
        '0323',
        '0324',
        '0325',
        '0327',
        '0328',
        '0329',
      ],
    },
    {
      'text': 'SCO',
      'value': 6,
      'image': 'assets/sco.webp',
      'prefixes': ['0355'],
    },
  ];

  KeyboardActionsConfig _buildKeyboardConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[200]
          : Colors.grey[800],
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: controller.cnicFocusNode,
          toolbarButtons: [
            (node) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                onPressed: () {
                  node.unfocus();
                  FocusScope.of(context).unfocus();
                },
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
          focusNode: controller.phoneFocusNode,
          toolbarButtons: [
            (node) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                onPressed: () {
                  node.unfocus();
                  FocusScope.of(context).unfocus();
                },
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

  Map<String, dynamic>? _detectOperator(String phoneNumber) {
    if (phoneNumber.length >= 4) {
      String prefix = phoneNumber.substring(0, 4);
      for (var operator in operatorList) {
        if (operator['prefixes']?.contains(prefix) ?? false) {
          return operator;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              config: _buildKeyboardConfig(context),
              child: Obx(
                () => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.12),
                    Center(
                      child: isDarkMode
                          ? Image.asset(
                              'assets/darklogo.png',
                              height: 60.0,
                              fit: BoxFit.contain,
                            )
                          : SvgPicture.asset(
                              'assets/logolight.svg',
                              height: 60.0,
                              fit: BoxFit.contain,
                            ),
                    ),
                    SizedBox(height: screenHeight * 0.06),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.authIndex.value = 0;
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign In',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: controller.authIndex.value == 0
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
                            horizontal: screenWidth * 0.02,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.authIndex.value = 1;
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign Up',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: controller.authIndex.value == 1
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
                      key: controller.formKey,
                      child: Column(
                        children: [
                          if (controller.authIndex.value == 1)
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
                              controller: controller.userName,
                              decoration: const InputDecoration(
                                hintText: 'Full Name',
                              ),
                              validator: (v) {
                                if (controller.authIndex.value == 1 &&
                                    (v == null || v.isEmpty || v.length < 3)) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                          SizedBox(height: screenHeight * 0.02),
                          TextFormField(
                            focusNode: controller.cnicFocusNode,
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
                            controller: controller.cnicController,
                            decoration: const InputDecoration(hintText: 'CNIC'),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Obx(
                            () => TextFormField(
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
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 70,
                                  maxWidth: 150,
                                ),
                                prefixIcon: controller.authIndex.value == 1
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          left: 4,
                                          right: 4,
                                        ),
                                        child: SizedBox(
                                          width: 200,
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<Map<String, dynamic>>(
                                              value: controller
                                                  .selectedOperator
                                                  .value,
                                              icon: const Icon(
                                                Icons.arrow_drop_down,
                                                size: 18,
                                              ),
                                              isExpanded: true,
                                              hint: Row(
                                                children: [
                                                  Text(
                                                    'Select Operator',
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: colorScheme
                                                              .onSurface,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                              onChanged:
                                                  (
                                                    Map<String, dynamic>?
                                                    newValue,
                                                  ) {
                                                    if (newValue != null) {
                                                      controller
                                                              .selectedOperator
                                                              .value =
                                                          newValue;
                                                    }
                                                  },
                                              selectedItemBuilder: (context) {
                                                return operatorList.map((
                                                  operator,
                                                ) {
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
                                                                    FontWeight
                                                                        .w500,
                                                                color: colorScheme
                                                                    .onSurface,
                                                              ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }).toList();
                                              },
                                              items: operatorList.map((
                                                operator,
                                              ) {
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
                                                                    FontWeight
                                                                        .w500,
                                                                color: colorScheme
                                                                    .onSurface,
                                                              ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                              isDense: false,
                                              dropdownColor: Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                              menuMaxHeight: 300,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
                                final detectedOperator = _detectOperator(value);
                                if (detectedOperator != null) {
                                  controller.selectedOperator.value =
                                      detectedOperator;
                                }
                              },
                              onEditingComplete: () =>
                                  FocusScope.of(context).unfocus(),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () async {
                                if (controller.formKey.currentState
                                        ?.validate() ??
                                    false) {
                                  var release =
                                      await DeviceInfo.getDeviceInfo();
                                  if (controller.authIndex.value == 0) {
                                    Get.find<AuthController>().login(
                                      cnic: controller.cnicController.text
                                          .trim(),
                                      mobileNumber: controller
                                          .phoneController
                                          .text
                                          .trim(),
                                      metaData:
                                          '"${Platform.isAndroid ? "Android" : 'iOS'} ""__"${release['release']} "__"${release['manufacturer']}""${release['model']} "__"android_id"__"fcmToken"__"3.1.4"',
                                      operator:
                                          controller
                                                  .selectedOperator
                                                  .value?['value']
                                              as int?,
                                    );
                                  } else {
                                    await Get.find<AuthController>()
                                        .registerUser(
                                          cnic: controller.cnicController.text,
                                          mobileNumber:
                                              controller.phoneController.text,
                                          fullName: controller.userName.text,
                                          operator:
                                              controller
                                                      .selectedOperator
                                                      .value?['value']
                                                  as int?,
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
