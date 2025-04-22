import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/utils.dart';

class RechargeAmountField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool isObscured;
  final FocusNode? focusNode;

  const RechargeAmountField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isObscured = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(maxLength: 8,
  focusNode: focusNode,
  controller: controller,
  textInputAction: TextInputAction.done,
  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))],
  keyboardType: keyboardType,
  obscureText: isObscured,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  autofocus: false, // Autofocus remains false
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1),
  decoration: InputDecoration(counterText: '',
    isDense: true,
    enabled: true,
    prefixIcon: Transform.translate(offset: Offset(5, 10),
      child: Text(
        'PKR ',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    ),
    suffixIconConstraints: const BoxConstraints(maxHeight: 20, minHeight: 20),
    hintText: hintText,
    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).hintColor,
        ),
    alignLabelWithHint: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
    filled: true,
    fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11,
          color: Colors.redAccent,
        ),
  ),
  validator: validateAmount,
);


  }
}
