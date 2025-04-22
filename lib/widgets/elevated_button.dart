import 'package:flutter/material.dart';

class ElevatedButton1 extends StatelessWidget {
  const ElevatedButton1({
    super.key,
    required this.onclick,
    required this.text,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.textscaller,
  });
  final Function()? onclick;
  final String? text;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? textscaller;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
          backgroundColor: WidgetStatePropertyAll(backgroundColor),
          foregroundColor: WidgetStatePropertyAll(foregroundColor),
          fixedSize: WidgetStatePropertyAll(
            Size(width ?? 300, 35),
          ),
          maximumSize: WidgetStatePropertyAll(
            Size(width ?? 300, 35),
          ),
          minimumSize: WidgetStatePropertyAll(Size(width ?? 300, 35))),
      onPressed: onclick,
      child: Text(text ?? '', textScaler: TextScaler.linear(textscaller ?? 1.0)),
    );
  }
}
