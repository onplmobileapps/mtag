import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BuilAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkTheme;
  final VoidCallback onSupportTap;
  final VoidCallback onSmsTap;
  final ValueNotifier<int> badgeCountNotifier;
  final VoidCallback onNotificationTap;

  const BuilAppBarWidget({
    super.key,
    required this.isDarkTheme,
    required this.onSupportTap,
    required this.onSmsTap,
    required this.badgeCountNotifier,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Image.asset(
          'assets/darklogo.png',
          height: 50,
          width: 50,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      actions: [
        const SizedBox(width: 8),
        // _buildIconAction(
        //   context,
        //   assetPath: 'assets/helpline.svg',
        //   onTap: onSupportTap,
        //   isDarkTheme: isDarkTheme,
        // ),
        const SizedBox(width: 8),
        _buildIconAction(
          context,
          assetPath: 'assets/sms.svg',
          onTap: onSmsTap,
          isDarkTheme: isDarkTheme,
        ),
        const SizedBox(width: 4),
        _buildNotificationBadge(context),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildIconAction(
    BuildContext context, {
    required String assetPath,
    required VoidCallback onTap,
    required bool isDarkTheme,
  }) {
    return InkWell(
      onTap: onTap,
      child: SvgPicture.asset(
        assetPath,
        height: 25,
        width: 20,
        colorFilter: ColorFilter.mode(Theme.of(context).focusColor, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildNotificationBadge(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: badgeCountNotifier,
      builder: (context, value, child) {
        return InkWell(
          onTap: onNotificationTap,
          child: Badge.count(
            padding: EdgeInsets.zero,
            count: value,
            child: Icon(
              Icons.notifications_outlined,
              size: 28,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
