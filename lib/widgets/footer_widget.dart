import 'package:flutter/material.dart';
import '../constants/call_helper.dart';
import '../features/recharge_center_locator.dart';
import '../pages/faqs/faqs_screen.dart';


class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;

          // Adaptive padding based on screen size
          final horizontalPadding = screenWidth < 360 ? 12.0 : 16.0;
          final itemSpacing = screenWidth < 360 ? 6.0 : 8.0;

          // Calculate exact item width for pixel-perfect layout
          final availableWidth = constraints.maxWidth - (horizontalPadding * 2);
          final totalSpacing = itemSpacing * 3;
          final itemWidth = (availableWidth - totalSpacing) / 4;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              MediaQuery.of(context).padding.bottom > 0 ? 8 : 16,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FooterItem(
                    image: 'assets/whatsapp.png',
                    label: 'WhatsApp',
                    semantics: 'Open WhatsApp support',
                    width: itemWidth,
                    screenWidth: screenWidth,
                    onTap: () async {
                      await CallWhatsappUtil.openWhatsAppChat();
                    },
                  ),
                  SizedBox(width: itemSpacing),
                  _FooterItem(
                    image: 'assets/phone.png',
                    label: 'Helpline 1313',
                    semantics: 'Call helpline 1313',
                    width: itemWidth,
                    screenWidth: screenWidth,
                    onTap: () async {
                      await CallWhatsappUtil.openCall1313();
                    },
                  ),
                  SizedBox(width: itemSpacing),
                  _FooterItem(
                    image: 'assets/location.png',
                    label: 'Recharge Locations',
                    semantics: 'Find recharge locations',
                    width: itemWidth,
                    screenWidth: screenWidth,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RechargeMapScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: itemSpacing),
                  _FooterItem(
                    image: 'assets/question.png',
                    label: 'FAQ\'s',
                    semantics: 'Open frequently asked questions',
                    width: itemWidth,
                    screenWidth: screenWidth,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FaqsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FooterItem extends StatefulWidget {
  final String image;
  final String label;
  final String semantics;
  final double width;
  final double screenWidth;
  final VoidCallback onTap;

  const _FooterItem({
    required this.image,
    required this.label,
    required this.semantics,
    required this.width,
    required this.screenWidth,
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

    // Initialize animation controller
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

  // Get responsive values based on screen width
  double get _iconSize {
    if (widget.screenWidth < 340) return 20.0;
    if (widget.screenWidth < 375) return 22.0;
    if (widget.screenWidth < 414) return 24.0;
    return 24.0;
  }

  double get _fontSize {
    if (widget.screenWidth < 340) return 9.5;
    if (widget.screenWidth < 375) return 10.5;
    if (widget.screenWidth < 414) return 11.5;
    return 12.0;
  }

  double get _textHeight {
    if (widget.screenWidth < 340) return 28.0;
    if (widget.screenWidth < 375) return 30.0;
    if (widget.screenWidth < 414) return 32.0;
    return 34.0;
  }

  double get _verticalPadding {
    if (widget.screenWidth < 340) return 10.0;
    if (widget.screenWidth < 375) return 11.0;
    return 12.0;
  }

  double get _spacing {
    if (widget.screenWidth < 340) return 4.0;
    if (widget.screenWidth < 375) return 5.0;
    return 6.0;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semantics,
      excludeSemantics: true,
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
            splashColor: Colors.black.withValues(alpha: 0.05),
            highlightColor: Colors.black.withValues(alpha: 0.03),
            child: Ink(
              width: widget.width,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: _verticalPadding,
                  horizontal: 4,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Icon with optimized rendering
                    SizedBox(
                      height: _iconSize,
                      width: _iconSize,
                      child: Image.asset(
                        widget.image,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                        isAntiAlias: true,
                        cacheWidth: (_iconSize * MediaQuery.of(context).devicePixelRatio).round(),
                      ),
                    ),
                    SizedBox(height: _spacing),

                    // Text with fixed height for alignment
                    SizedBox(
                      height: _textHeight,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.label,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: _fontSize,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A1A1A),
                            letterSpacing: -0.1,
                          ),
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