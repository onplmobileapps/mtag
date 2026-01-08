import 'package:flutter/material.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';

import '../../constants/call_helper.dart';

class HelpSection extends StatelessWidget {
  const HelpSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: .symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: Theme.of(context).extension<AppGradients>()!.card,
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            width: 0.1,
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/help.png',
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.broken_image),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help & Customer Support',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Call our helpline 1313 to get quick help on queries related to your M-Tag',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCallButton(
                          onTap: CallWhatsappUtil.openCall1313,
                          text: '1313',
                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildCallButton(
                          onTap: () async =>
                              await CallWhatsappUtil.openWhatsAppChat(),
                          text: 'WhatsApp',
                          icon: Image.asset(
                            'assets/whatsapp.png',
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({String? text, Widget? icon, VoidCallback? onTap}) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: icon!,
      label: Text(
        text ?? '',
        style: TextStyle(
          color: text == 'WhatsApp' ? Colors.green : Colors.redAccent,
          fontSize: 12,
        ),
      ),
      iconAlignment: IconAlignment.end,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(double.infinity, 35),
        maximumSize: const Size(double.infinity, 35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}