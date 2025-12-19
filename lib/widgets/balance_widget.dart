import 'package:flutter/material.dart';
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
            mainAxisSize: MainAxisSize.min, // shrink to content
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  isHidden ? '⁎' * balance.length : 'Rs. $balance',
                  overflow: TextOverflow.ellipsis,
                  style: TextTheme.of(context).headlineLarge?.copyWith(
                    fontSize: 30,

                    fontWeight: FontWeight.bold,letterSpacing: 0.1
                  ),
                ),
              ),

              const SizedBox(width: 10),
              Padding(
                padding: .only(top:6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => isHiddenNotifier.value = !isHidden,
                  child: Icon(
                    isHidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: iconSize,
                    
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
