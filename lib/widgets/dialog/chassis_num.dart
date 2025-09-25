import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import '../elevated_button.dart';

class ChassisNumberDialog extends StatefulWidget {
  final String registration;
  final String tokenNo;
  final String balance;

  const ChassisNumberDialog({
    super.key,
    required this.registration,
    required this.tokenNo,
    required this.balance,
  });

  @override
  State<ChassisNumberDialog> createState() => _ChassisNumberDialogState();
}

class _ChassisNumberDialogState extends State<ChassisNumberDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;
    final containerPadding = isSmallScreen ? 10.0 : 12.0;

    return PopScope(
      canPop: false,

      child: AlertDialog(
        backgroundColor: Theme.of(context).disabledColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).primaryColorLight,
            width: 1,
          ),
        ),
        title: Center(
          child: Text(
            "Enter Chassis Number",
            style: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                            fontFamily: "Poppins",
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

            // 🔢 Chassis input field
            TextField(
              controller: _controller,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                UpperCaseTextFormatter(),
              ],
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: "e.g AX129XXX",
                hintStyle: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  color: Colors.grey.shade500,
                ),
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
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton1(
              onclick: () {
                final text = _controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.of(context).pop(text);
                }
              },
              text: "Submit",
              backgroundColor: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
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
