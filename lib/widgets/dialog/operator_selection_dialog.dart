import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/call_helper.dart';
import '../operator_drop_down.dart';

class OperatorSelectionDialog extends StatefulWidget {
  final void Function(String operator, String number) onSubmit;
  final String? mobileNumber;

  const OperatorSelectionDialog({
    super.key,
    required this.onSubmit,
    this.mobileNumber,
  });

  static void show(
      BuildContext context,
      void Function(String, String) onSubmit, {
        String? mobileNumber,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: OperatorSelectionDialog(
          onSubmit: onSubmit,
          mobileNumber: mobileNumber,
        ),
      ),
    );
  }

  @override
  State<OperatorSelectionDialog> createState() => _OperatorSelectionDialogState();
}

class _OperatorSelectionDialogState extends State<OperatorSelectionDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _numberController = TextEditingController();
  String? selectedOperator;
  bool _showError = false;
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;


  @override
  void initState() {
    super.initState();
    if (widget.mobileNumber != null) {
      _numberController.text = widget.mobileNumber!;
    }

    // Initialize animation controller for shake effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Define shake animation with a sequence of offsets
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 10), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 10, end: -10), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: -10, end: 10), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 10, end: 0), weight: 25),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double leftPadding = 10.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Centered Logo
            Center(
              child: SvgPicture.asset(
                'assets/logolight.svg',
                height: 60.0,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            // Mobile Number Field (Read-Only)
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: leftPadding, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            // Operator Selection Section
            Padding(
              padding: const EdgeInsets.only(left: leftPadding),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Mobile Operator',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            OperatorDropdown(
              selectedOperator: selectedOperator,
              onChanged: (value) {
                setState(() {
                  selectedOperator = value;
                  _showError = false;
                  _animationController.reset();
                });
              },
            ),
            const SizedBox(height: 15),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {

                  if (selectedOperator != null && _numberController.text.isNotEmpty) {
                    Navigator.of(context).pop();
                    widget.onSubmit(selectedOperator!, _numberController.text);

                  } else {
                    setState(() {
                      _showError = true;
                      _animationController.forward(from: 0);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.white),
                ),
              ),
            ),
            // Error Message
            if (_showError)
              Center(
                child: Text(
                  'Please select Mobile Operator.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            const SizedBox(height: 15),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 16.0,
                  fontFamily: 'Poppins',
                  letterSpacing: 1.5,
                ),
                children: <InlineSpan>[
                  TextSpan(
                    text: 'Further assistance? Call ',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  TextSpan(
                    recognizer: TapGestureRecognizer()..onTap = () async => await CallWhatsappUtil.openCall1313(),
                    text: '1313',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: ' or ',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () async => await CallWhatsappUtil.openWhatsAppChat('+923105931103'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/whatsapp.png',
                            width: 20.0,
                            height: 20.0,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            'WhatsApp',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperatorItem {
  final String name;
  final String image;

  _OperatorItem({required this.name, required this.image});
}