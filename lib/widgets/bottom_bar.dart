import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';

class CustomBottomNavBar extends StatelessWidget {
  final HomeController controller;
  final List<BottomNavItem> items;
  final double height;
  final EdgeInsets padding;
  final double notchMargin;
  final double elevation;
  final Color? backgroundColor;

  const CustomBottomNavBar({
    super.key,
    required this.controller,
    required this.items,
    this.height = 55,
    this.padding = const EdgeInsets.only(top: 0,bottom: 0),
    this.notchMargin = 10,
    this.elevation = 10,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {

    return BottomAppBar(shadowColor: Color(0xFFFCFCFC),
      height: height,
      padding: padding,clipBehavior: .none,
      shape: const CircularNotchedRectangle(),
      notchMargin: notchMargin,surfaceTintColor: Colors.white,
      elevation: elevation,
   color: Colors.transparent,
      child: Container(decoration: BoxDecoration(  gradient: const LinearGradient(
              begin: .topLeft,
              end: AlignmentGeometry.centerRight,
              colors: [Color(0xFFE4EDFC), Color(0xFFFCFCFC), Color(0xFFEAEBFD)],
            ),),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildNavigationItems(context),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationItems(BuildContext context) {
    List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      if (item.isSpacer) {
        widgets.add(SizedBox(width: item.spacerWidth ?? 50));
      } else {
        widgets.add(
          _BottomNavItemWidget(
            item: item,
            controller: controller,
          ),
        );
      }
    }

    return widgets;
  }
}

class _BottomNavItemWidget extends StatelessWidget {
  final BottomNavItem item;
  final HomeController controller;

  const _BottomNavItemWidget({
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.currentPage.value == item.index;
      final colorScheme = Theme.of(context).colorScheme;
      final iconColor = isSelected
          ? (item.selectedColor ?? colorScheme.primary)
          : (item.unselectedColor ?? colorScheme.secondary.withAlpha(180));
      final textColor = isSelected
          ? (item.selectedColor ?? colorScheme.primary)
          : (item.unselectedColor ?? colorScheme.secondary.withAlpha(180));

      final double iconSize = item.index == 0 ? 20 : 24;

      return InkWell(
        onTap: () => controller.changePage(item.index),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: SvgPicture.asset(
                  item.imagePath,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
              SizedBox(height: item.spacing),
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      );
    });
  }
}

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
    this.iconSize = 24,
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

  factory BottomNavItem.spacer({double width = 50}) {
    return BottomNavItem(
      imagePath: '',
      label: '',
      index: -1,
      isSpacer: true,
      spacerWidth: width,
    );
  }
}