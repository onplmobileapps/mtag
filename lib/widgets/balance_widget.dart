import 'package:flutter/material.dart';

class BalanceWidget extends StatefulWidget {
  final String? ball;

  const BalanceWidget({super.key, required this.ball});

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
          isHidden ? '••••••' : 'Rs ${widget.ball}',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
