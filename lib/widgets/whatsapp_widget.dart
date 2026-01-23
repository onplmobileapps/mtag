import 'package:flutter/material.dart';
import '../constants/call_helper.dart';

class WhatsAppButton extends StatelessWidget {

  final double width;
  final double height;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets padding;
  final String iconAsset;

  const WhatsAppButton({
    super.key,
  
    this.width = 40,
    this.height = 40,
    this.backgroundColor = Colors.white,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.iconAsset = 'assets/whatsapp_1.png',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CallWhatsappUtil.openWhatsAppChat();
      },
      child: Container(
        padding: padding,
       
        child: Image.asset(iconAsset, width: width, height: height),
      ),
    );
  }
}
