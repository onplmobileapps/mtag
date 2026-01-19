import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mtag_flutterapp/widgets/footer_widget.dart';

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

  Future<void> _checkBiometricAvailability() async {
    try {
      final canAuthenticate = await AuthenticationUtil.canAuthenticate();
      final availableBiometrics = await _auth.getAvailableBiometrics();
      if (mounted) {
        setState(() {
          _isAuthAvailable = availableBiometrics.isNotEmpty && canAuthenticate;
        });
      }
    } catch (e) {
      debugPrint('Biometric check error: $e');
      if (mounted) {
        setState(() => _isAuthAvailable = false);
      }
    }
  }

  Future<void> _authenticateAndVerify() async {
    if (_isAuthenticating || !mounted) return;

    try {
      setState(() => _isAuthenticating = true);
      final isAuthenticated = await AuthenticationUtil.authenticate();

      if (isAuthenticated && mounted) {
        final pinData = AppData.getPinData();
        if (pinData != null) {
          await Get.find<AuthController>().verifyPIN(
            cnic: pinData['cnic'],
            mobileNum: pinData['mobile'],
            pin: pinData['pin'],
          );
        }
      }
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  void _onNumberTap(int number) {
    if (_pin.value.length < 4) {
      _pin.value += number.toString();
      if (_pin.value.length == 4) {
        _submitPin();
      }
    }
  }

  void _onBackspaceTap() {
    if (_pin.value.isNotEmpty) {
      _pin.value = _pin.value.substring(0, _pin.value.length - 1);
    }
  }

  Future<void> _submitPin() async {
    try {
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
    } catch (e) {
      debugPrint('PIN submission error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Get.isDarkMode;

    return Scaffold(body: SafeArea(child: _buildContent(size, isDarkMode)));
  }

  Widget _buildContent(Size size, bool isDarkMode) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: size.height),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // Top Section
            SizedBox(height: size.height * 0.01),
            _buildLogo(size, isDarkMode),
            SizedBox(height: size.height * 0.01),
            _buildSubtitle(context),
            SizedBox(height: size.height * 0.02),
            _buildPinField(size),
            SizedBox(height: size.height * 0.02),
            _buildOptions(context, size),
            SizedBox(height: size.height * 0.01),
            _buildDifferentAccountOption(context),
            SizedBox(height: size.height * 0.02),

            // Keypad Section - Separate Component
            _buildKeypad(size),

            // Footer at bottom
            // SizedBox(height: size.height * 0.03),
            const Spacer(),
            const FooterWidget(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(Size size, bool isDarkMode) {
    return Center(
      child: Image.asset(
        isDarkMode ? 'assets/darklogo.png' : 'assets/logolight.png',
        height: size.height * 0.07,
        width: size.height * 0.15,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Center(
      child: Text(
        widget.isCreatePin || widget.isForgetPin == 1
            ? 'Create Login PIN'
            : 'Enter Login PIN',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

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
                margin: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: pin.length > index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade400,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
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

  Widget _buildOptions(BuildContext context, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (_isAuthAvailable)
            GestureDetector(
              onTap: () {
                if (AppData.getPinData() == null) {
                  _showBiometricDialog(context);
                } else {
                  _authenticateAndVerify();
                }
              },
              child: Platform.isIOS
                  ? Image.asset(
                      "assets/face3.png",
                      height: size.width * 0.099,
                      width: size.width * 0.099,

                      color: Get.isDarkMode
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    )
                  : Image.asset(
                      "assets/fingerprint.png",
                      height: 24,
                      width: 24,
                      color: Get.isDarkMode
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildDifferentAccountOption(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {
          _isFirstVisit = false;
          Get.toNamed('/auth');
        },
        child: Text(
          'Sign-in with a different account',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  // SEPARATE KEYPAD COMPONENT
  Widget _buildKeypad(Size size) {
    return Column(
      children: [
        // Row 1: 1 2 3
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleKey('1', size),
            SizedBox(width: size.width * 0.08),
            _buildCircleKey('2', size),
            SizedBox(width: size.width * 0.08),
            _buildCircleKey('3', size),
          ],
        ),
        SizedBox(height: size.height * 0.02),

        // Row 2: 4 5 6
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleKey('4', size),
            SizedBox(width: size.width * 0.08),
            _buildCircleKey('5', size),
            SizedBox(width: size.width * 0.08),
            _buildCircleKey('6', size),
          ],
        ),
        SizedBox(height: size.height * 0.02),

        // Row 3: 7 8 9
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleKey('7', size),
            SizedBox(width: size.width * 0.08),
            _buildCircleKey('8', size),
            SizedBox(width: size.width * 0.08),
            _buildCircleKey('9', size),
          ],
        ),
        SizedBox(height: size.height * 0.02),

        // Row 4: 0 and delete
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty space for symmetry
            SizedBox(width: size.width * 0.26),

            // 0 Key
            _buildCircleKey('0', size),

            // Delete Key
            SizedBox(width: size.width * 0.08),
            _buildDeleteKey(size),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleKey(String number, Size size) {
    final keySize = size.width * 0.18;
    final bgColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerLowest.withValues(alpha: 0.4);

    return SizedBox(
      width: keySize,
      height: keySize,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => _onNumberTap(int.parse(number)),
          borderRadius: BorderRadius.circular(keySize / 2),
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            alignment: Alignment.center,
            child: Text(
              number,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey(Size size) {
    final keySize = size.width * 0.18;
    final bgColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerLowest.withValues(alpha: 0.4);

    return SizedBox(
      width: keySize,
      height: keySize,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _onBackspaceTap,
          borderRadius: BorderRadius.circular(keySize / 2),
          onLongPress: () {
            _pin.value = '';
          },
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            alignment: Alignment.center,
            child: Icon(
              Icons.backspace_outlined,
              size: 28,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  void _showBiometricDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Biometric Login'),
        content: const Text(
          'Sign in with your CNIC and Mobile Number to enable biometric login. '
          'Next time, simply tap the Biometric icon to sign in.',
          textAlign: TextAlign.justify,
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: Get.back,
            isDefaultAction: true,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
