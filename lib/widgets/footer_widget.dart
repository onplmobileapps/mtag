import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import '../api/auth_controller.dart';
import '../constants/call_helper.dart';
import '../features/recharge_center_locator.dart';
import '../pages/faqs/faqs_screen.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // _FooterItem(
              //   image: 'assets/whatsapp_1.png',
              //   label: 'WhatsApp',
              //   semantics: 'Open WhatsApp support',
              //   isDark: isDark,
              //   isMultiColor: true,
              //   onTap: () async {
              //     await CallWhatsappUtil.openWhatsAppChat();
              //   },
              // ),
              _FooterItem(
                image: 'assets/phone.png',
                label: 'Helpline 1313',
                semantics: 'Call helpline 1313',
                isDark: isDark,
                onTap: () async {
                  await CallWhatsappUtil.openCall1313();
                },
              ),
              _FooterItem(
                image: 'assets/location.png',
                label: 'Recharge Locations',
                semantics: 'Find recharge locations',
                isDark: isDark,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => RechargeMapScreen()),
                  );
                  try {
                    Get.find<AuthController>().clearSharedData();
                  } catch (e) {
                    debugPrint("⚠️ Could not find AuthController: $e");
                  }
                },
              ),
              _FooterItem(
                image: 'assets/question.png',
                label: 'FAQ\'s',
                semantics: 'Open frequently asked questions',
                isDark: isDark,
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => FaqsScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterItem extends StatefulWidget {
  final String image;
  final String label;
  final String semantics;
  final bool isDark;
  final bool isMultiColor;
  final VoidCallback onTap;

  const _FooterItem({
    required this.image,
    required this.label,
    required this.semantics,
    required this.isDark,
    this.isMultiColor = false,
    required this.onTap,
  });

  @override
  State<_FooterItem> createState() => _FooterItemState();
}

class _FooterItemState extends State<_FooterItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.reverse();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.forward();
  }

  void _handleTapCancel() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semantics,
      child: ScaleTransition(
        scale: _controller,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            highlightColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.03),
            child: Container(
              width: 72, // Fixed base width
              height: 72, // Fixed base height
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF1A1C28)
                    : const Color(0xFFF5F6F9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(bottom: 6),
                      child: Image.asset(
                        widget.image,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                        // Apply white tint in dark mode, unless it's a multi-color icon like WhatsApp
                        color: (widget.isDark && !widget.isMultiColor)
                            ? Colors.white
                            : null,
                        colorBlendMode: (widget.isDark && !widget.isMultiColor)
                            ? BlendMode.srcIn
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: 64, // Constrain text width
                      child: Text(
                        widget.label,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
