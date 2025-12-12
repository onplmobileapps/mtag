import 'package:flutter/material.dart';
class ZoomControl extends StatelessWidget {
  final VoidCallback onPlus;
  final VoidCallback onMinus;

  const ZoomControl({super.key, required this.onPlus, required this.onMinus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 45,
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.surface, // background adapts to theme
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline), // use outline for border
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha:0.1), // subtle shadow
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: onPlus,
            child: Icon(
              Icons.add,
              size: 26,
              color: colorScheme.onSurface, // icon color adapts to theme
            ),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: colorScheme.outlineVariant, // line color adapts
          ),
          GestureDetector(
            onTap: onMinus,
            child: Icon(
              Icons.remove,
              size: 26,
              color: colorScheme.onSurface, // icon color adapts to theme
            ),
          ),
        ],
      ),
    );
  }
}
