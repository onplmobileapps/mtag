import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../api/auth_controller.dart';
import '../../base/app_data.dart';
import '../../controller/home_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/dialog/change_pin_dialog.dart';
import '../../widgets/dialog/operator_selection_dialog.dart';
import '../../widgets/dialog/support_dialog.dart';
import '../../widgets/gradient_appbar.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final HomeController homeController = Get.find<HomeController>();

  Future<String> _getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  void _handleBackNavigation() {
    final authController = Get.find<AuthController>();
    if (authController.isLogedIn() == true) {
      Get.find<HomeController>().currentPage.value = 0;
    } else {
      Get.back();
    }
  }

  void _shareApp() {
    final box = context.findRenderObject() as RenderBox?;
    SharePlus.instance.share(
      ShareParams(
        text: '''Get the M-Tag One Network Application now\n
      Android: https://bit.ly/3nLrHNX\n
      iOS: https://apple.co/3byIb6c",''',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  void _handleLogout() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        content: const Text('Do you want to logout?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Get.delete<HomeController>(force: true);
              Get.find<AuthController>().clearSharedData()
                  ? Get.offAllNamed('/pinPage')
                  : Get.back();
            },
            child: const Text('Logout'),
          ),
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = homeController.dashboradData.value.customerDetail;
    final bool isDarkMode = AppData.theme ?? false;

    return AnimatedTheme(
      data: isDarkMode ? darkTheme : appTheme,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, _) => _handleBackNavigation(),
        child: Scaffold(
          appBar: GradientAppBar(
            title: const Text('Settings'),
            showBackButton: true,
            onBackPressed: _handleBackNavigation,
          ),
          body: Column(
            children: [
              _ProfileCard(customer: customer),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      _SectionCard(
                        title: 'General',
                        isDarkMode: isDarkMode,
                        children: [
                          _ThemeSwitchTile(
                            isDark: isDarkMode,
                            onChanged: (val) {
                              if (val) {
                                Get.changeThemeMode(ThemeMode.dark);
                                Get.changeTheme(darkTheme);
                                AppData.setThemeMode(true);
                              } else {
                                Get.changeThemeMode(ThemeMode.light);
                                Get.changeTheme(appTheme);
                                AppData.setThemeMode(false);
                              }
                              setState(() {});
                            },
                          ),
                          _SettingsTile(
                            icon: Icons.sms_outlined,
                            title: 'Travel SMS Alerts',
                            onTap: () => Get.toNamed('/smsAlert'),
                          ),
                          _SettingsTile(
                            icon: Icons.notifications_on_outlined,
                            title: 'Notifications',
                            onTap: () => Get.toNamed('/notifications'),
                          ),
                          _SettingsTile(
                            icon: Icons.password_outlined,
                            title: 'Change PIN',
                            onTap: () => showChangePinDialog(
                              context,
                              onSubmit: (_, _) {},
                            ),
                          ),
                          _SettingsTile(
                            icon: Icons.sim_card_outlined,
                            title: 'Change SIM Operator',
                            onTap: () {
                              OperatorSelectionDialog.show(
                                Get.context!,
                                (value) {
                                  Get.find<AuthController>()
                                      .sendNetworkOperator(
                                        cnicNumber: customer?.cNIC ?? '',
                                        mobileNum: customer?.mobileNumber ?? '',
                                        simOperator: value,
                                      );
                                },
                                mobileNumber: customer?.mobileNumber ?? '',
                              );
                            },
                          ),
                        ],
                      ),
                      _SectionCard(
                        title: 'Support',
                        isDarkMode: isDarkMode,
                        children: [
                          _SettingsTile(
                            icon: Icons.headset_mic_outlined,
                            title: 'Quick Support',
                            onTap: () => SupportDialog.show(context),
                          ),
                          _SettingsTile(
                            icon: Icons.quiz_outlined,
                            title: 'FAQ’s',
                            onTap: () => Get.toNamed('/faqs'),
                          ),
                          _SettingsTile(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () => Get.toNamed('/privacyPolicy'),
                          ),
                        ],
                      ),
                      _SectionCard(
                        title: 'Others',
                        isDarkMode: isDarkMode,
                        children: [
                          _SettingsTile(
                            icon: Icons.share_outlined,
                            title: 'Share App',
                            onTap: _shareApp,
                          ),
                          FutureBuilder<String>(
                            future: _getAppVersion(),
                            builder: (_, snap) => _SettingsTile(
                              icon: Icons.info_outline,
                              title: 'App Version',
                              trailing: snap.data ?? '...',
                              showArrow: false,
                              onTap: () {},
                            ),
                          ),
                          _SettingsTile(
                            icon: Icons.logout_outlined,
                            title: 'Logout',
                            onTap: _handleLogout,
                            titleColor: Colors.redAccent,
                            iconColor: Colors.redAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final dynamic customer;

  const _ProfileCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              child: Text(
                getInitials(customer?.fullName ?? ''),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer?.fullName ?? '',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconTextInfo(
                      icon: Icons.contact_mail_outlined,
                      text: customer?.cNIC ?? "",
                    ),
                    Container(
                      height: 15,
                      width: 1.5,
                      color: Colors.grey,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    IconTextInfo(
                      icon: Icons.call_outlined,
                      text: customer?.mobileNumber ?? "",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isDarkMode;

  const _SectionCard({
    required this.title,
    required this.children,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDarkMode
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            gradient: Theme.of(context).extension<AppGradients>()?.background,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    indent: 45,
                    endIndent: 16,
                    height: 1,
                    thickness: 0.3,
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;
  final bool showArrow;
  final Color? titleColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.showArrow = true,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      dense: true,
      leading: Icon(icon, color: iconColor ?? (isDark ? Colors.white70 : null)),
      horizontalTitleGap: 12,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? (isDark ? Colors.white : Colors.black87),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          if (showArrow) ...[
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

class _ThemeSwitchTile extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ThemeSwitchTile({required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(
        isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
        color: isDark ? const Color(0xFF5C79FF) : Colors.orangeAccent,
      ),
      horizontalTitleGap: 12,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: SizedBox(
          key: ValueKey(isDark),
          width: double.infinity,
          child: Text(
            isDark ? 'Dark Mode' : 'Light Mode',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      trailing: GestureDetector(
        onTap: () => onChanged(!isDark),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutBack,
          width: 58,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: isDark ? const Color(0xFF1E1E2C) : const Color(0xFFE0E0E0),
            border: Border.all(
              color: isDark
                  ? Colors.blueAccent.withValues(alpha: 0.5)
                  : Colors.black12,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutBack,
                alignment: isDark
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF5C79FF) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.blueAccent.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          isDark
                              ? Icons.nightlight_round
                              : Icons.wb_sunny_rounded,
                          key: ValueKey(isDark),
                          size: 14,
                          color: isDark ? Colors.white : Colors.orangeAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String getInitials(String fullName) {
  if (fullName.trim().isEmpty) return '';
  final parts = fullName.trim().split(RegExp(r'\s+'));
  final first = parts.first[0].toUpperCase();
  final second = parts.length > 1 ? parts[1][0].toUpperCase() : '';
  return '$first$second';
}

class IconTextInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const IconTextInfo({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.displayMedium?.copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.0, color: Colors.white),
        const SizedBox(width: 5),
        Flexible(
          child: Text(text, style: textStyle, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
