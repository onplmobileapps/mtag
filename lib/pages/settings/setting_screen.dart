import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/app_data.dart';
import '../../controller/home_controller.dart';
import '../../widgets/dialog/change_pin_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../api/auth_controller.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_appbar.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen({super.key});

  final navigatorKey = GlobalKey<NavigatorState>();
  final homeController = Get.find<HomeController>();

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Widget _buildSettingsListItem(int index, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          onTap: items[index].onTap,
          horizontalTitleGap: 8.0,
          dense: true,
          leading: items[index].icon,
          title: Text(
            items[index].name ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 18,
          ),
        ),
        const Divider(thickness: .5, height: 1.5, color: Colors.grey),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(title: Text('Settings')),

      body: Container(
        constraints: const BoxConstraints.expand(),
        color: Theme.of(context).primaryColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            gradient: Theme.of(context).extension<AppGradients>()!.background,
            borderRadius: const BorderRadiusDirectional.only(),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5),
                        Container(
                          padding: .all(16),
                          decoration: BoxDecoration(
                            shape: .circle,
                            gradient: Theme.of(
                              context,
                            ).extension<AppGradients>()!.verticalFade,
                          ),

                          child: Text(
                            getInitials(
                              homeController
                                      .dashboradData
                                      .value
                                      .customerDetail
                                      ?.fullName ??
                                  "",
                            ),
                            style: TextTheme.of(context).headlineLarge,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          homeController
                                  .dashboradData
                                  .value
                                  .customerDetail
                                  ?.fullName ??
                              "",
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconTextInfo(
                              icon: Icons.contact_mail_outlined,
                              text:
                                  homeController
                                      .dashboradData
                                      .value
                                      .customerDetail
                                      ?.cNIC ??
                                  "",
                            ),
                            Container(
                              height: 15,
                              width: 1.5,
                              color: Colors.grey,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            IconTextInfo(
                              icon: Icons.call_outlined,
                              text:
                                  homeController
                                      .dashboradData
                                      .value
                                      .customerDetail
                                      ?.mobileNumber ??
                                  "",
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _buildSettingsListItem(index, context),
                ),
              ),
              FutureBuilder<String>(
                future: _getAppVersion(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        'Version ${snapshot.data}',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.w100),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsModel {
  String? name, routeName;
  Icon? icon;
  Function()? onTap;

  SettingsModel({
    required this.icon,
    required this.name,
    required this.routeName,
    required this.onTap,
  });
}

final List<SettingsModel> items = [
  SettingsModel(
    onTap: () {
      Get.bottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            gradient: Theme.of(
              Get.context!,
            ).extension<AppGradients>()!.background,
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  onTap: () {
                    Get.changeThemeMode(ThemeMode.system);
                    AppData.setThemeMode(null);
                    Get.back();
                  },
                  dense: true,
                  leading: const Icon(Icons.phone_android_outlined),
                  title: const Text('System Default'),
                ),
                const Divider(),
                ListTile(
                  onTap: () {
                    Get.changeThemeMode(ThemeMode.light);
                    Get.changeTheme(appTheme);
                    AppData.setThemeMode(false);
                    Get.back();
                  },
                  dense: true,
                  leading: const Icon(Icons.light_mode_outlined),
                  title: const Text('Light Mode'),
                ),
                const Divider(),
                ListTile(
                  onTap: () {
                    Get.changeThemeMode(ThemeMode.dark);
                    Get.changeTheme(darkTheme);
                    AppData.setThemeMode(true);
                    Get.back();
                  },
                  dense: true,
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode'),
                ),
              ],
            ),
          ),
        ),
      );
    },
    name: 'Dark/Light Mode',
    icon: const Icon(Icons.light_mode_outlined),
    routeName: '/theme',
  ),
  SettingsModel(
    onTap: () {
      Get.toNamed('/smsAlert');
    },
    name: 'Travel SMS Alert',
    icon: const Icon(Icons.sms_outlined),
    routeName: '/theme',
  ),
  SettingsModel(
    onTap: () {
      Get.toNamed('/notifications');
    },
    name: 'Notifications',
    icon: const Icon(Icons.notifications_on_outlined),
    routeName: '/notifications',
  ),

  SettingsModel(
    onTap: () {
      Get.toNamed('/feedback');
    },
    name: 'Help & Feedback',
    icon: const Icon(Icons.help_outline),
    routeName: '/theme',
  ),
  SettingsModel(
    onTap: () {
      showChangePinDialog(Get.context!, onSubmit: (oldPin, newPin) {});
    },
    name: 'Change PIN',
    icon: const Icon(Icons.password_outlined),
    routeName: '',
  ),
  SettingsModel(
    onTap: () {
      Get.toNamed('/faqs');
    },
    name: 'FAQ\'s',
    icon: const Icon(Icons.quiz_outlined),
    routeName: '/theme',
  ),
  SettingsModel(
    onTap: () {
      Get.toNamed('/privacyPolicy');
    },
    name: 'Privacy Policy',
    icon: const Icon(Icons.privacy_tip_outlined),
    routeName: '/theme',
  ),
  SettingsModel(
    onTap: () {
      final box = Get.context!.findRenderObject() as RenderBox?;
      if (box != null) {
        String shareLinks =
            "Get the M-Tag One Network Application now for exciting features\n"
            "Android: https://bit.ly/3nLrHNX\n"
            "IOS: https://apple.co/3byIb6c\n"
            "Huawei: https://bit.ly/3IFgzLf";
        SharePlus.instance.share(
          ShareParams(
            text: shareLinks,
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
          ),
        );
      }
    },
    name: 'Share',
    icon: const Icon(Icons.share_outlined),
    routeName: '/theme',
  ),
  SettingsModel(
    onTap: () {
      showCupertinoModalPopup(
        context: Get.context!,
        builder: (_) => CupertinoAlertDialog(
          content: const Text('Do you want to logout?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Confirm'),
              onPressed: () {
                Get.delete<HomeController>(force: true);
                Get.find<AuthController>().clearSharedData()
                    ? Get.offNamedUntil('/pinPage', (v) => false)
                    : Get.back();
              },
            ),
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      );
    },
    name: 'Logout',
    icon: const Icon(Icons.login),
    routeName: '/theme',
  ),
];

String getInitials(String fullName) {
  if (fullName.trim().isNotEmpty) {
    var nameParts = fullName.trim().split(RegExp(r'\s+'));
    if (nameParts.isNotEmpty) {
      var firstNameInitial = nameParts[0][0].toUpperCase();
      var secondNameInitial = nameParts.length > 1
          ? nameParts[1][0].toUpperCase()
          : '';
      if (secondNameInitial.isNotEmpty) {
        return '$firstNameInitial$secondNameInitial';
      } else {
        return firstNameInitial;
      }
    }
  }
  return '';
}

class IconTextInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const IconTextInfo({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w600);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 5),
        Flexible(
          child: Text(text, style: textStyle, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
