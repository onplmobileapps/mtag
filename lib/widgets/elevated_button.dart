import 'package:flutter/material.dart';

class ElevatedButton1 extends StatelessWidget {
  const ElevatedButton1({
    super.key,
    required this.onclick,
    required this.text,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.textscaller,
    this.shape,
    this.icon,
    this.iconRight = false,
  });

  final Function()? onclick;
  final String? text;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? textscaller;
  final OutlinedBorder? shape;

  final Widget? icon;

  final bool iconRight;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
        backgroundColor: WidgetStatePropertyAll(backgroundColor),
        foregroundColor: WidgetStatePropertyAll(foregroundColor),
        fixedSize: WidgetStatePropertyAll(Size(width ?? 300, height ?? 40)),
        minimumSize: WidgetStatePropertyAll(Size(width ?? 300, height ?? 40)),
        maximumSize: WidgetStatePropertyAll(Size(width ?? 300, height ?? 40)),
        shape: shape != null ? WidgetStatePropertyAll(shape) : null,
      ),
      onPressed: onclick,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null && !iconRight) ...[icon!, const SizedBox(width: 12)],
          Text(text ?? '', textScaler: TextScaler.linear(textscaller ?? 1.0)),
          if (icon != null && iconRight) ...[const SizedBox(width: 12), icon!],
        ],
      ),
    );
  }
}
