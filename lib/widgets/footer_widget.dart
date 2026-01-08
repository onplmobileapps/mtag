import 'package:flutter/material.dart';

import 'package:mtag_flutterapp/constants/call_helper.dart';
import 'package:mtag_flutterapp/features/recharge_center_locator.dart';
import 'package:mtag_flutterapp/pages/faqs/faqs_screen.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        _buildFooterItem(
          context,
          image: 'assets/whatsapp.png',
          label: 'WhatsApp',onPressed: ()async {
          await  CallWhatsappUtil.openWhatsAppChat();
          },
        ),
         _buildFooterItem(
          context,
          image: 'assets/phone.png',
          label: 'Helpline 1313',onPressed: ()async {
          await  CallWhatsappUtil.openCall1313();
          },
        ),
         _buildFooterItem(
          context,
          image: 'assets/location.png',
          label: 'Recharge Locations',onPressed: ()async {
        Navigator.of(context).push(MaterialPageRoute(builder: (_)=>RechargeMapScreen()));
          },
        ),
         _buildFooterItem(
          context,
          image: 'assets/question.png',
          label: 'FAQ’s',onPressed: ()async {
           Navigator.of(context).push(MaterialPageRoute(builder: (_)=>FaqsScreen()));
          },
        ),
      ],
    );
  }
}

Widget _buildFooterItem(
  BuildContext context, {
  final String? image,
  final String? label,
  final VoidCallback? onPressed,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: 80,
      height: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xffF5F6F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 4,),
          // Image section
          if (image != null && image.isNotEmpty)
            Container(
              height: 30,
              width: 30,
              alignment: Alignment.center,
              child: Image.asset(
                image,
                fit: BoxFit.contain,
              ),
            ),
        
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 64, // Container width minus padding (80 - 8*2 = 64)
                child: Text(
                  label ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
