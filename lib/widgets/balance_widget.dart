import 'package:flutter/material.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';

class BalanceWidget extends StatelessWidget {
  final String balance;
  final double fontSize;
  final double iconSize;

  /// ValueNotifier to control the visibility of balance
  final ValueNotifier<bool> isHiddenNotifier;

  BalanceWidget({
    super.key,
    required this.balance,
    required this.fontSize,
    required this.iconSize,
    bool initialHidden = true,
  }) : isHiddenNotifier = ValueNotifier<bool>(initialHidden);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isHiddenNotifier,
      builder: (context, isHidden, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isHidden ? '⁎' * balance.length : 'Rs. $balance',
                style: TextStyle(
                  color: primarSwatch,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,letterSpacing: 0.0
                  // fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => isHiddenNotifier.value = !isHidden,
                child: Icon(
                  isHidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: iconSize,
                  color: primarSwatch,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
