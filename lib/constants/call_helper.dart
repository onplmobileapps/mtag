import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class CallWhatsappUtil {
  static final CallWhatsappUtil _instance = CallWhatsappUtil._internal();
  CallWhatsappUtil._internal();
  factory CallWhatsappUtil() => _instance;
  static Future<void> openCall1313() async {
    try {
      await launchUrl(Uri.parse('tel:1313'));
    } catch (e) {
      if (kDebugMode) {
        print('Error calling phone number: $e');
      }
    }
  }

  static Future<void> openWhatsAppChat() async {
    final Uri whatsappUrl = Uri.parse("https://wa.me/+923105931103");
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        throw 'Could not launch $whatsappUrl';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error opening WhatsApp chat: $e');
      }
    }
  }
}
