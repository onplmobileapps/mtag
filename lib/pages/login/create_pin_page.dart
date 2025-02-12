import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '../../api/auth_controller.dart';
import '../../base/app_data.dart';
import '../../constants/auth_utils.dart';

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
late bool isAuthAvailable;
  Future<void> _authenticateAndVerify() async {
    if (isAuthenticating) return;
    if (mounted) {
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

    if (mounted) {
      setState(() {
        isAuthenticating = false;
      });
    }
  }
   static final auth = LocalAuthentication();
bool _isLoading=true;
Future<void> checkAvailability() async {
    setState(() => _isLoading = true); // Ensure UI updates

    bool canAuthenticate = await AuthenticationUtil.canAuthenticate();
    List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

    setState(() {
      isAuthAvailable =  availableBiometrics.isNotEmpty&&canAuthenticate ;
      log("is available$isAuthAvailable".toString());
      _isLoading = false;
    });
  }
 @override
 void didChangeDependencies()async {
await  checkAvailability();
    WidgetsBinding.instance.addPostFrameCallback((_) {
  
      if (isAuthAvailable&&AppData.getPinData() != null) _authenticateAndVerify();
    });
    super.didChangeDependencies();
  }
 

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return  LayoutBuilder(
      builder: (context, constraints) {
        final double fontSize = size.height * 0.02;
        final double spacing = size.height * 0.03;
        final double pinFieldSize =
            size.width * 0.11; // Scales with screen width

        return Material(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing * 1.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: spacing * 3),

                // Logo & Title
                Center(
                    child: Image.asset(
                        Get.isDarkMode
                            ? 'assets/darklogo.png'
                            : 'assets/logolight.png',
                        height: size.height * 0.08)),
                SizedBox(height: spacing * 1.5),

                Center(
                  child: Text(
                    'Welcome to One Network',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: fontSize * 1.3,
                        ),
                  ),
                ),
                SizedBox(height: spacing / 2),

                Center(
                  child: Text(
                    widget.iscreatPin == true || widget.isForgetPin == 1
                        ? 'Create Login PIN'
                        : 'Enter Login PIN',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(height: spacing),

                // PIN Entry Field
                Center(
                  child: ValueListenableBuilder<String>(
                    valueListenable: _pinNotifier,
                    builder: (context, pin, child) {
                      if (pin.length == 4) {
                        var pindata = AppData.getPinData();

                        Future.microtask(() async {
                          if (widget.iscreatPin == true ||
                              widget.isForgetPin == 1) {
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
                                  Future.delayed(Duration(milliseconds: 200),
                                      () {
                                    Get.back(); // Ensures back navigation happens after state update
                                  });
                                  
                                }
                              },
                              cnic: '${pindata?['cnic'] ?? widget.cnicNumber}',
                              mobileNum:
                                  '${pindata?['mobile'] ?? widget.mobileNum}',
                              pin: pin,
                            );
                          }
                        });
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Container(
                            width: pinFieldSize,
                            height: pinFieldSize,
                            margin: EdgeInsets.symmetric(
                                horizontal: size.width * 0.030),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                pin.length > index ? pin[index] : "",
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                SizedBox(height: spacing * 1.5),

                // Forgot PIN & Sign-in with a different account
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: ()async => Get.toNamed('/forgetPin'),
                            child: Text(
                              'Forgot Login PIN?',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                    if (!_isLoading&&isAuthAvailable)
  _buildKey(
    child: Icon(
      Platform.isIOS ? Icons.face : Icons.fingerprint,
      size: size.width * 0.09,
    ),
    onPressed: () {
      if (AppData.getPinData() == null) {
        showCupertinoModalPopup(
          context: Get.context!,
          builder: (_) => CupertinoAlertDialog(
            content: const Text(
              'Sign in with your CNIC and Mobile Number to enable biometric login. Next time, simply tap the Biometric icon to sign in.',
              textAlign: TextAlign.justify,
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: Get.back,
                child: const Text('Ok'),
              )
            ],
          ),
        );
        return;
      } else {
        _authenticateAndVerify();
      }
    },
  ),

                        ],
                      ),
                    ),
                    SizedBox(height: spacing / 2),
                    Center(
                      child: InkWell(
                        onTap: () => Get.toNamed('/auth'),
                        child: Text(
                          'Sign-in with a different account',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing),

                // Numeric Keyboard
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 12,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.3,
                    ),
                    itemBuilder: (context, index) {
                      if (index == 9) {
                        return SizedBox.shrink();
                      }
                      // if (index == 9) {
                      //   return _buildKey(
                      //     child: Icon(
                      //       Platform.isIOS ? Icons.face : Icons.fingerprint,
                      //       size: size.width * 0.09,
                      //     ),
                      //     onPressed: _authenticateAndVerify,
                      //   );
                      // }
                      else if (index == 11) {
                        return _buildKey(
                          child: Icon(
                            Icons.backspace_outlined,
                            size: size.width * 0.07,
                          ),
                          onPressed: _onBackspaceTap,
                        );
                      } else {
                        final number = index == 10 ? 0 : index + 1;
                        return _buildKey(
                          child: Text(
                            '$number',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontSize: fontSize * 1.5),
                          ),
                          onPressed: () => _onNumberTap(number),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKey({required Widget child, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        // splashColor: Colors.grey.shade300,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50), // Ensures rounded shape
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
