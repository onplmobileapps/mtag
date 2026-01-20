import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import '../../controller/home_controller.dart';
import '../elevated_button.dart';

class ChassisNumberDialog extends StatelessWidget {
  final String registration;
  final String mobileNumber;
  final String tokenNo;
  final String balance;
  final String cnicNumber;
  final String? chassissNo;

  ChassisNumberDialog({
    super.key,
    required this.registration,
    required this.tokenNo,
    required this.balance,
    required this.cnicNumber,
    required this.mobileNumber,
    this.chassissNo,
  });

  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;
    final containerPadding = isSmallScreen ? 10.0 : 12.0;

    return PopScope(
      canPop: true,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: Theme.of(context).extension<AppGradients>()!.background,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: Get.back,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                // Title
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Enter Chassis Number",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Vehicle info card
                Container(
                  padding: EdgeInsets.all(containerPadding),
                  decoration: BoxDecoration(
                    color: ColorScheme.of(context).surfaceContainerLow,
                    boxShadow: Theme.of(
                      context,
                    ).extension<AppShadows>()!.cardShadow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ColorScheme.of(context).surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          'assets/delivery.png',
                          color: Theme.of(context).primaryColor,
                          height: 35,
                          width: 35,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Vehicle details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Registration number
                            Text(
                              registration,
                              style: Theme.of(context).textTheme.displayMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Token and balance row
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    tokenNo,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  balance,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Chassis input field
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CupertinoTextFormFieldRow(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: ColorScheme.of(context).surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        maxLines: 1,
                        maxLength: 17,
                        placeholder: 'Enter chassis number',
                        placeholderStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: Theme.of(context).hintColor),
                        controller: _controller..text = chassissNo ?? '',
                        keyboardType: TextInputType.text,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Enter a valid chassis number'
                            : null,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9]'),
                          ),
                          UpperCaseTextFormatter(),
                        ],
                        textCapitalization: TextCapitalization.characters,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Submit button
                Center(
                  child: ElevatedButton1(
                    onclick: () async {
                      final text = _controller.text.trim();
                      if (_formKey.currentState?.validate() ?? false) {
                        Get.back();
                        await Get.find<HomeController>().updateChassisCall(
                          cnicNumber: cnicNumber,
                          mobileNumber: mobileNumber,
                          mtagID: tokenNo,
                          chassisNumber: text,
                        );
                      }
                    },
                    text: "Submit",
                    backgroundColor: Theme.of(context).primaryColorDark,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
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
