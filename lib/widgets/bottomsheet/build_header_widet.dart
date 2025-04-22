  import 'package:flutter/material.dart';

Widget buildHandleBar(BuildContext context) {
  return Center(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.3, 
      height: 4, 
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(2), 
        border: Border.all(
          color: Colors.grey, // Border color
          width: 1, // Border thickness
        ),
      ),
    ),
  );
}
