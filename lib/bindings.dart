import 'package:get/get.dart';

import '../../pages/editprofile/controller/update_emai_controller.dart';
import '../../pages/faqs/controller/delete_account_controller.dart';
import '../../pages/mtag/controller/delink_controller.dart';
import '../../pages/notification/controller/notificationcontroller.dart';
import '../../pages/payment/controller/payment_card_controller.dart';
import '../../pages/receipt/controller/receipt_generate_controller.dart';
import '../../pages/recharge/controller/recharge_controller.dart';
import '../../pages/smsalert/controller/update_sms_controller.dart';
import '../../pages/tolcalator/controller/toll_calculator_static_controller.dart';
import '../../pages/tollhistory/controller/tollcontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/auth_controller.dart';
import 'api/auth_repo.dart';
import 'api/recharge_repo.dart';
import 'api/user_repo.dart';
import 'controller/home_controller.dart';

class Binding extends Bindings {
  final SharedPreferences sharedPreferences;

  Binding(this.sharedPreferences);

  @override
  void dependencies() {
    Get.lazyPut(
      () => AuthController(
        authRepo: AuthRepo(sharedPreferences: sharedPreferences),
      ),
      fenix: true,
    );

    Get.lazyPut(() => HomeController(userRepo: UserRepo()), fenix: true);
    Get.lazyPut(
      () => PaymentCardController(userRepo: RechargRepo()),
      fenix: true,
    );
    Get.lazyPut(() => UpdateEmailController(userRepo: UserRepo()), fenix: true);
    Get.lazyPut(() => RechargeController(userRepo: UserRepo()), fenix: true);
    Get.lazyPut(() => MotorwayStaticController(), fenix: true);
    Get.lazyPut(() => TollController(userRepo: UserRepo()), fenix: true);
    Get.lazyPut(
      () => UpdateSmsStatusController(userRepo: UserRepo()),
      fenix: true,
    );
    // Get.lazyPut(() => ActivityContorller(UserRepo()), fenix: true);
    Get.lazyPut(() => ReceiptController(userRepo: UserRepo()), fenix: true);
    Get.lazyPut(() => DelinkController(userRepo: UserRepo()), fenix: true);
    Get.lazyPut(
      () => DeleteAccountController(userRepo: UserRepo()),
      fenix: true,
    );
    Get.lazyPut(() => NotificationController(), fenix: true);
  }
}
