import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mtag_flutterapp/pages/notification/notification_withintent.dart';
import '../../constants/other_consts.dart';
import '../../maintenance/maintenance_screen.dart';
import '../../pages/alfawebview/alfla_webview.dart';
import '../../pages/dashboard/home_page.dart';
import '../../pages/payment/payment_cards_screen.dart';
import '../../pages/payment/payment_cards_screen_mastercard.dart';
import '../../pages/notification/notification_screen.dart';
import '../../pages/privacy/privacy_policy_screen.dart';
import '../../pages/receipt/receipt_screen.dart';
import '../../pages/recharge/recharge_screen.dart';
import '../pages/alfawebview/alfla_webview_mastercard.dart';
import '../pages/recharge/recharge_new_design.dart';
import '../pages/recharge/select_mtag.dart';
import '../../pages/smsalert/sms_alert_screen.dart';
import '../../pages/faqs/faqs_screen.dart';
import '../../pages/editprofile/edit_profile_screen.dart';
import '../../pages/feedback/feedback_screen.dart';
import '../../pages/login/login_screen.dart';
import '../../pages/mtag/mtag_detail_screen.dart';
import '../../pages/otp/otp_screen.dart';
import '../../pages/register/register_screen.dart';
import '../../pages/settings/setting_screen.dart';
import '../../pages/tolcalator/tolcalculator_screen.dart';
import '../../pages/tollhistory/toll_history_screen.dart';
import '../../pages/mtag/mtag_screen.dart';
import '../../pages/notification/notification_expand_screen.dart';

List<GetPage<dynamic>>? getPages = [
  GetPage(
    name: '/',
    page: () => HomePage(),
  ),
  GetPage(
    name: '/rechargeSelf',
    page: () => RechargeSelfPage(),
  ),
  // GetPage(
  //   name: '/welcome',
  //   page: () => const WelcomeScreen(),
  // ),
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
    page: () => OtherConsts().emergencySwitchProd.value == '1' ? const AlfaWebView() : const AlfaWebView2(),
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
    page: () => const TolCalCulatorScreen(),
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
    page: () => RechargePage(),
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
    name: '/payment',
    page: () =>
        OtherConsts().emergencySwitchProd.value == '1' ? const PaymentCardsScreen() : const PaymentCardsScreen2(),
  ),
  GetPage(
    name: '/otp',
    page: () => const OTPScreen(),
  ),
  GetPage(
    name: '/login',
    page: () => LoginScreen(),
  ),
  GetPage(
    name: '/signUp',
    page: () => SignUpScreen(),
  ),
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
