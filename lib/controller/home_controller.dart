import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../features/widget/weather_option_dailog.dart';
import '../api/api_constants.dart';
import '../api/auth_controller.dart';
import '../api/user_repo.dart';
import '../base/app_data.dart';
import '../constants/other_consts.dart';
import '../pages/dashboard/model/dashboard_model.dart';
import '../pages/dashboard/model/mtag_model.dart';
import '../utils/utils.dart';
import '../widgets/dialog/cupertino_dialog.dart';
import '../widgets/dialog/operator_selection_dialog.dart';

class HomeController extends GetxController implements GetxService {
  final balances = <String, String>{}.obs;
  final hiddenStates = <String, bool>{}.obs;
  final UserRepo userRepo;
  HomeController({required this.userRepo});
  final RxInt currentPage = 0.obs;
  final RxBool isLoading = false.obs;
  var balanceUpdate = false.obs;
  var transferBalance = false.obs;
  var chassisNumberUpdate = false.obs;
  RxInt selectedMtagIndex = 0.obs;
  final navigationStack = <int>[0].obs;
  final int homePageIndex = 0;
  void setCurrentIndex(int value) {
    currentPage.value = value;
    if (value == 1) showWeatherUpdateDialog(Get.context!);
  }
  final _otherConstants = OtherConsts();
  final List<MtagModel> dashBoardModel = [
    // Sir Suleman asked to change M-TAG to Vehicles(Date 27-12-25)
    MtagModel(
      routeName: '/mTag',
      title: 'Vehicles',
      image: 'assets/icons/receipt.png',
    ),
    MtagModel(
      routeName: '/tollHostory',
      title: 'Toll\nHistory',
      image: 'assets/icons/toll.png',
    ),
    MtagModel(
      routeName: '/tollCalculator',
      title: 'Toll\nCalculator',
      image: 'assets/icons/calculator1.png',
    ),
    MtagModel(
      routeName: '/recharge',
      title: 'Recharge',
      image: 'assets/icons/card.png',
    ),
  ];

  final dashboradData = DashBoardModel().obs;

