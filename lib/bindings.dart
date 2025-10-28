import 'package:get/get.dart';
import '../../controller/home_controller.dart';
import '../../pages/tolcalator/controller/toll_calculator_static_controller.dart';
import '../../api/recharge_repo.dart';
import '../../pages/activity/controller/activity_controller.dart';
import '../../pages/editprofile/controller/update_emai_controller.dart';
import '../../pages/faqs/controller/delete_account_controller.dart';
import '../../pages/mtag/controller/delink_controller.dart';
import '../../pages/notification/controller/notificationcontroller.dart';
import '../../pages/payment/controller/payment_card_controller.dart';
import '../../pages/receipt/controller/receipt_generate_controller.dart';
import '../../pages/smsalert/controller/update_sms_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/auth_controller.dart';
import 'api/auth_repo.dart';
import 'api/user_repo.dart';
import 'pages/recharge/controller/recharge_controller.dart';
import 'pages/tollhistory/controller/tollcontroller.dart';

class Binding extends Bindings {
  final SharedPreferences sharedPreferences;
  Binding(this.sharedPreferences);

  @override
  void dependencies() {
    // AuthController needs SharedPreferences immediately
    Get.put(
      AuthController(
        authRepo: AuthRepo(sharedPreferences: sharedPreferences),
      ),
      permanent: true,
    );

    // Other controllers lazy-loaded when first used
    Get.lazyPut(() => HomeController(userRepo: UserRepo()));
    Get.lazyPut(() => PaymentCardController(userRepo: RechargRepo()));
    Get.lazyPut(() => UpdateEmailController(userRepo: UserRepo()));
    Get.lazyPut(() => RechargeController(userRepo: UserRepo()));
    Get.lazyPut(() => MotorwayStaticController());
    Get.lazyPut(() => TollController(userRepo: UserRepo()));
    Get.lazyPut(() => UpdateSmsStatusController(userRepo: UserRepo()));
    Get.lazyPut(() => ActivityContorller(UserRepo()));
    Get.lazyPut(() => ReceiptController(userRepo: UserRepo()));
    Get.lazyPut(() => DelinkController(userRepo: UserRepo()));
    Get.lazyPut(() => DeleteAccountController(userRepo: UserRepo()));
    Get.lazyPut(() => NotificationController());

  }
}