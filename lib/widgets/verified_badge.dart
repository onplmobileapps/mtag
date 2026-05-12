import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  final String label;
  final String tooltipMessage;
  final bool isVerified;

  const VerifiedBadge({
    super.key,
    required this.label,
    required this.tooltipMessage,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message: tooltipMessage,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isVerified
                ? const Color(0xffA5B891).withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isVerified
                ? Image.asset('assets/verified.png', height: 16, width: 16)
                : Image.asset('assets/unverified.png', height: 16, width: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isVerified ? Color(0xff222B5D) : Colors.grey,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                fontFamily: 'biotifbold',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
