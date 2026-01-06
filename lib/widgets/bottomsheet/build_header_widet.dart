  import 'package:flutter/material.dart';

Widget buildHandleBar(BuildContext context) {
  return Center(
    child: Container(margin: .all(8),
      width: 60, 
      height: 6, 
      decoration: BoxDecoration(
        color: ColorScheme.of(context).surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(
          color: Colors.grey.shade100.withValues(alpha: 0.2), // Border color
          width: 1, // Border thickness
        ),
      ),
    ),
  );
}
