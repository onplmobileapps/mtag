import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/api/auth_controller.dart';
import 'package:mtag_flutterapp/base/app_data.dart';
import 'package:mtag_flutterapp/constants/auth_utils.dart';

class PinEntryPage extends StatefulWidget {
  final bool? iscreatPin;
  final int? isForgetPin;
  final String? cnicNumber;
  final String? mobileNum;

  const PinEntryPage({
    super.key,
    this.iscreatPin,
    this.cnicNumber,
    this.mobileNum,
    this.isForgetPin,
  });

  @override
  State<PinEntryPage> createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  final ValueNotifier<String> _pinNotifier = ValueNotifier<String>('');
  bool isAuthenticating = false;

  @override
  void dispose() {
    _pinNotifier.dispose();
    super.dispose();
  }

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

  Future<void> _authenticateAndVerify() async {
    if (isAuthenticating) return;
  if(mounted) {
    setState(() {
      isAuthenticating = true;
    });
  }

    bool isAuthenticated = await AuthenticationUtil.authenticate();

    if (isAuthenticated) {
      var pindata = AppData.getPinData();
      if (pindata != null) {
        await Get.find<AuthController>().verifyPIN(
          cnic: pindata['cnic'],
          mobileNum: pindata['mobile'],
          pin: pindata['pin'],
        );
      }
    } else {
      log("Authentication was canceled or failed.");
    }

   if(mounted) {
     setState(() {
      isAuthenticating = false;
    });
   }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {

            final double fontSize = constraints.maxHeight * 0.02;
            final double spacing = constraints.maxHeight * 0.03;
            final double pinFieldSize = constraints.maxWidth * 0.12;

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo and Title Section
                Column(
                  children: [
                    SizedBox(height: spacing * 1),
                    isDarkMode
                        ? Image.asset('assets/darklogo.png', height: 80, width: 80)
                        : SvgPicture.asset('assets/logolight.svg', height: 50, width: 50),
                    SizedBox(height: spacing * 2),
                    Text(
                      widget.iscreatPin == true || widget.isForgetPin == 1
                          ? 'Create your Login PIN'
                          : 'Enter your Login PIN',
                      style: TextStyle(
                        fontSize: fontSize * 1,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: spacing * 2),
                  ],
                ),

                // PIN Entry Section
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // PIN Fields
                      ValueListenableBuilder<String>(
                        valueListenable: _pinNotifier,
                        builder: (context, pin, child) {
                          if (pin.length == 4) {
                            var pindata = AppData.getPinData();

                            Future.microtask(() async {
                              if (widget.iscreatPin == true || widget.isForgetPin == 1) {
                                Get.find<AuthController>().createPIN(
                                  cnic: widget.cnicNumber,
                                  mobileNum: widget.mobileNum,
                                  isCreatePin: widget.iscreatPin == true ? 1 : 0,
                                  isForgetPin: widget.isForgetPin ?? 0,
                                  isResetPin: 0,
                                  pin: widget.iscreatPin == true ? pin : '',
                                  newPin: widget.isForgetPin == 1 ? pin : '',
                                );
                                return;
                              } else {
                                Get.find<AuthController>().verifyPIN(
                                  onTap: () {
                                    if (pin != pindata?['pin']) {
                                      _pinNotifier.value = ''; // Reset PIN field
                                      Future.delayed(Duration(milliseconds: 200), () {
                                        Get.back(); // Ensures back navigation happens after state update
                                      });
                                    }
                                  },
                                  cnic: '${pindata?['cnic'] ?? widget.cnicNumber}',
                                  mobileNum: '${pindata?['mobile'] ?? widget.mobileNum}',
                                  pin: pin,
                                );
                              }
                            });
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (index) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: spacing / 8),
                                width: pinFieldSize,
                                height: pinFieldSize,
                                child: Center(
                                  child: Text(
                                    pin.length > index ? pin[index] : "-",
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Numeric Keyboard Section
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/forgetPin');
                      },
                      child: Text(
                        'Forgot PIN?',
                        style: TextStyle(fontSize: fontSize, color: colorScheme.primary),
                      ),
                    ),
                    SizedBox(height: spacing),

                    // Numeric Keyboard
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 12,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.4,
                        ),
                        itemBuilder: (context, index) {
                          if (index == 9) {
                            return IconButton(
                              onPressed: _authenticateAndVerify,
                              icon: Icon(
                                Platform.isIOS ? Icons.face : Icons.fingerprint,
                                color: isDarkMode? Colors.white: Theme.of(context).primaryColor,
                                size: 40,
                              ),
                            );
                          } else if (index == 11) {
                            return IconButton(
                              onPressed: _onBackspaceTap,
                              icon: Icon(
                                Icons.backspace_outlined,
                                color: isDarkMode? Colors.white: Theme.of(context).primaryColor,
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
                                  fontSize: fontSize * 1.8,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            );
                          }
                        },
                      ),
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
