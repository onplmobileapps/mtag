import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/pages/alfawebview/alfla_webview_mastercard.dart';
import '../../../widgets/dialog/cupertino_dialog.dart';
import '../../recharge/shared/card_shared_ui.dart';
import '/api/api_constants.dart';
import '/api/recharge_repo.dart';
import '/api/user_repo.dart';
import '/controller/home_controller.dart';
import '/pages/activity/controller/activity_controller.dart';
import '/pages/recharge/model/owner_summary_model.dart';
import '/widgets/jazzcash_loader.dart';
import '../../../widgets/dialog/recharge_summary_dialog.dart';
import '../../../api/application_url.dart';
import '../../../api/auth_controller.dart';
import '../model/payment_card_model.dart';

class PaymentCardController extends GetxController implements GetxService {
  final RechargRepo userRepo;

  PaymentCardController({required this.userRepo});

  var paymentCardModel = PaymentCardModel().obs;
  var rechargeSummaryModel = Rx<OwnerRechargeModel?>(null);

  RxBool isLoading = false.obs;

  Future<Map<String, dynamic>> getCardDetails1(String payId) async {
    isLoading(true);
    var response = await userRepo.getCardDetails1(payId: payId);
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      paymentCardModel.refresh();
      paymentCardModel.value = PaymentCardModel.fromJson(
        response[APIRESPONSE.SUCCESS],
      );
      isLoading(false);
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () {
        Get.find<AuthController>().clearSharedData();
        Get.delete<HomeController>(force: true);
        Get.offAllNamed('/pinPage');
      });

