import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controller/home_controller.dart';
import '../elevated_button.dart';

class ChassisNumberDialog extends StatefulWidget {
  final String registration;
  final String mobileNumber;
  final String tokenNo;
  final String balance;
  final String cnicNumber;

  const ChassisNumberDialog({
    super.key,
    required this.registration,
    required this.tokenNo,
    required this.balance,
    required this.cnicNumber,
    required this.mobileNumber,
  });

  @override
  State<ChassisNumberDialog> createState() => _ChassisNumberDialogState();
}

class _ChassisNumberDialogState extends State<ChassisNumberDialog> {
  final TextEditingController _controller = TextEditingController();
  String? errorText;

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;
    final containerPadding = isSmallScreen ? 10.0 : 12.0;

    return PopScope(
      canPop: true,
      child: AlertDialog(
        backgroundColor: Theme.of(context).disabledColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).primaryColorLight,
            width: 1,
          ),
        ),
        contentPadding: EdgeInsets.zero,
        content: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 40,
                left: 20,
                right: 20,
                bottom: 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Enter Chassis Number",
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// Vehicle Info Card
                  Container(
                    padding: EdgeInsets.all(containerPadding),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: isSmallScreen ? 18 : 20,
                          backgroundColor: Colors.white24,
                          child: Image.asset(
                            'assets/suv.png',
                            width: isSmallScreen ? 20 : 24,
                            height: isSmallScreen ? 20 : 24,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.registration,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: isSmallScreen ? 2 : 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.tokenNo,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 10 : 12,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    widget.balance,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 10 : 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// Text Field
                  TextField(
                    maxLength: 17,
                    controller: _controller,
                    keyboardType: TextInputType.text,

                    onChanged: (_) {
                      if (errorText != null) {
                        setState(() => errorText = null);
                      }
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      UpperCaseTextFormatter(),
                    ],
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: "e.g AX129XXXXXXX",
                      errorText: errorText,
                      counterText: "",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColorLight,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColorDark,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton1(
                      onclick: () async {
                        final text = _controller.text.trim();
                        if (text.isEmpty) {
                          setState(
                            () =>
                                errorText = "Chassis number must not be empty",
                          );
                          return;
                        }

                        Get.back();
                        await Get.find<HomeController>().updateChassisCall(
                          cnicNumber: widget.cnicNumber,
                          mobileNumber: widget.mobileNumber,
                          mtagID: widget.tokenNo,
                          chassisNumber: text,
                        );
                      },
                      text: "Submit",
                      backgroundColor: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ],
              ),
            ),

            /// 🔴 Close Red Round Button
            Positioned(
              right: 8,
              top: 8,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Forces uppercase input
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