  Future<Map<String, dynamic>> getDashboardData({
    String? appVersion,
    String? deviceID,
    bool? isLoadingValue,
  }) async {
    isLoading.value = true;
    final response = await userRepo.getdashBoardData();
    isLoading.value = false;

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      _updateDashboardData(response[APIRESPONSE.SUCCESS]);
    } else {
      _handleError(response);
    }
    return response;
  }

  // Future<Map<String, dynamic>> sendNetworkOperator({
  //   String? cnicNumber,
  //   String? mobileNum,
  //   int? simOperator,
  // }) async {
  //   final response = await userRepo.updateSimOperator(
  //     CnicNumber: cnicNumber,
  //     MobileNum: mobileNum,
  //     sim_operator: simOperator,
  //   );
  //
  //   if (response.containsKey(APIRESPONSE.SUCCESS)) {
  //     showCupertinoModalPopup(
  //       context: Get.context!,
  //       builder: (_) => CupertinoAlertDialog(
  //         content: Text('${response[APIRESPONSE.SUCCESS]['Message']}'),
  //         actions: [
  //           CupertinoDialogAction(onPressed: Get.back, child: const Text('Ok')),
  //         ],
  //       ),
  //     );
  //   } else {
  //     _handleError(response);
  //   }
  //   return response;
  // }

  Future<Map<String, dynamic>> updateChassisCall({
    String? cnicNumber,
    mobileNumber,
    mtagID,
    chassisNumber,
  }) async {
    final response = await userRepo.updateChassisNumber(
      cnicNumber,
      mobileNumber,
      mtagID,
      chassisNumber,
    );

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      await refreshDashboardData();
      showCupertinoModalPopup(
        context: Get.context!,
        builder: (_) => CupertinoAlertDialog(
          content: Text('${response[APIRESPONSE.SUCCESS]['Message']}'),
          actions: [
            CupertinoDialogAction(onPressed: Get.back, child: const Text('Ok')),
          ],
        ),
      );
    } else {
      _handleError(response);
    }
    return response;
  }

  //transfer balance call
  Future<Map<String, dynamic>> transferBalanceCall({
    String? cnicNumber,
    mobileNumber,
    fromMtag,
    toMtag,
    amount,
  }) async {
    final response = await userRepo.transferBalance(
      cnicNumber,
      mobileNumber,
      fromMtag,
      toMtag,
      amount,
    );

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      // await sendCheckBalance([toMtag, fromMtag]);
      await refreshDashboardData();
      showCupertinoModalPopup(
        context: Get.context!,
        builder: (_) => CupertinoAlertDialog(
          content: Text('${response[APIRESPONSE.SUCCESS]['Message']}'),
          actions: [
            CupertinoDialogAction(onPressed: Get.back, child: const Text('Ok')),
          ],
        ),
      );
    } else {
      _handleError(response);
    }
    return response;
  }

  Future<Map<String, dynamic>> sendCheckBalance([List<String>? mtagIds]) async {
    balanceUpdate.value = true;
    final response = await userRepo.checkBalance(mtagIds ?? []);

    Map<String, dynamic> actualData;
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      actualData = response[APIRESPONSE.SUCCESS];
    } else if (response.containsKey("Error")) {
      balanceUpdate.value = false;
      _handleError(response);
      return response;
    } else {
      actualData = response;
    }

    final code = actualData["Code"]?.toString();

    if (code == "00" && actualData["Data"] != null) {
      final data = actualData["Data"] as List<dynamic>;

      for (final e in data) {
        final id = e["itokenno"].toString();
        final amount = (e["amount"] != null) ? e["amount"].toString() : "0.00";

        balances[id] = amount;
        hiddenStates.putIfAbsent(id, () => true);
      }

      hiddenStates.refresh();

      debugPrint("✅ Balance check successful. Found ${data.length} accounts");
    } else {
      _handleError(response);
    }
    balanceUpdate.value = false;
    return response;
  }

  void _updateDashboardData(Map<String, dynamic> data) {
    dashboradData.value = DashBoardModel.fromJson(data);
    final customer = dashboradData.value.customerDetail;
    if (customer != null) {
      _otherConstants.ownerName.value = customer.fullName ?? '';
      _otherConstants.ownerCNIC.value = customer.cNIC ?? '';
      _otherConstants.mobile.value = customer.mobileNumber ?? '';
      _otherConstants.email.value = customer.email ?? '';
      _otherConstants.password.value = customer.password ?? '';
    }
    _otherConstants.jazzCode(dashboradData.value.jazzCashRecharge);
    _otherConstants.creditCode(dashboradData.value.creditCardRecharge);
  }

  void _handleError(Map<String, dynamic> response) {
    final message = response.containsKey(APIRESPONSE.ERROR)
        ? response[APIRESPONSE.ERROR]['Message']
        : 'We couldn’t complete your request\n Try again or contact assistance.';

    showPopDialog(message, _resetAndNavigate);
  }

  void _resetAndNavigate() {
    Get.find<AuthController>().clearSharedData();
    Get.delete<HomeController>(force: true);
    Get.offAllNamed('/pinPage');
  }

  Future<void> refreshDashboardData() async {
    await getDashboardData();
    _otherConstants.isRefresh(false);
  }

  Future<void> pullRefreshDashboardData() async {
    await getDashboardData();
    _otherConstants.isRefresh(false);
  }

  @override
  void onReady() async {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeDashboard();
      await _handleAppCountAndReview();
      _handlePostInitActions();
    });
  }

  Future<void> _initializeDashboard() async {
    await getDashboardData();
  }

  // / Increments app count and triggers review at 5 launches.
  Future<void> _handleAppCountAndReview() async {
    await AppData.setCount(); // Increment count
    final count = AppData.getAppCount();
    if (count >= 5) {
      AppReviewUtils.requestAppReview();
      await AppData.setCount(reset: true); // Reset count after review
    }
  }

  void _handlePostInitActions() {
    if (dashboradData.value.customerDetail != null &&
        dashboradData.value.customerDetail!.mobileNumber != null &&
        dashboradData.value.customerDetail!.mobileNumber!.isNotEmpty &&
        dashboradData.value.customerDetail?.sim_operator == 0) {
      OperatorSelectionDialog.show(
        Get.context!,
        (value) {
          Get.find<AuthController>().sendNetworkOperator(
            cnicNumber: dashboradData.value.customerDetail!.cNIC,
            mobileNum: dashboradData.value.customerDetail!.mobileNumber,
            simOperator: value,
          );
        },
        mobileNumber: dashboradData.value.customerDetail!.mobileNumber,
      );
    }
  }

  void changePage(int index) {
    currentPage.value = index;
    if (currentPage.value == 1) {
    showWeatherUpdateDialog(Get.context!);
    }
  }

  void goBackToHome() {
    currentPage.value = homePageIndex;
  }

  bool get isNotOnHome => currentPage.value != homePageIndex;
}


