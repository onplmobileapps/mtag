import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/call_helper.dart';
import '../operator_drop_down.dart';

class OperatorSelectionDialog extends StatefulWidget {
  final void Function(int value) onSubmit;
  final String? mobileNumber;
  final int? value;

  const OperatorSelectionDialog({
    super.key,
    required this.onSubmit,
    this.mobileNumber,
    this.value
  });

  static void show(
      BuildContext context,
      void Function(int) onSubmit, {
        String? mobileNumber,
        int? value
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          surfaceTintColor: Theme.of(context).dialogTheme.surfaceTintColor,
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: OperatorSelectionDialog(
            onSubmit: onSubmit,
            mobileNumber: mobileNumber,
            value: value,
          ),
        ),
      ),
    );
  }

  @override
  State<OperatorSelectionDialog> createState() => _OperatorSelectionDialogState();
}

class _OperatorSelectionDialogState extends State<OperatorSelectionDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _numberController = TextEditingController();
  int? selectedOperatorValue;
  bool _showError = false;
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.mobileNumber != null) {
      _numberController.text = widget.mobileNumber!;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: isDarkMode
              ? Border.all(color: Colors.grey.withAlpha(128), width: 1)
              : null, // No border in light mode
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Centered Logo - changes based on theme
                Center(
                  child: isDarkMode
                      ? Image.asset(
                    'assets/darklogo.png',
                    height: 60.0,
                    fit: BoxFit.contain,
                  )
                      : SvgPicture.asset(
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
                    hintStyle: Theme.of(context).textTheme.displaySmall,
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor, width: 1.5),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                // Operator Selection Section
                Text(
                  'Select Mobile Operator',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 8),
                OperatorDropdown(
                  selectedOperator: selectedOperatorValue != null
                      ? OperatorDropdown.defaultOperators
                      .firstWhere((op) => op.value == selectedOperatorValue)
                      .name
                      : null,
                  onChanged: (value) {
                    setState(() {
                      selectedOperatorValue = value != null
                          ? OperatorDropdown.defaultOperators
                          .firstWhere((op) => op.name == value)
                          .value
                          : null;
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
                      if (selectedOperatorValue != null) {
                        Navigator.of(context).pop();
                        widget.onSubmit(selectedOperatorValue!);
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
                    child: Text(
                      'Submit',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Error Message
                if (_showError)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Please select Mobile Operator.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
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
                          onTap: () async => await CallWhatsappUtil.openWhatsAppChat(),
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
        ),
      ),
    );
  }
}