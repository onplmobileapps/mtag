import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
      child: 
         Dialog(
          shape: RoundedRectangleBorder(borderRadius: .circular(12)),
          backgroundColor: ColorScheme.of(context).surfaceContainerLowest,
        
          child: Container(
             decoration:BoxDecoration(borderRadius: .circular(8),
               gradient: const LinearGradient(
              begin: .topLeft,
              end: AlignmentGeometry.centerRight,
              colors: [Color(0xFFE4EDFC), Color(0xFFFCFCFC), Color(0xFFEAEBFD)],
            ), ),
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
                        radius: 14,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                  Text(
                    "Enter Chassis Number",
                    style: TextTheme.of(
                      context,
                    ).titleMedium?.copyWith(fontWeight: .w600),
                  ),
                  const SizedBox(height: 30),
                    
                  Container(
                    padding: EdgeInsets.all(containerPadding),
                    decoration: BoxDecoration(  color: Color(0xffF5F6F9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          offset: Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.grey.shade200,
                          offset: Offset(4, 1),
                        ),
                        BoxShadow(
                          color: Colors.grey.shade200,
                          offset: Offset(1, 2),
                        ),
                        BoxShadow(
                          color: Colors.grey.shade200,
                          offset: Offset(2, 1),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: .all(12),
                          decoration: BoxDecoration(
                            color: ColorScheme.of(context).surface,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [],
                          ),
                          child: Image.asset(
                            'assets/delivery.png',
                            color: Theme.of(context).primaryColor,
                            height: 35,
                          ),
                        ),
                        SizedBox(width:10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                registration,
                                style: TextTheme.of(
                                  context,
                                ).displayMedium?.copyWith(),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      tokenNo,
                                      style: TextTheme.of(
                                        context,
                                      ).bodySmall?.copyWith(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    balance,
                                    style: TextTheme.of(context).bodySmall,
                                    
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
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: .start,
                      crossAxisAlignment: .start,
                      children: [
                        CupertinoTextFormFieldRow(
                          padding: .symmetric(horizontal: 10, vertical: 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: .circular(8),
                          ),
                          maxLines: 1,
                    
                          maxLength: 17,
                          placeholder: 'Enter chassis number',
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                    
                  /// Submit Button
                  ElevatedButton1(
                    onclick: () async {
                      final text = _controller.text.trim();
                    
                      Get.back();
                      await Get.find<HomeController>().updateChassisCall(
                        cnicNumber: cnicNumber,
                        mobileNumber: mobileNumber,
                        mtagID: tokenNo,
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
