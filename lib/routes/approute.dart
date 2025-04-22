import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mtag_flutterapp/pages/login/auth_page.dart';
import 'package:mtag_flutterapp/pages/login/create_pin_page.dart';
import 'package:mtag_flutterapp/pages/notification/notification_withintent.dart';
import '../../constants/other_consts.dart';
import '../../maintenance/maintenance_screen.dart';
import '../../pages/dashboard/home_page.dart';

import '../../pages/notification/notification_screen.dart';
import '../../pages/privacy/privacy_policy_screen.dart';
import '../../pages/receipt/receipt_screen.dart';
import '../pages/alfawebview/alfla_webview_mastercard.dart';
import '../pages/login/forget_pin_page.dart';
import '../pages/recharge/recharge_page.dart';
import '../pages/recharge/select_mtag.dart';
import '../../pages/smsalert/sms_alert_screen.dart';
import '../../pages/faqs/faqs_screen.dart';
import '../../pages/editprofile/edit_profile_screen.dart';
import '../../pages/feedback/feedback_screen.dart';
import '../../pages/mtag/mtag_detail_screen.dart';
import '../../pages/settings/setting_screen.dart';

import '../../pages/tollhistory/toll_history_screen.dart';
import '../../pages/mtag/mtag_screen.dart';
import '../../pages/notification/notification_expand_screen.dart';
import '../pages/tolcalator/toll_calculator_local_tabs.dart';

List<GetPage<dynamic>>? getPages = [
  GetPage(
    name: '/',
    page: () => HomePage(),
  ),
  GetPage(
    name: '/notificationsExpandScreen',
    page: () => NotificationsExpandScreen(),
  ),
  GetPage(
    name: '/receipt',
    page: () => ReceiptScreen(),
  ),
  GetPage(
    name: '/alflahwebview',
    page: () => OtherConsts().emergencySwitchProd.value == '1'
        ? MaintenanceScreen()
        : const AlfaWebView2(),
  ),
  GetPage(
    name: '/notifications',
    page: () => NotificationScreen(),
  ),
  GetPage(
    name: '/smsAlert',
    page: () => const SMSAlertScreen(),
  ),
  GetPage(
    name: '/privacyPolicy',
    page: () => const PrivacyPolicyScreen(),
  ),
  GetPage(
    name: '/faqs',
    page: () => FaqsScreen(),
  ),
  GetPage(
    name: '/tollCalculator',
    // page: () => const TollCalculatorLocal(),
    page: () => const TollCalculatorLocalTabs(),
  ),
  GetPage(
    name: '/maintenancePage',
    page: () => const MaintenanceScreen(),
  ),
  GetPage(
    name: '/dashboard',
    page: () => HomePage(),
  ),
  GetPage(
    name: '/tollHostory',
    page: () => const TollHistoryPage(),
  ),
  GetPage(
    name: '/recharge',
    page: () => RechargeSelfPage(),
  ),
  GetPage(
    name: '/selectrecharge',
    page: () => SelectMtag(onChange: (p0) {}),
  ),
  GetPage(
    name: '/mTag',
    page: () => MyMtagScreen(),
  ),
  GetPage(
    name: '/settings',
    page: () => SettingScreen(),
  ),
  GetPage(
    name: '/auth',
    page: () => AuthPage(),
  ),
  GetPage(
    name: '/pinPage',
    page: () => PinEntryPage(),
  ),
  GetPage(name: '/forgetPin', page: () => ForgetPinPage()),
  GetPage(
    name: '/mtagDetails',
    page: () => MatagDetailScreen(),
  ),
  GetPage(
    name: '/editProfile',
    page: () => EditProfileScreen(),
  ),
  GetPage(
    name: '/feedback',
    page: () => FeedBackScreen(),
  ),
  GetPage(
    name: '/notificationIntent',
    page: () => NotificationWithintent(),
  ),
];
