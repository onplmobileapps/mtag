import 'package:flutter/cupertino.dart';
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
  final String? chassissNo;

  const ChassisNumberDialog({
    super.key,
    required this.registration,
    required this.tokenNo,
    required this.balance,
    required this.cnicNumber,
    required this.mobileNumber,
    this.chassissNo,
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
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: .circular(12)),
        backgroundColor: ColorScheme.of(context).surfaceContainerLowest,

        child: Padding(
          padding: .all(16),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentGeometry.topRight,
                child: GestureDetector(
                  onTap: Get.back,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
              Text(
                "Enter Chassis Number",
                style: TextTheme.of(
                  context,
                ).headlineSmall?.copyWith(fontWeight: .w600),
              ),
              const SizedBox(height: 30),

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
                            style: TextTheme.of(
                              context,
                            ).displayMedium?.copyWith(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.tokenNo,
                                  style: TextTheme.of(
                                    context,
                                  ).bodySmall?.copyWith(color: Colors.white),
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
              CupertinoTextField(
                maxLines: 1,
                padding: .all(16),
                maxLength: 17,
                placeholder: 'Enter chassis number',
                controller: _controller..text = widget.chassissNo ?? '',
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
              ),
              const SizedBox(height: 20),

              /// Submit Button
              ElevatedButton1(
                onclick: () async {
                  final text = _controller.text.trim();
                  if (text.isEmpty) {
                    setState(
                      () => errorText = "Chassis number must not be empty",
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
              const SizedBox(height: 20),
            ],
          ),
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
