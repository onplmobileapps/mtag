import 'package:flutter/material.dart';
import '../constants/call_helper.dart';

class WhatsAppButton extends StatelessWidget {
  final String phoneNumber;
  final double width;
  final double height;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets padding;
  final String iconAsset;

  const WhatsAppButton({
    super.key,
    required this.phoneNumber,
    this.width = 40,
    this.height = 40,
    this.backgroundColor = Colors.white,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.iconAsset = 'assets/whatsapp_round.png',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CallWhatsappUtil.openWhatsAppChat(phoneNumber);
      },
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            bottomLeft: Radius.circular(borderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(iconAsset, width: width, height: height),
      ),
    );
  }
}
