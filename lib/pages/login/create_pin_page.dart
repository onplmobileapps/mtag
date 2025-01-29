import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/api/auth_controller.dart';
import 'package:mtag_flutterapp/base/app_data.dart';
import 'package:mtag_flutterapp/constants/auth_utils.dart';

class PinEntryPage extends StatelessWidget {
  final ValueNotifier<String> _pinNotifier = ValueNotifier<String>('');
  final bool? iscreatPin;
  final int? isForgetPin;
  final String? cnicNumber;
  final String? mobileNum;

  PinEntryPage(
      {super.key,
      this.iscreatPin,
      this.cnicNumber,
      this.mobileNum,
      this.isForgetPin});

  void _onNumberTap(int number) {
    if (_pinNotifier.value.length < 4) {
      _pinNotifier.value += number.toString();
    }
  }

  void _onBackspaceTap() {
    if (_pinNotifier.value.isNotEmpty) {
      _pinNotifier.value =
          _pinNotifier.value.substring(0, _pinNotifier.value.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Define responsive sizing
            final double iconSize = constraints.maxHeight * 0.08;
            final double fontSize = constraints.maxHeight * 0.02;
            final double spacing = constraints.maxHeight * 0.03;
            final double pinFieldSize = constraints.maxWidth * 0.12;

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(height: spacing * 1),
                    Icon(Icons.lock,
                        size: iconSize, color: colorScheme.primary),
                    SizedBox(height: spacing * 3),
                    Text(
                      iscreatPin == true || isForgetPin == 1
                          ? 'Create your login PIN'
                          : 'Enter your login PIN',
                      style: TextStyle(
                        fontSize: fontSize * 1,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: spacing * 2),

                    // PIN Fields
                    ValueListenableBuilder<String>(
                      valueListenable: _pinNotifier,
                      builder: (context, pin, child) {
                        if (pin.length == 4) {
                          var pindata = AppData.getPinData();

                          Future.microtask(() async {
                            if (iscreatPin == true || isForgetPin == 1) {
                              Get.find<AuthController>().createPIN(
                                cnic: cnicNumber,
                                mobileNum: mobileNum,
                                isCreatePin: iscreatPin == true ? 1 : 0,
                                isForgetPin: isForgetPin ?? 0,
                                isResetPin: 0,
                                pin: iscreatPin == true ? pin : '',
                                newPin: isForgetPin == 1 ? pin : '',
                              );
                              return;
                            } else {
                              Get.find<AuthController>().verifyPIN(
                                onTap: () {
                                  if (pin != pindata?['pin']) {
                                    _pinNotifier.value = '';
                                    Get.back();
                                  }
                                },
                                cnic: '${pindata?['cnic'] ?? cnicNumber}',
                                mobileNum: '${pindata?['mobile'] ?? mobileNum}',
                                pin: pin,
                              );
                            }
                          });
                        }

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: spacing / 2),
                                  width: pinFieldSize,
                                  height: pinFieldSize,
                                  decoration: BoxDecoration(),
                                  child: Center(
                                    child: Text(
                                      pin.length > index ? pin[index] : "-",
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/forgetPin');
                      },
                      child: Text(
                        'Forgot PIN?',
                        style: TextStyle(
                            fontSize: fontSize, color: colorScheme.primary),
                      ),
                    ),
                    SizedBox(height: spacing),

                    // Numeric Keyboard
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 12,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.5,
                      ),
                      itemBuilder: (context, index) {
                        if (index == 9) {
                          return IconButton(
                            onPressed: () async {
                              await AuthenticationUtil.authenticate();
                              var pindata = AppData.getPinData();
                              await Get.find<AuthController>().verifyPIN(
                                cnic: pindata?['cnic'],
                                mobileNum: pindata?['mobile'],
                                pin: pindata?['pin'],
                              );
                            },
                            icon: Icon(
                              Platform.isIOS ? Icons.face : Icons.fingerprint,
                              color: Colors.blue,
                              size: 25,
                            ),
                          );
                        } else if (index == 11) {
                          return IconButton(
                            onPressed: _onBackspaceTap,
                            icon: Icon(
                              Icons.backspace_outlined,
                              color: Colors.blue,
                              size: 25,
                            ),
                          );
                        } else {
                          final number = index == 10 ? 0 : index + 1;
                          return IconButton(
                            onPressed: () => _onNumberTap(number),
                            icon: Text(
                              '$number',
                              style: TextStyle(
                                fontSize: fontSize * 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
