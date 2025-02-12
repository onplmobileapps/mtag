import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTExtField extends StatelessWidget {
  const CustomTExtField({
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
    this.enable,
    this.obscure = false,
    this.isReadOnly,
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
  final bool? enable;
  final bool obscure;
  final EdgeInsetsGeometry? contentPadding;
  final Function(PointerDownEvent)? onTapOutside;
  final TextInputAction? textInputAction;
  final bool? isReadOnly;
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
      readOnly: isReadOnly ?? false,
      textInputAction: textInputAction,
      onTapOutside: onTapOutside,onFieldSubmitted:onFieldSubmitted ,
      maxLength: maxLength,
      style: style ?? const TextStyle(fontSize: 14, fontFamily: 'Poppins', height: 1),
      onEditingComplete: onEditingComplete,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      validator: validator,
      maxLines: maxLines ?? 1,
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType ?? TextInputType.text,
      enabled: enable,
      obscureText: obscure,
      decoration: InputDecoration(
        errorBorder: const UnderlineInputBorder(),
        focusedErrorBorder: const UnderlineInputBorder(),
        counterText: '',
        hintText: hint,
        hintStyle: hintStyle,
        filled: filled,
        fillColor: fillColor,
        focusColor: const Color(0xffF0F0F0),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(width: 0.3, color: Theme.of(context).indicatorColor)),
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(width: 0.3, color: Theme.of(context).indicatorColor)),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).indicatorColor, width: 0.3)),
        contentPadding: contentPadding ?? EdgeInsets.zero,
        label: Text(label ?? ''),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
