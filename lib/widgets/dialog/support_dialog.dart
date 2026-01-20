import 'package:flutter/material.dart';
import '../../constants/call_helper.dart';
import '../../theme/app_theme.dart';

class SupportDialog extends StatelessWidget {
  const SupportDialog({super.key});

  static void show(BuildContext context) {
    showDialog(context: context, builder: (context) => const SupportDialog());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: Theme.of(context).extension<AppGradients>()?.background,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Text(
                  'How would you like to contact us?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 25),
                _SupportOption(
                  icon: Icons.phone_in_talk_rounded,
                  title: 'Call 1313',
                  subtitle: 'Talk to our representative',
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.pop(context);
                    CallWhatsappUtil.openCall1313();
                  },
                ),
                const SizedBox(height: 15),
                _SupportOption(
                  imagePath: 'assets/whatsapp_1.png',
                  title: 'WhatsApp',
                  subtitle: 'Chat with us on WhatsApp',
                  color: const Color(0xFF25D366),
                  iconBgColor: Colors.white,
                  onTap: () {
                    Navigator.pop(context);
                    CallWhatsappUtil.openWhatsAppChat();
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 16,
                  child: Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportOption extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String subtitle;
  final Color color;
  final Color? iconBgColor;
  final VoidCallback onTap;

  const _SupportOption({
    this.icon,
    this.imagePath,
    required this.title,
    required this.subtitle,
    required this.color,
    this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
            color: color.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor ?? color,
                  shape: BoxShape.circle,
                  boxShadow: iconBgColor != null
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: imagePath != null
                    ? Image.asset(imagePath!, width: 24, height: 24)
                    : Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white30 : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
