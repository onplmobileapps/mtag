


import 'package:flutter/material.dart';

Widget buildBulletPoint(String text, Color textColor) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "• ",
        style: TextStyle(fontSize: 14, color: Colors.redAccent),
      ),
      Expanded(
        child: Text(
          text,
          style: TextStyle(fontSize: 12, color: textColor),
        ),
      ),
    ],
  );
}