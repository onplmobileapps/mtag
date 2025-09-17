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
            padding: EdgeInsets.symmetric(horizontal: spacing * 1.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: spacing * 3),
                _buildLogo(size),
                SizedBox(height: spacing * 1.5),
                _buildTitle(context),
                SizedBox(height: spacing / 2),
                _buildSubtitle(context),
                SizedBox(height: spacing),
                _buildPinField(size),
                SizedBox(height: spacing * 1.5),
                _buildOptions(size),
                SizedBox(height: spacing),
                _buildKeyboard(size),
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

  /// Builds the welcome title.
  Widget _buildTitle(BuildContext context) {
    return Center(
      child: Text(
        'Welcome to One Network',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: MediaQuery.of(context).size.height * 0.026,
        ),
      ),
    );
  }

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
                width: size.width * 0.11,
                height: size.width * 0.11,
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
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              // Show empty Container until biometric availability is checked
              _isAuthAvailable
                  ? _buildKey(
                      // child: Icon(
                      //   Platform.isIOS ? Icons.face : Icons.fingerprint,
                      //   size: size.width * 0.09,
                      // ),
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Platform.isIOS
                            ? Image.asset(
                                "assets/face.png",
                                height: size.width * 0.08,
                                width: size.width * 0.08,
                                color: Get.isDarkMode
                                    ? Theme.of(context).primaryColor
                                    : Colors.white,
                              )
                            : Image.asset(
                                "assets/fingerprint.png",
                                height: size.width * 0.08,
                                width: size.width * 0.08,
                                color: Get.isDarkMode
                                    ? Theme.of(context).primaryColor
                                    : Colors.white,
                              ),
                      ),

                      onPressed: () {
                        if (AppData.getPinData() == null) {
                          _showBiometricDialog(context);
                        } else {
                          _authenticateAndVerify();
                        }
                      },
                    )
                  : Container(width: size.width * 0.09), // Placeholder
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
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the numeric keyboard.
  Widget _buildKeyboard(Size size) {
    return Expanded(
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.3,
        ),
        itemBuilder: (context, index) {
          if (index == 9) return const SizedBox.shrink();
          if (index == 11) {
            return _buildKey(
              child: Icon(Icons.backspace_outlined, size: size.width * 0.07),
              onPressed: _onBackspaceTap,
            );
          }
          final number = index == 10 ? 0 : index + 1;
          return _buildKey(
            child: Text(
              '$number',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontSize: size.height * 0.03),
            ),
            onPressed: () => _onNumberTap(number),
          );
        },
      ),
    );
  }

  /// Reusable key widget for keyboard buttons.
  Widget _buildKey({required Widget child, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(12),
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
