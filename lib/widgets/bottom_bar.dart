import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final Color selectedColor;
  final Color unselectedColor;
  final Color backgroundColor;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      backgroundColor: backgroundColor,
      iconSize: 20,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Poppins',
        color: selectedColor,
      ),
      unselectedIconTheme: IconThemeData(color: unselectedColor),
      items: items,
    );
  }
}
