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

class SettingScreen extends StatelessWidget {
  SettingScreen({super.key});

  final navigatorKey = GlobalKey<NavigatorState>();
  final homeController = Get.find<HomeController>();

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {},
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text('Settings '),
        ),
        body: Container(
          constraints: const BoxConstraints.expand(),
          color: Theme.of(context).primaryColor,
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadiusDirectional.only(
                topEnd: Radius.circular(15),
                topStart: Radius.circular(15),
              ),
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
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              getInitials(
                                homeController
                                        .dashboradData
                                        .value
                                        .customerDetail
                                        ?.fullName ??
                                    "",
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 40,
                                fontWeight: FontWeight.w600,
                              ),
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
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            homeController
                                    .dashboradData
                                    .value
                                    .customerDetail
                                    ?.cNIC ??
                                "",
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            homeController
                                    .dashboradData
                                    .value
                                    .customerDetail
                                    ?.mobileNumber ??
                                "",
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // const Divider(thickness: 0.4),

                Expanded(
                  child: CustomScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    key: UniqueKey(),
                    shrinkWrap: true,
                    slivers: [
                      SliverList(
                        key: UniqueKey(),
                        delegate: SliverChildBuilderDelegate(
                          childCount: items.length,
                          (context, i) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                key: UniqueKey(),
                                visualDensity:
                                    VisualDensity.adaptivePlatformDensity,
                                onTap: items[i].onTap,
                                horizontalTitleGap: 6.0,
                                dense: true,
                                leading: Text(items[i].name ?? ''),
                                trailing: items[i].icon,
                              ),
                              const Divider(thickness: 0.4),
                            ],
                          ),
                        ),
                      ),
                    ],
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
        backgroundColor: Theme.of(
          Get.context!,
        ).bottomSheetTheme.backgroundColor,
        SafeArea(
          child: Wrap(
            children: [
              ListTile(
                key: UniqueKey(),
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
                key: UniqueKey(),
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
                key: UniqueKey(),
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
    icon: Icon(Icons.password_outlined),
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
      String shareLinks =
          "Get the M-Tag One Network Application now for exciting features\n"
          "Android: https://bit.ly/3nLrHNX\n"
          "IOS: https://apple.co/3byIb6c\n"
          "Huawei: https://bit.ly/3IFgzLf";
      SharePlus.instance.share(
        ShareParams(
          text: shareLinks,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        ),
      );
    },
    name: 'Share',
    icon: const Icon(Icons.share_outlined),
    routeName: '/theme',
  ),
  SettingsModel(
    onTap: () {
      showCupertinoModalPopup(
        context: navigator!.context,
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
    icon: const Icon(Icons.logout_outlined),
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
