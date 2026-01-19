import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';


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
    if (items.isEmpty) {
      debugPrint('NewBottomBar: No items provided');
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.colorScheme.surface;
    final outlineColor = isDark
        ? theme.colorScheme.outlineVariant
        : const Color(0xFF2C2E65);
    final primaryColor = theme.colorScheme.primary;
    final unselectedColor = isDark
        ? Colors.grey.shade400
        : Colors.grey.shade600;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final barHeight = (screenHeight * 0.10).clamp(65.0, 85.0);
    final fabSize = barHeight * 0.75;

    final itemIconSize = barHeight * 0.35;
    final curveRadius = barHeight * 0.25;
    final fabCurveRadius = fabSize * 0.65;
    final curveDepth = barHeight * 0.60;

    final nonSpacerItems = items.where((i) => !i.isSpacer).length;
    final horizontalPadding = 12.0;
    final availableWidth = screenWidth - (horizontalPadding * 2);
    final itemWidth =
        (availableWidth - fabSize) / (nonSpacerItems > 0 ? nonSpacerItems : 1);

    return Container(
     
      clipBehavior: Clip.none,
      height: barHeight,
      width: screenWidth,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(screenWidth, barHeight),
          painter: _BottomBarOutlinePainter(
            fabRadius: fabCurveRadius,
            curveDepth: curveDepth,
            curveRadius: curveRadius,
            backgroundColor: backgroundColor,
            outlineColor: outlineColor,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildNavItems(
                  items,
                  itemWidth,
                  itemIconSize,
                  primaryColor,
                  unselectedColor,
                  barHeight,
                  fabSize,
                  screenWidth,
                  horizontalPadding,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(
    List<BottomNavItem> items,
    double itemWidth,
    double itemIconSize,
    Color primaryColor,
    Color defaultUnselected,
    double barHeight,
    double fabSize,
    double screenWidth,
    double horizontalPadding,
  ) {
    final List<Widget> navWidgets = [];
    final int itemCount = items.length;

    for (int i = 0; i < itemCount; i++) {
      final item = items[i];
      final isSelected = controller.currentPage.value == item.index;
      final color = isSelected
          ? (item.selectedColor ?? primaryColor)
          : (item.unselectedColor ?? defaultUnselected);

      navWidgets.add(
        _NavItem(
          item: item,
          isSelected: isSelected,
          color: color,
          itemWidth: itemWidth,
          itemIconSize: itemIconSize,
          barHeight: barHeight,
          onTap: () => controller.changePage(item.index),
        ),
      );

      if (i == itemCount ~/ 2 - 1) {
        navWidgets.add(
          SizedBox(
            width: fabSize,
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: double.infinity,
              child: Transform.translate(
                offset: Offset(0, -fabSize * 0.48),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onCenterTap,
                  child: Container(
                    width: fabSize,
                    height: fabSize,
                    decoration: BoxDecoration(
                      color: ColorScheme.of(Get.context!).surface,
                      shape: BoxShape.circle,
                      border: Border.all(width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/whatsapp_1.png',
                        height: 50,
                        width: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.chat_bubble_outline),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return navWidgets;
  }
}

class _NavItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final Color color;
  final double itemWidth;
  final double itemIconSize;
  final double barHeight;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.color,
    required this.itemWidth,
    required this.itemIconSize,
    required this.barHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: itemWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: barHeight * 0.5,
              padding: EdgeInsets.only(
                top: barHeight * 0.1,
                bottom: barHeight * 0.05,
              ),
              child: SvgPicture.asset(
                item.imagePath,
                height: itemIconSize,
                width: itemIconSize,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(
              height: barHeight * 0.35,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarOutlinePainter extends CustomPainter {
  final double fabRadius;
  final double curveDepth;
  final double curveRadius;
  final Color backgroundColor;
  final Color outlineColor;

  const _BottomBarOutlinePainter({
    required this.fabRadius,
    required this.curveDepth,
    required this.curveRadius,
    required this.backgroundColor,
    required this.outlineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final path = _createPath(size);

    canvas.drawPath(path, fillPaint);

    final outlinePath = _createOutlinePath(size);
    canvas.drawPath(outlinePath, outlinePaint);
  }

  Path _createPath(Size size) {
    final path = Path();
    final double centerX = size.width / 2;
    final double cornerRadius = curveRadius;

    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    final leftCurveStart = centerX - fabRadius - cornerRadius;
    path.lineTo(leftCurveStart, 0);

    path.quadraticBezierTo(
      centerX - fabRadius - cornerRadius * 0.5,
      0,
      centerX - fabRadius,
      curveDepth * 0.3,
    );

    path.cubicTo(
      centerX - fabRadius * 0.5,
      curveDepth,
      centerX + fabRadius * 0.5,
      curveDepth,
      centerX + fabRadius,
      curveDepth * 0.3,
    );

    path.quadraticBezierTo(
      centerX + fabRadius + cornerRadius * 0.5,
      0,
      centerX + fabRadius + cornerRadius,
      0,
    );

    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  Path _createOutlinePath(Size size) {
    final path = Path();
    final double centerX = size.width / 2;
    final double cornerRadius = curveRadius;

    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    final leftCurveStart = centerX - fabRadius - cornerRadius;
    path.lineTo(leftCurveStart, 0);

    path.quadraticBezierTo(
      centerX - fabRadius - cornerRadius * 0.5,
      0,
      centerX - fabRadius,
      curveDepth * 0.3,
    );

    path.cubicTo(
      centerX - fabRadius * 0.5,
      curveDepth,
      centerX + fabRadius * 0.5,
      curveDepth,
      centerX + fabRadius,
      curveDepth * 0.3,
    );

    path.quadraticBezierTo(
      centerX + fabRadius + cornerRadius * 0.5,
      0,
      centerX + fabRadius + cornerRadius,
      0,
    );

    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    return path;
  }

  @override
  bool shouldRepaint(covariant _BottomBarOutlinePainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.outlineColor != outlineColor;
}
