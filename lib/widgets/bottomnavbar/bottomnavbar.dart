import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final bool canRefresh;
  final VoidCallback? onRefreshDashboard;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.canRefresh = false,
    this.onRefreshDashboard,
  });

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double barHeight = deviceHeight * 0.085;

    return SafeArea(
      top: false,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: barHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, 0, "assets/home_b.svg", "Home"),
                _buildNavItem(context, 1, "assets/promotion.svg", "Promotions"),

                const SizedBox(width: 60),

                _buildNavItem(context, 3, "assets/allert.svg", "Notifications"),
                _buildNavItem(context, 4, "assets/user.svg", "Profile"),
              ],
            ),
          ),

          Positioned(
            top: -30,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: barHeight * 0.9,
                width: barHeight * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00296B), Color(0xFF8A2E87)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/location.svg',
                    height: barHeight * 0.39,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String icon,
    String label,
  ) {
    int correctedIndex = index > 2 ? index - 1 : index;

    bool isSelected = currentIndex == correctedIndex;

    return GestureDetector(
      onTap: () {
        if (index == 0 && canRefresh && onRefreshDashboard != null) {
          onRefreshDashboard!();
        }

        onTap(correctedIndex);
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColorLight
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.25 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: SvgPicture.asset(
                icon,
                height: isSelected ? 30 : 24,
                width: isSelected ? 30 : 24,
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
            ),

            const SizedBox(height: 3),

            AnimatedOpacity(
              opacity: isSelected ? 1 : 0.6,
              duration: const Duration(milliseconds: 150),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isSelected ? 13 : 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : Colors.grey.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
