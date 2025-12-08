import 'package:flutter/material.dart';

class ZoomControl extends StatelessWidget {
  final VoidCallback onPlus;
  final VoidCallback onMinus;

  const ZoomControl({super.key, required this.onPlus, required this.onMinus});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
        boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: onPlus,
            child: const Icon(Icons.add, size: 26),
          ),

          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.black26,
          ),

          GestureDetector(
            onTap: onMinus,
            child: const Icon(Icons.remove, size: 26),
          ),
        ],
      ),
    );
  }
}
