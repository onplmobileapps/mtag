import 'package:flutter/material.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';

class BalanceWidget extends StatefulWidget {
  final String? balance;
  final double? fontSize, iconSize;

  const BalanceWidget({
    super.key,
    required this.balance,
    required this.fontSize,
    required this.iconSize,
  });

  @override
  State<BalanceWidget> createState() => _BalanceWidgetState();
}

class _BalanceWidgetState extends State<BalanceWidget> {
  bool isHidden = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,crossAxisAlignment: .center,
      children: [
        Text(
          isHidden ? ' ••••••' : 'Rs. ${widget.balance}',
          style: TextStyle(
            color: primarSwatch,
            fontWeight: FontWeight.w700,
            fontSize: 25,
          ),
        ),
        SizedBox(width: 8),
        InkWell(
          onTap: () {
            setState(() {
              isHidden = !isHidden;
            });
          },
          child: Icon(
            size: widget.iconSize,
            isHidden
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: primarSwatch,
          ),
        ),
      ],
    );
  }
}
