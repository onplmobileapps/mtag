import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mtag_flutterapp/pages/login/auth_page.dart';
import 'package:mtag_flutterapp/pages/login/create_pin_page.dart';
import 'package:mtag_flutterapp/pages/notification/notification_withintent.dart';
import '../../constants/other_consts.dart';
import '../../maintenance/maintenance_screen.dart';
import '../features/design/home_page.dart';
import '../../pages/notification/notification_screen.dart';
import '../../pages/privacy/privacy_policy_screen.dart';
import '../../pages/receipt/receipt_screen.dart';
import '../features/recharge_center_locator.dart';
import '../features/story_view_page.dart';
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
  GetPage(name: '/', page: () => HomePage()),
  GetPage(
    name: '/notificationsExpandScreen',
    page: () => NotificationsExpandScreen(),
    popGesture: true,
  ),
  GetPage(name: '/receipt', page: () => ReceiptScreen(), popGesture: true),
  GetPage(
    name: '/alflahwebview',
    page: () => OtherConsts().emergencySwitchProd.value == '1'
        ? MaintenanceScreen()
        : const AlfaWebView2(),
    popGesture: true,
  ),
  GetPage(
    name: '/notifications',
    page: () => NotificationScreen(),
    popGesture: true,
  ),
  GetPage(
    name: '/smsAlert',
    page: () => const SMSAlertScreen(),
    popGesture: true,
  ),
  GetPage(
    name: '/privacyPolicy',
    page: () => const PrivacyPolicyScreen(),
    popGesture: true,
  ),
  GetPage(name: '/faqs', page: () => FaqsScreen(), popGesture: true),
  GetPage(
    name: '/tollCalculator',
    // page: () => const TollCalculatorLocal(),
    page: () => const TollCalculator(),
    popGesture: true,
  ),
  GetPage(
    name: '/maintenancePage',
    page: () => const MaintenanceScreen(),
    popGesture: true,
  ),
  GetPage(name: '/dashboard', page: () => HomePage(), popGesture: true),
  GetPage(
    name: '/tollHostory',
    page: () => const TollHistoryPage(),
    popGesture: true,
  ),
  GetPage(name: '/recharge', page: () => RechargeSelfPage(), popGesture: true),
  GetPage(
    name: '/selectrecharge',
    page: () => SelectMtag(onChange: (p0) {}),
    popGesture: true,
  ),
  GetPage(name: '/mTag', page: () => MyMtagScreen(), popGesture: true),
  GetPage(name: '/settings', page: () => SettingScreen(), popGesture: true),
  GetPage(name: '/auth', page: () => AuthPage(), popGesture: true),
  GetPage(name: '/pinPage', page: () => PinEntryPage(), popGesture: true),
  GetPage(name: '/forgetPin', page: () => ForgetPinPage(), popGesture: true),
  GetPage(
    name: '/mtagDetails',
    page: () => MatagDetailScreen(),
    popGesture: true,
  ),
  GetPage(
    name: '/editProfile',
    page: () => EditProfileScreen(),
    popGesture: true,
  ),
  GetPage(name: '/feedback', page: () => FeedBackScreen(), popGesture: true),
  GetPage(
    name: '/notificationIntent',
    page: () => NotificationWithintent(),
    popGesture: true,
  ),
  GetPage(
    name: '/story',
    page: () => StoryViewPage(storiesIndex: []),
    popGesture: false, // Disable swipe for this route
  ),
  GetPage(
    name: '/rechargeLocator',
    page: () => RechargeMapScreen(),
    popGesture: false, // Disable swipe for this route
  ),
];
//RechargeMapScreen
