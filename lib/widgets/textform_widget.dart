import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.keyboardType,
    this.label,
    this.controller,
    this.inputFormatters,
    this.maxLines,
    this.validator,
    this.autovalidateMode,
    this.focusNode,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.fillColor,
    this.filled,
    this.hint,
    this.contentPadding,
    this.maxLength,
    this.onTapOutside,
    this.textInputAction,
    this.enabled,
    this.obscure = false,
    this.readOnly,
    this.autoFocus = false,
    this.onChanged,
    this.suffix,
    this.style,
    this.hintStyle,
  });

  final TextInputType? keyboardType;
  final String? label;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;
  final Function()? onEditingComplete;
  final Color? fillColor;
  final bool? filled;
  final String? hint;
  final int? maxLength;
  final bool? enabled;
  final bool obscure;
  final EdgeInsetsGeometry? contentPadding;
  final Function(PointerDownEvent)? onTapOutside;
  final TextInputAction? textInputAction;
  final bool? readOnly;
  final bool? autoFocus;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final Widget? suffix;
  final TextStyle? style;
  final TextStyle? hintStyle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      autofocus: autoFocus ?? false,
      readOnly: readOnly ?? false,
      textInputAction: textInputAction,
      onTapOutside: onTapOutside,
      onFieldSubmitted: onFieldSubmitted,
      maxLength: maxLength,
      style:
          style ??
          const TextStyle(fontSize: 14, fontFamily: 'Poppins', height: 1),
      onEditingComplete: onEditingComplete,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      validator: validator,
      maxLines: maxLines ?? 1,
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType ?? TextInputType.text,
      enabled: enabled,
      obscureText: obscure,
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: hintStyle,
        filled: filled,
        fillColor: fillColor,
        focusColor: const Color(0xffF0F0F0),

        contentPadding: contentPadding ?? EdgeInsets.zero,
        label: Text(label ?? ''),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
