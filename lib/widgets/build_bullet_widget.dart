


import 'package:flutter/material.dart';

Widget buildBulletPoint(BuildContext context, String text,) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
     Text(
        "• ",
        style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.redAccent),
      ),
      Expanded(
        child: Text(
          text,
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
    ],
  );
}