import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../../api/auth_controller.dart';
import '../../base/app_data.dart';
import '../../constants/auth_utils.dart';

class PinEntryPage extends StatefulWidget {
  final bool isCreatePin;
  final int? isForgetPin;
  final String? cnicNumber;
  final String? mobileNumber;

  const PinEntryPage({
    super.key,
    this.isCreatePin = false,
    this.isForgetPin,
    this.cnicNumber,
    this.mobileNumber,
  });

  @override
  State<PinEntryPage> createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  final ValueNotifier<String> _pin = ValueNotifier<String>('');
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  bool _isFirstVisit = true;
  bool _isAuthAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFirstVisit && _isAuthAvailable && AppData.getPinData() != null) {
        _authenticateAndVerify();
        _isFirstVisit = false;
      }
    });
  }

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  /// Checks if biometric authentication is available.
  Future<void> _checkBiometricAvailability() async {
    final canAuthenticate = await AuthenticationUtil.canAuthenticate();
    final availableBiometrics = await _auth.getAvailableBiometrics();
    if (mounted) {
      setState(() {
        _isAuthAvailable = availableBiometrics.isNotEmpty && canAuthenticate;
      });
    }
  }

  /// Authenticates using biometrics and verifies stored PIN.
  Future<void> _authenticateAndVerify() async {
    if (_isAuthenticating || !mounted) return;

    setState(() => _isAuthenticating = true);
    final isAuthenticated = await AuthenticationUtil.authenticate();

    if (isAuthenticated) {
      final pinData = AppData.getPinData();
      if (pinData != null) {
        await Get.find<AuthController>().verifyPIN(
          cnic: pinData['cnic'],
          mobileNum: pinData['mobile'],
          pin: pinData['pin'],
        );
      }
    }

    if (mounted) setState(() => _isAuthenticating = false);
  }

  /// Handles number input for PIN entry.
  void _onNumberTap(int number) {
    if (_pin.value.length < 4) {
      _pin.value += number.toString();
      if (_pin.value.length == 4) _submitPin();
    }
  }

  /// Removes the last digit from the PIN.
  void _onBackspaceTap() {
    if (_pin.value.isNotEmpty) {
      _pin.value = _pin.value.substring(0, _pin.value.length - 1);
    }
  }

  /// Submits the PIN for creation or verification.
  Future<void> _submitPin() async {
    final authController = Get.find<AuthController>();
    final pinData = AppData.getPinData();

    if (widget.isCreatePin || widget.isForgetPin == 1) {
      await authController.createPIN(
        cnic: widget.cnicNumber,
        mobileNum: widget.mobileNumber,
        isCreatePin: widget.isCreatePin ? 1 : 0,
        isForgetPin: widget.isForgetPin ?? 0,
        isResetPin: 0,
        pin: widget.isCreatePin ? _pin.value : '',
        newPin: widget.isForgetPin == 1 ? _pin.value : '',
      );
    } else {
      await authController.verifyPIN(
        onTap: () {
          _pin.value = '';
          Future.delayed(const Duration(milliseconds: 200), () => Get.back());
        },
        cnic: pinData?['cnic'] ?? widget.cnicNumber ?? '',
        mobileNum: pinData?['mobile'] ?? widget.mobileNumber ?? '',
        pin: _pin.value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = size.height * 0.03;

        return Material(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing),
            child: Column(
              spacing: 16,
              mainAxisAlignment: .start,
              crossAxisAlignment: .start,
              children: [
                SizedBox(height: 60),

                _buildLogo(size),

              

                _buildSubtitle(context),
   
                _buildPinField(size),

                _buildOptions(size),

                _buildKeyboard(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the logo widget.
  Widget _buildLogo(Size size) {
    return Center(
      child: Image.asset(
        Get.isDarkMode ? 'assets/darklogo.png' : 'assets/logolight.png',
        height: size.height * 0.08,
      ),
    );
  }


// Hasseeb asked to remove title 

  /// Builds the subtitle based on page context.
  Widget _buildSubtitle(BuildContext context) {
    return Center(
      child: Text(
        widget.isCreatePin || widget.isForgetPin == 1
            ? 'Create Login PIN'
            : 'Enter Login PIN',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  /// Builds the PIN entry field.
  Widget _buildPinField(Size size) {
    return Center(
      child: ValueListenableBuilder<String>(
        valueListenable: _pin,
        builder: (context, pin, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                width: size.width * 0.14,
                height: size.width * 0.14,
                margin: EdgeInsets.symmetric(horizontal: size.width * 0.030),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    pin.length > index ? pin[index] : '',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  /// Builds the options row (Forgot PIN and Biometric).
  Widget _buildOptions(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  _isFirstVisit = false;
                  Get.toNamed('/forgetPin');
                },
                child: Text(
                  'Forgot Login PIN?',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: .w600),
                ),
              ),
              _isAuthAvailable
                  ? GestureDetector(
                      onTap: () {
                        if (AppData.getPinData() == null) {
                          _showBiometricDialog(context);
                        } else {
                          _authenticateAndVerify();
                        }
                      },
                      child: Container(
                        margin: .all(16),
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? Colors.transparent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Get.isDarkMode
                                ? Colors.transparent
                                : Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        child: Platform.isIOS
                            ? Transform.translate(
                                offset: Offset(
                                  size.width * 0.008,
                                  size.height * 0.002,
                                ),
                                child: Image.asset(
                                  "assets/face3.png",
                                  height: size.width * 0.09,
                                  width: size.width * 0.09,
                                  fit: BoxFit.contain,
                                  color: Get.isDarkMode
                                      ? Colors.white
                                      : Theme.of(context).primaryColor,
                                ),
                              )
                            : Image.asset(
                                "assets/fingerprint.png",
                                height: size.width * 0.08,
                                width: size.width * 0.08,
                                color: Get.isDarkMode
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                              ),
                      ),
                    )
                  : Container(width: size.width * 0.09),
            ],
          ),
        ),
        SizedBox(height: size.height * 0.015),
        Center(
          child: InkWell(
            onTap: () {
              _isFirstVisit = false;
              Get.toNamed('/auth');
            },
            child: Text(
              'Sign-in with a different account',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                decoration: TextDecoration.underline,
                fontWeight: .w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the numeric keyboard.
  Widget _buildKeyboard() {
  return Expanded(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final maxWidth = constraints.maxWidth;
        
        // Calculate key size based on available space
        final double keyWidth = maxWidth / 3 - 5; // Account for spacing
        final double keyHeight = keyWidth * (Platform.isAndroid ? 1.0 : 1.4);
        
        // Adjust if total height exceeds available space
        final totalGridHeight = (keyHeight * 4) + (28 * 3); // 4 rows, 3 spacings
        
        final double aspectRatio = totalGridHeight > maxHeight 
            ? keyWidth / (keyHeight * (maxHeight / totalGridHeight))
            : keyWidth / keyHeight;
        
        return GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 12,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 6,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) {
            if (index == 9) return const SizedBox.shrink();
            if (index == 11) {
              return _buildKey(
                child: Icon(Icons.backspace_outlined, size: keyWidth * 0.3),
                onPressed: _onBackspaceTap,
              );
            }
            final number = index == 10 ? 0 : index + 1;
            return _buildKey(
              child: Text(
                '$number',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 30, // Relative to key size
                ),
              ),
              onPressed: () => _onNumberTap(number),
            );
          },
        );
      },
    ),
  );
}

  /// Reusable key widget for keyboard buttons.
  Widget _buildKey({required Widget child, required VoidCallback onPressed}) {
    final bgColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerLowest.withValues(alpha: 0.4);

    return Material(
      color: bgColor, // SAME as container bg
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(), // splash radius = circle
        splashColor: bgColor.withValues(alpha: 0.7),
        highlightColor: bgColor.withValues(alpha: 0.5),
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  /// Shows a dialog when biometric is unavailable or not set up.
  void _showBiometricDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        content: const Text(
          'Sign in with your CNIC and Mobile Number to enable biometric login. Next time, simply tap the Biometric icon to sign in.',
          textAlign: TextAlign.justify,
        ),
        actions: [
          CupertinoDialogAction(onPressed: Get.back, child: const Text('Ok')),
        ],
      ),
    );
  }
}
