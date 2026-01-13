import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';

// ----------------------------- Bottom Nav Item -----------------------------
class BottomNavItem {
  final String imagePath;
  final String label;
  final int index;
  final double iconSize;
  final double fontSize;
  final double spacing;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final bool isSpacer;
  final double? spacerWidth;
  final Widget? page;

  BottomNavItem({
    required this.imagePath,
    required this.label,
    required this.index,
    this.iconSize = 16,
    this.fontSize = 10,
    this.spacing = 4,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.isSpacer = false,
    this.spacerWidth,
    this.page,
  });

  factory BottomNavItem.spacer({double width = 40}) {
    return BottomNavItem(
      imagePath: '',
      label: '',
      index: -1,
      isSpacer: true,
      spacerWidth: width,
    );
  }
}

// ----------------------------- Merged Bottom Bar -----------------------------
class NewBottomBar extends StatelessWidget {
  final HomeController controller;
  final List<BottomNavItem> items;
  final VoidCallback onCenterTap;

  const NewBottomBar({
    super.key,
    required this.controller,
    required this.items,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    // Guard against empty items
    if (items.isEmpty) {
      debugPrint('NewBottomBar: No items provided');
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive calculations with safety checks
    final barHeight = (screenHeight * 0.1).clamp(60.0, 100.0);
    final fabSize = barHeight * 0.7;
    final fabIconSize = fabSize * 0.5;
    final itemIconSize = barHeight * 0.28;
    final itemSpacing = screenWidth * 0.02;
    final horizontalPadding = screenWidth * 0.02;
    final curveRadius = barHeight * 0.25;
    final fabCurveRadius = fabSize * 0.6;
    final curveDepth = barHeight * 0.60;

    // Safe item width calculation
    final nonSpacerItems = items.where((i) => !i.isSpacer).length;
    final availableWidth = screenWidth - (horizontalPadding * 2) - fabSize - (itemSpacing * 4);
    final itemWidth = nonSpacerItems > 0 ? (availableWidth / nonSpacerItems).clamp(50.0, 100.0) : 80.0;

    return SizedBox(
      height: barHeight,
      width: screenWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background with outline - wrapped in RepaintBoundary for performance
          RepaintBoundary(
            child: CustomPaint(
              size: Size(screenWidth, barHeight),
              painter: _BottomBarOutlinePainter(
                fabRadius: fabCurveRadius,
                curveDepth: curveDepth,
                curveRadius: curveRadius,
                barHeight: barHeight,
              ),
            ),
          ),

          // Navigation items
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildNavItems(
                    items,
                    itemWidth,
                    fabSize,
                    itemSpacing,
                    itemIconSize,
                    barHeight,
                  ),
                );
              }),
            ),
          ),

          // Center FAB - Properly centered with accessibility
          Positioned(
            left: (screenWidth - fabSize) / 2,
            top: -fabSize * 0.40,
            child: Semantics(
              label: 'Center action button',
              button: true,
              child: GestureDetector(
                onTap: onCenterTap,
                child: Container(
                  height: fabSize,
                  width: fabSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2C2E65),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/whatsapp_1.png',
                      height: fabIconSize,
                      width: fabIconSize,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('FAB Image load error: $error');
                        return Icon(
                          Icons.chat_bubble_outline,
                          size: fabIconSize,
                          color: const Color(0xFF2C2E65),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavItems(
      List<BottomNavItem> items,
      double itemWidth,
      double fabSize,
      double itemSpacing,
      double itemIconSize,
      double barHeight,
      ) {
    List<Widget> navWidgets = [];

    for (var item in items) {
      if (item.isSpacer) {
        navWidgets.add(SizedBox(width: fabSize + itemSpacing * 2));
      } else {
        // Safe null check for currentPage
        final currentPageValue = controller.currentPage.value;
        final isSelected = currentPageValue == item.index;

        final iconColor = isSelected
            ? (item.selectedColor ?? const Color(0xFF2C2E65))
            : (item.unselectedColor ?? Colors.grey.shade600);
        final textColor = isSelected
            ? (item.selectedTextColor ?? const Color(0xFF2C2E65))
            : (item.unselectedTextColor ?? Colors.grey.shade600);

        navWidgets.add(
          _NavItem(
            item: item,
            isSelected: isSelected,
            iconColor: iconColor,
            textColor: textColor,
            itemWidth: itemWidth,
            itemIconSize: itemIconSize,
            barHeight: barHeight,
            onTap: () {
              try {
                controller.changePage(item.index);
              } catch (e) {
                debugPrint('Error changing page: $e');
              }
            },
          ),
        );
      }
    }

    return navWidgets;
  }
}

// ----------------------------- Nav Item Widget -----------------------------
class _NavItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final Color iconColor;
  final Color textColor;
  final double itemWidth;
  final double itemIconSize;
  final double barHeight;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.iconColor,
    required this.textColor,
    required this.itemWidth,
    required this.itemIconSize,
    required this.barHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: item.label,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: itemWidth,
          padding: EdgeInsets.only(top: barHeight * 0.15, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              const SizedBox(height: 4),
              _buildLabel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    // Validate asset path
    if (item.imagePath.isEmpty) {
      debugPrint('NavItem: Empty image path for ${item.label}');
      return Icon(
        Icons.error_outline,
        size: itemIconSize,
        color: iconColor,
      );
    }

    return SvgPicture.asset(
      item.imagePath,
      height: itemIconSize,
      width: itemIconSize,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      fit: BoxFit.contain,
      placeholderBuilder: (context) => SizedBox(
        height: itemIconSize,
        width: itemIconSize,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(iconColor),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel() {
    if (item.label.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      item.label,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: (item.fontSize + 1).clamp(9.0, 14.0),
        color: textColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        height: 1.1,
      ),
    );
  }
}

// ----------------------------- Bottom Bar Outline Painter -----------------------------
class _BottomBarOutlinePainter extends CustomPainter {
  final double fabRadius;
  final double curveDepth;
  final double curveRadius;
  final double barHeight;

  const _BottomBarOutlinePainter({
    required this.fabRadius,
    required this.curveDepth,
    required this.curveRadius,
    required this.barHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Validate size
    if (size.width <= 0 || size.height <= 0) {
      debugPrint('BottomBarPainter: Invalid size');
      return;
    }

    // Fill background
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Outline paint with antialiasing
    final outlinePaint = Paint()
      ..color = const Color(0xFF2C2E65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    try {
      final fillPath = _createFillPath(size);
      final outlinePath = _createOutlinePath(size);

      // Draw fill first, then outline (only top and sides)
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(outlinePath, outlinePaint);
    } catch (e) {
      debugPrint('Error painting bottom bar: $e');
    }
  }

  Path _createFillPath(Size size) {
    final path = Path();
    final double centerX = size.width / 2;
    final double cornerRadius = curveRadius.clamp(0.0, size.height / 2);

    // Start from top-left corner
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // Calculate curve positions with bounds checking
    final leftCurveStart = (centerX - fabRadius - cornerRadius).clamp(cornerRadius, size.width - cornerRadius);
    path.lineTo(leftCurveStart, 0);

    // Left side of center curve
    path.quadraticBezierTo(
      centerX - fabRadius - cornerRadius * 0.5,
      0,
      centerX - fabRadius,
      curveDepth * 0.3,
    );

    // Center curve (deep curve for FAB)
    path.cubicTo(
      centerX - fabRadius * 0.5,
      curveDepth,
      centerX + fabRadius * 0.5,
      curveDepth,
      centerX + fabRadius,
      curveDepth * 0.3,
    );

    // Right side of center curve
    path.quadraticBezierTo(
      centerX + fabRadius + cornerRadius * 0.5,
      0,
      centerX + fabRadius + cornerRadius,
      0,
    );

    // Top edge to top-right corner
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    // Complete the shape
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  Path _createOutlinePath(Size size) {
    final path = Path();
    final double centerX = size.width / 2;
    final double cornerRadius = curveRadius.clamp(0.0, size.height / 2);

    // Start from bottom left (no line here, just positioning)
    path.moveTo(0, size.height);

    // Left side up to corner
    path.lineTo(0, cornerRadius);

    // Top-left corner
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // Top edge to left of center curve
    final leftCurveStart = (centerX - fabRadius - cornerRadius).clamp(cornerRadius, size.width - cornerRadius);
    path.lineTo(leftCurveStart, 0);

    // Smooth transition into center curve
    path.quadraticBezierTo(
      centerX - fabRadius - cornerRadius * 0.5,
      0,
      centerX - fabRadius,
      curveDepth * 0.3,
    );

    // Center curve (deep curve for FAB)
    path.cubicTo(
      centerX - fabRadius * 0.5,
      curveDepth,
      centerX + fabRadius * 0.5,
      curveDepth,
      centerX + fabRadius,
      curveDepth * 0.3,
    );

    // Smooth transition out of center curve
    path.quadraticBezierTo(
      centerX + fabRadius + cornerRadius * 0.5,
      0,
      centerX + fabRadius + cornerRadius,
      0,
    );

    // Top edge to top-right corner
    path.lineTo(size.width - cornerRadius, 0);

    // Top-right corner
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    // Right side down to bottom (stops at bottom, no line drawn at bottom)
    path.lineTo(size.width, size.height);

    return path;
  }

  @override
  bool shouldRepaint(covariant _BottomBarOutlinePainter oldDelegate) =>
      oldDelegate.fabRadius != fabRadius ||
          oldDelegate.curveDepth != curveDepth ||
          oldDelegate.curveRadius != curveRadius ||
          oldDelegate.barHeight != barHeight;
}