      isLoading(false);
      return response;
    }

    return response;
  }

  Future<Map<String, dynamic>> getCardDetails(String payId) async {
    var response = await userRepo.getCardDetails(payId: payId);
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      paymentCardModel.refresh();
      paymentCardModel.value = PaymentCardModel.fromJson(
        response[APIRESPONSE.SUCCESS],
      );
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () {
        Get.find<AuthController>().clearSharedData();
        Get.delete<HomeController>(force: true);
        Get.offAllNamed('/pinPage');
      });

      return {'Error': response};
    }

    return response;
  }

  Future<Map<String, dynamic>> jazzCashRecharge({
    required String? mobile,
    required String? amount,
    required String? mtagId,
  }) async {
    jazzLoader();
    var response = await userRepo.jazzCashRecharg(
      mobileNumber: mobile,
      amount: amount,
      mtagID: mtagId,
    );

    if (response.containsKey(APIRESPONSE.SUCCESS) &&
        (response[APIRESPONSE.SUCCESS]['Code'] == '000' ||
            response[APIRESPONSE.SUCCESS]['Code'] == '121')) {
      await Get.find<HomeController>().pullRefreshDashboardData();
      Get.back();
      showDialog(
        barrierDismissible: false,
        context: Get.context!,
        builder: (_) => JazzResponseDialog(
          message:
              response[APIRESPONSE.SUCCESS]['Message'] ??
              'Something went wrong',
          isSuccess: true,
          color: Colors.green,
        ),
      );
    } else if (response.isNotEmpty &&
        response.containsKey(APIRESPONSE.SUCCESS)) {
      Get.back();

      showDialog(
        context: Get.context!,
        builder: (_) => JazzResponseDialog(
          message:
              response[APIRESPONSE.SUCCESS]['Message'] ??
              'We couldn’t complete your request\n Try again or contact assistance.',
          isSuccess: false,
          color: Colors.red,
        ),
      );
    } else {
      showDialog(
        context: Get.context!,
        builder: (_) => const JazzResponseDialog(
          message:
              'We couldn’t complete your request\n Try again or contact assistance.\nTry again later.',
          isSuccess: false,
          color: Colors.red,
        ),
      );
    }

    return response;
  }

  Future<Map<String, dynamic>> deleteCardDetails({
    required String token,
    required String payId,
  }) async {
    var response = await userRepo.deleteCardDetails(token: token, payId: payId);
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      isJazzShown.value = false;
      isCardsVisible.value = false;
      showPopDialog(response[APIRESPONSE.SUCCESS]['Message'], () async {
        await Get.find<ActivityContorller>().getActivities();
        Get.back();
        Get.back();
      });
    }
    return response;
  }

  Future<Map<String, dynamic>> getPayUUID({
    String? token,
    required String mtagId,
    required String amount,
    required bool isFleet,
  }) async {
    var response = await userRepo.getPayUUID(
      token: token,
      amount: amount,
      mtagId: mtagId,
      isFleet: isFleet,
    );
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      return response;
    }
    return response;
  }

  Future<void> getRechargeSummary({
    required String mtagId,
    required String payId,
    required String amount,
    required bool isFleet,
    String? token,
  }) async {
    var response = await UserRepo().getOwnerRechargeDetails(
      mtagId: mtagId,
      amount: amount,
      payId: payId,
      isFleet: isFleet,
    );
    if (response.containsKey(APIRESPONSE.SUCCESS) &&
        response[APIRESPONSE.SUCCESS]['Code'] == "00") {
      rechargeSummaryModel.value = OwnerRechargeModel.fromJson(
        response[APIRESPONSE.SUCCESS],
      );
      showRechargeSummaryDialog(
        payId: payId,
        rechargeSummaryModel: rechargeSummaryModel.value,
        context: Get.context!,
        onPressed: () async {
          if (payId == '1') {
            Get.back();
            await Get.find<PaymentCardController>().jazzCashRecharge(
              mobile: token,
              amount: amount,
              mtagId: mtagId,
            );
            return;
          }
          var result = await Get.find<PaymentCardController>().getPayUUID(
            mtagId: mtagId,
            amount: amount,
            token: token ?? '',
            isFleet: isFleet,
          );
          log(result.toString());
          if (result.isNotEmpty && result.containsKey(APIRESPONSE.SUCCESS)) {
            Get.to(
              () => AlfaWebView2(
                isSaveCard: false,
                url:
                    "${ApplicationUrl.IMAGE_ULR}/payment/${result[APIRESPONSE.SUCCESS]['key']}",
              ),
            );
          }
        },
      );
    } else if ((response.containsKey(APIRESPONSE.SUCCESS) &&
        response[APIRESPONSE.SUCCESS]['Code'] == "03")) {
      showPopDialog(response[APIRESPONSE.SUCCESS]['Message'], () {
        Get.back();
      });
    }
  }

  Future<Map<String, dynamic>> generatePSID({
    required String? mtagID,
    required double? amount,
    required String? cnic,
    required String? mobileNum,
    required bool? isBlocked,
    bool? isInvoice,
  }) async {
    var response = await userRepo.genearatePSID(
      mtagID: mtagID,
      amount: amount,
      cnic: cnic,
      mobileNum: mobileNum,
      isBlocked: isBlocked,
      isInvoice: isInvoice,
    );

    // Check if the response is successful and contains the expected data
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      return response[APIRESPONSE.SUCCESS]['Data']; // Extract the Data field
    }

    return response;
  }

  Future<Map<String, dynamic>> generatePSIDTOPUP({
    required String? mtagID,
    required String? cnic,
    required String? mobileNum,
    required bool? isBlocked,
    bool? isInvoice,
  }) async {
    var response = await userRepo.genearatePSIDTOPUP(
      mtagID: mtagID,
      cnic: cnic,
      mobileNum: mobileNum,
      isBlocked: isBlocked,
    );
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      log(response.toString());
      return response;
    }
    return response;
  }

  Future<String> getAmountBreakDown({
    required String? amount,
    bool? isInvoice,
  }) async {
    var response = await userRepo.getAmountBreakDown(amount: amount);
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      log(response[APIRESPONSE.SUCCESS]['Data']['charges'].toString());
      return response[APIRESPONSE.SUCCESS]['Data']['charges'].toString();
    }
    return response[APIRESPONSE.ERROR]['Message'];
  }
}
