import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
      subtitle: 'Manage Vehicles',
    ),
    MtagModel(
      routeName: '/tollHostory',
      title: 'Toll History',
      image: 'assets/icons/toll.png',
      subtitle: 'View Transactions',
    ),
    MtagModel(
      routeName: '/tollCalculator',
      title: 'Toll Calculator',
      image: 'assets/icons/calculator1.png',
      subtitle: 'Calculate Toll Rates',
    ),
    MtagModel(
      routeName: '/recharge',
      title: 'Recharge',
      image: 'assets/icons/card.png',
      subtitle: 'Recharge M-Tag',
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

    if (dashboradData.value.activeMtags != null) {
      for (var mtag in dashboradData.value.activeMtags!) {
        expiryDate(mtag);
      }
    }
  }

  bool isMtagExpired(String? issuedate) {
    if (issuedate == null || issuedate.isEmpty) return false;
    try {
      DateTime? issueDate = DateTime.tryParse(issuedate);

      if (issueDate == null) {
        try {
          issueDate = DateFormat("dd-MMM-yyyy").parse(issuedate);
        } catch (_) {
          List<String> parts = issuedate.split('-');
          if (parts.length == 3) {
            if (parts[2].length == 4) {
              issueDate = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            } else if (parts[0].length == 4) {
              issueDate = DateTime(
                int.parse(parts[0]),
                int.parse(parts[1]),
                int.parse(parts[2]),
              );
            }
          }
        }
      }

      if (issueDate != null) {
        DateTime expiryDate = DateTime(
          issueDate.year + 5,
          issueDate.month,
          issueDate.day,
        );
        return expiryDate.isBefore(DateTime.now());
      }
    } catch (e) {
      debugPrint("Error parsing date: $e");
    }
    return false;
  }

  String expiryDate(ActiveMtags mtag) {
    String? issuedate = mtag.issuedate;
    String? tagExpiryDate = mtag.tag_expiry_date;
    if (issuedate == null || issuedate.isEmpty) return "";
    try {
      DateTime? issueDate = DateTime.tryParse(issuedate);

      if (issueDate == null) {
        try {
          issueDate = DateFormat("dd-MMM-yyyy").parse(issuedate);
        } catch (_) {
          // Fallback for numeric dd-MM-yyyy or yyyy-MM-dd
          List<String> parts = issuedate.split('-');
          if (parts.length == 3) {
            if (parts[2].length == 4) {
              issueDate = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            } else if (parts[0].length == 4) {
              issueDate = DateTime(
                int.parse(parts[0]),
                int.parse(parts[1]),
                int.parse(parts[2]),
              );
            }
          }
        }
      }

      if (issueDate != null) {
        // Expiry is 5 years after issue date
        DateTime expiryDate = DateTime(
          issueDate.year + 5,
          issueDate.month,
          issueDate.day,
        );
        DateTime now = DateTime.now();

        if (expiryDate.isBefore(now) || mtag.is_expired == true || mtag.isactive == 9) {
          return tagExpiryDate ?? "Expired";
        }

        int years = expiryDate.year - now.year;
        int months = expiryDate.month - now.month;
        int days = expiryDate.day - now.day;

        if (days < 0) {
          months -= 1;
          // Get last day of previous month
          DateTime previousMonth = DateTime(now.year, now.month, 0);
          days += previousMonth.day;
        }

        if (months < 0) {
          years -= 1;
          months += 12;
        }

        List<String> parts = [];
        if (years > 0) parts.add("$years ${years == 1 ? 'Year' : 'Years'}");
        if (months > 0) {
          parts.add("$months ${months == 1 ? 'Month' : 'Months'}");
        }
        if (days > 0) parts.add("$days ${days == 1 ? 'Day' : 'Days'}");

        String result = parts.join(", ");
        debugPrint(
          "Issue Date: $issuedate, Expiry Date: ${DateFormat("dd MMMM, yyyy").format(expiryDate)}, Expires in: $result",
        );
        return result;
      }
    } catch (e) {
      debugPrint("Error parsing date: $e");
    }
    return "";
  }

  void _handleError(Map<String, dynamic> response) {
    final message = response.containsKey(APIRESPONSE.ERROR)
        ? response[APIRESPONSE.ERROR]['Message']
        : APIEXCEPTION.UNPROCESS;

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
