import 'package:flutter/material.dart';

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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isHidden ? '••••••' : ': Rs ${widget.balance}',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: widget.fontSize,
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
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }
}
