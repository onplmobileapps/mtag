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
    this.isShowIcon = false,
    this.iconAlignment = IconAlignment.end,
    this.textStyle,
    this.isEnabled = true,
  });

  final VoidCallback? onclick;
  final String? text;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? textscaller;
  final OutlinedBorder? shape;
  final bool isShowIcon;
  final IconAlignment iconAlignment;
  final Widget? icon;
  final TextStyle? textStyle;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).elevatedButtonTheme.style?.copyWith(
      backgroundColor: WidgetStatePropertyAll(backgroundColor),
      foregroundColor: WidgetStatePropertyAll(foregroundColor),
      fixedSize: WidgetStatePropertyAll(Size(width ?? 300, height ?? 40)),
      minimumSize: WidgetStatePropertyAll(Size(width ?? 300, height ?? 40)),
      maximumSize: WidgetStatePropertyAll(Size(width ?? 300, height ?? 40)),
      shape: WidgetStatePropertyAll(
        shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
    final VoidCallback? effectiveOnPressed = isEnabled ? onclick : null;
    if (!isShowIcon || icon == null) {
      return ElevatedButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: Text(
          text ?? '',
          textAlign: TextAlign.center,
          style: textStyle ?? const TextStyle(fontSize: 14),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: effectiveOnPressed,
      style: style,
      iconAlignment: iconAlignment,
      icon: icon!,
      label: Text(
        text ?? '',
        style: textStyle ?? const TextStyle(fontSize: 14),
      ),
    );
  }
}
