import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/api/api_constants.dart';
import '/api/user_repo.dart';
import '/pages/recharge/model/owner_summary_model.dart';
import '../../../widgets/dialog/cupertion_dialog.dart';

class RechargeController extends GetxController implements GetxService {
  final UserRepo userRepo;
  RechargeController({required this.userRepo});
  final otherRechargeKey = GlobalKey<State<StatefulWidget>>();

  RxBool isSummaryVisible = false.obs;
  var isPaymentModdeVisible = false.obs;
  RxBool isRechageVisible = true.obs;

  var mtagId = ''.obs;
  var payId = ''.obs;
  var rechargeAmount = ''.obs;
  var ownerRechargeModel = Rx<OwnerRechargeModel?>(null);
  void getOwnerRechargeDetails({
    required String mtagId,
    required String payId,
    required String amount,
    required Function onError,
  }) async {
    ownerRechargeModel(null);
    var response = await userRepo.getOwnerRechargeDetails(mtagId: mtagId, payId: payId, amount: amount);
    if (response.containsKey(APIRESPONSE.SUCCESS) &&
        response[APIRESPONSE.SUCCESS]['Code'] == "00" &&
        response[APIRESPONSE.SUCCESS]['Data'] != "") {
      ownerRechargeModel(null);
      ownerRechargeModel.value = OwnerRechargeModel.fromJson(response[APIRESPONSE.SUCCESS]);
      isSummaryVisible(true);
      update();
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      isSummaryVisible(false);
      isPaymentModdeVisible(false);
      isRechageVisible(false);
      update();
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () {
        Get.back();
        onError();
      });
    } else if (response.containsKey(APIRESPONSE.SUCCESS) && response[APIRESPONSE.SUCCESS]['Code'] == '03') {
      showPopDialog(response[APIRESPONSE.SUCCESS]['Message'], () {
        update();
        onError();
        Get.back();
      });
    }
  }

  void setMtagId(String id) {
    mtagId(id);
  }

  void setAmount(String amount) {
    rechargeAmount(amount);
    isRechageVisible(false);
    isPaymentModdeVisible(true);

    log(amount);
  }

  void setPayId(String payID) {
    payId(payID);
  }
}
