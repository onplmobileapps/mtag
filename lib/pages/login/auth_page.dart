import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/widgets/custom_keyboard_actions.dart';
import 'package:mtag_flutterapp/widgets/elevated_button.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final mainContent = LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        return Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.09,
            ),
            child: Obx(
              () => SizedBox(
                height: screenHeight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: .min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.12),
                      Center(
                        child: Image.asset(
                          isDarkMode
                              ? 'assets/darklogo.png'
                              : 'assets/logolight.png',
                          height: 60.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Text(
                        'Welcome to M-TAG One Network',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: .w900,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.06),
                      Container(
                        padding: .all(2),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withAlpha(
                            200,
                          ),
                          borderRadius: .circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ------------------ SIGN IN ------------------
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  controller.authIndex.value = 0;
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      controller.authIndex.value == 0
                                      ? colorScheme
                                            .surface // active: white in light, dark in dark
                                      : colorScheme.surfaceContainerHighest,
                                  foregroundColor:
                                      controller.authIndex.value == 0
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.secondary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                  ),

                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: controller.authIndex.value == 0
                                        ? const BorderSide(
                                            color: Color(0x7FEFF0F6),
                                            width: 1,
                                          )
                                        : BorderSide.none,
                                  ),
                                  elevation: controller.authIndex.value == 0
                                      ? 2
                                      : 0,
                                ),
                                child: Text(
                                  'Sign In',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                            ),

                            const SizedBox(width: 4),

                            // ------------------ SIGN UP ------------------
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  controller.authIndex.value = 1;
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      controller.authIndex.value == 1
                                      ? colorScheme
                                            .surface // active: white in light, dark in dark
                                      : colorScheme.surfaceContainerHighest,
                                  foregroundColor:
                                      controller.authIndex.value == 1
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.secondary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                  ),

                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: controller.authIndex.value == 1
                                        ? const BorderSide(
                                            color: Color(0x7FEFF0F6),
                                            width: 1,
                                          )
                                        : BorderSide.none,
                                  ),
                                  elevation: controller.authIndex.value == 1
                                      ? 2
                                      : 0,
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),
                      Form(
                        key: controller.formKey,
                        child: Column(
                          mainAxisAlignment: .start,
                          crossAxisAlignment: .start,
                          children: [
                            if (controller.authIndex.value == 1) ...[
                              Text(
                                'Full Name',
                                style: TextTheme.of(context).bodySmall,
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
                                decoration: const InputDecoration(
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
                              style: TextTheme.of(context).bodySmall,
                            ),
                            SizedBox(height: screenHeight * 0.004),
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
                              decoration: const InputDecoration(
                                hintText: 'CNIC',
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              'Phone Number',
                              style: TextTheme.of(context).bodySmall,
                            ),
                            SizedBox(height: screenHeight * 0.004),
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
                                            width: 100,
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
                                                    SvgPicture.asset(
                                                      'assets/simcard.svg',
                                                    ),
                                                  ],
                                                ),
                                                onChanged: (newValue) {
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
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
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
                                                            overflow:
                                                                TextOverflow
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
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
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
                                                            overflow:
                                                                TextOverflow
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
                                  final detectedOperator = _detectOperator(
                                    value,
                                  );
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
                            Center(
                              child: ElevatedButton1(
                                text: 'Continue',
                                onclick: () async {
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
                                            cnic:
                                                controller.cnicController.text,
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
