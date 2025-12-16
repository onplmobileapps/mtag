import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../base/app_data.dart';
import '../../utils/utils.dart';
import '../api/api_constants.dart';
import '../api/auth_controller.dart';
import '../api/user_repo.dart';
import '../constants/other_consts.dart';
import '../pages/dashboard/model/dashboard_model.dart';
import '../pages/dashboard/model/mtag_model.dart';
import '../widgets/dialog/cupertino_dialog.dart';
import '../widgets/dialog/operator_selection_dialog.dart';

class HomeController extends GetxController implements GetxService {
  // --------------------- Observables ---------------------
  final hiddenStates = <String, bool>{}.obs;
  final RxInt currentPage = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final RxBool _backPressedOnce = false.obs;

  // --------------------- Timer ---------------------
  Timer? _backPressTimer;

  // --------------------- Dashboard & Models ---------------------
  final dashboradData = DashBoardModel().obs;
  final List<MtagModel> dashBoardModel = [
    MtagModel(routeName: '/mTag', title: 'M-TAG', image: 'assets/my_tag.svg'),
    MtagModel(
      routeName: '/tollHostory',
      title: 'Toll/Recharge History',
      image: 'assets/tollhistory.svg',
    ),
    MtagModel(
      routeName: '/tollCalculator',
      title: 'Toll Calculator',
      image: 'assets/toll_calc.svg',
    ),
    MtagModel(
      routeName: '/recharge',
      title: 'Recharge',
      image: 'assets/recharge2.svg',
    ),
  ];

  // --------------------- Repos & Constants ---------------------
  final UserRepo userRepo;
  final OtherConsts _otherConstants = OtherConsts();

  HomeController({required this.userRepo}) {
    log('HomeController created');
    _initializeController();
  }

  // --------------------- Lifecycle ---------------------
  @override
  void onInit() {
    super.onInit();
    _initializeAsync();
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(milliseconds: 500), () {
      _handlePostInitActions();
      _handleAppCountAndReview();
    });
  }

  @override
  void onClose() {
    _backPressTimer?.cancel();
    super.onClose();
  }

  bool get isReady => isInitialized.value && !isLoading.value;

  // --------------------- Initialization ---------------------
  void _initializeController() {
    _otherConstants.jazzCode.value = 0;
    _otherConstants.creditCode.value = 0;
    log('Controller initialized');
  }

  Future<void> _initializeAsync() async {
    if (!isInitialized.value) {
      await getDashboardData();
      isInitialized.value = true;
    }
  }

  // --------------------- Dashboard Data ---------------------
  Future<Map<String, dynamic>> getDashboardData() async {
    if (isLoading.value) return {};
    isLoading.value = true;

    try {
      final response = await userRepo.getdashBoardData();
      if (response.containsKey(APIRESPONSE.SUCCESS)) {
        _updateDashboardData(response[APIRESPONSE.SUCCESS]);
      } else {
        _handleError(response);
      }
      return response;
    } catch (e) {
      _handleError({'Error': 'Network error: $e'});
      return {'Error': 'Exception: $e'};
    } finally {
      Future.delayed(
        const Duration(milliseconds: 300),
        () => isLoading.value = false,
      );
    }
  }

  void _updateDashboardData(Map<String, dynamic> data) {
    try {
      final newData = DashBoardModel.fromJson(data);
      dashboradData.value = newData;

      // Update constants
      final customer = newData.customerDetail;
      if (customer != null) {
        _otherConstants.ownerName.value = customer.fullName ?? '';
        _otherConstants.ownerCNIC.value = customer.cNIC ?? '';
        _otherConstants.mobile.value = customer.mobileNumber ?? '';
        _otherConstants.email.value = customer.email ?? '';
        _otherConstants.password.value = customer.password ?? '';
      }

      _otherConstants.jazzCode(newData.jazzCashRecharge);
      _otherConstants.creditCode(newData.creditCardRecharge);

      // Hidden states for MTags
      newData.activeMtags?.forEach((mtag) {
        hiddenStates.putIfAbsent(mtag.tokenno.toString(), () => true);
      });
    } catch (e) {
      log('Error updating dashboard: $e');
    }
  }

  Future<void> refreshDashboardData() async => await getDashboardData();

  Future<void> pullRefreshDashboardData() async => await getDashboardData();

  // --------------------- API Calls ---------------------
  Future<Map<String, dynamic>> sendNetworkOperator({
    String? CnicNumber,
    String? MobileNum,
    int? sim_operator,
  }) async {
    try {
      final response = await userRepo.updateSimOperator(
        CnicNumber: CnicNumber,
        MobileNum: MobileNum,
        sim_operator: sim_operator,
      );
      if (response.containsKey(APIRESPONSE.SUCCESS)) {
        _showSuccessDialog(
          response[APIRESPONSE.SUCCESS]['Message']?.toString() ?? 'Success',
        );
      } else {
        _handleError(response);
      }
      return response;
    } catch (e) {
      _handleError({'Error': 'Failed to update network operator'});
      return {'Error': 'Exception occurred'};
    }
  }

  Future<Map<String, dynamic>> updateChassisCall({
    String? cnicNumber,
    String? mobileNumber,
    String? mtagID,
    String? chassisNumber,
  }) async {
    try {
      final response = await userRepo.updateChassisNumber(
        cnicNumber,
        mobileNumber,
        mtagID,
        chassisNumber,
      );
      if (response.containsKey(APIRESPONSE.SUCCESS)) {
        await refreshDashboardData();
        _showSuccessDialog(
          response[APIRESPONSE.SUCCESS]['Message']?.toString() ??
              'Chassis updated',
        );
      } else {
        _handleError(response);
      }
      return response;
    } catch (e) {
      _handleError({'Error': 'Failed to update chassis number'});
      return {'Error': 'Exception occurred'};
    }
  }

  Future<Map<String, dynamic>> transferBalanceCall({
    String? cnicNumber,
    String? mobileNumber,
    String? fromMtag,
    String? toMtag,
    double? amount,
  }) async {
    try {
      final response = await userRepo.transferBalance(
        cnicNumber,
        mobileNumber,
        fromMtag,
        toMtag,
        amount,
      );
      if (response.containsKey(APIRESPONSE.SUCCESS)) {
        await refreshDashboardData();
        _showSuccessDialog(
          response[APIRESPONSE.SUCCESS]['Message']?.toString() ??
              'Balance transferred',
        );
      } else {
        _handleError(response);
      }
      return response;
    } catch (e) {
      _handleError({'Error': 'Failed to transfer balance'});
      return {'Error': 'Exception occurred'};
    }
  }

  // --------------------- Dialogs ---------------------
  void _showSuccessDialog(String message) {
    if (Get.context != null && Get.context!.mounted) {
      showCupertinoModalPopup(
        context: Get.context!,
        builder: (_) => CupertinoAlertDialog(
          content: Text(message),
          actions: [
            CupertinoDialogAction(onPressed: Get.back, child: const Text('OK')),
          ],
        ),
      );
    }
  }

  void _handleError(Map<String, dynamic> response) {
    String message =
        'We couldn\'t complete your request. Please try again or contact support.';
    if (response.containsKey(APIRESPONSE.ERROR)) {
      final error = response[APIRESPONSE.ERROR];
      if (error is Map)
        message = error['Message']?.toString() ?? message;
      else
        message = error?.toString() ?? message;
    }

    if (Get.context != null && Get.context!.mounted) {
      showPopDialog(message, _resetAndNavigate);
    }
  }

  void _resetAndNavigate() {
    Get.find<AuthController>().clearSharedData();
    Get.offAllNamed('/pinPage');
  }

  // --------------------- Back Press ---------------------
  void initializeBackHandler(BuildContext context) {
    SystemChannels.platform.setMethodCallHandler((call) async {
      if (call.method == 'SystemNavigator.pop') return await handleBackPress();
      return null;
    });
  }

  Future<bool> handleBackPress() async {
    if (_backPressedOnce.value) {
      _backPressTimer?.cancel();
      return true;
    }

    _backPressedOnce.value = true;
    Get.snackbar(
      'Press back again to exit',
      '',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black54,
      colorText: Colors.white,
    );

    _backPressTimer = Timer(
      const Duration(seconds: 2),
      () => _backPressedOnce.value = false,
    );
    return false;
  }

  // --------------------- Utilities ---------------------
  void setCurrentIndex(int value) => currentPage.value = value;

  void _handlePostInitActions() {
    final customer = dashboradData.value.customerDetail;
    if (customer?.mobileNumber?.isNotEmpty == true &&
        customer?.sim_operator == 0) {
      if (Get.context != null && Get.context!.mounted) {
        OperatorSelectionDialog.show(
          Get.context!,
          (value) => sendNetworkOperator(
            CnicNumber: customer?.cNIC,
            MobileNum: customer?.mobileNumber,
            sim_operator: value,
          ),
          mobileNumber: customer?.mobileNumber,
        );
      }
    }
  }

  Future<void> _handleAppCountAndReview() async {
    await AppData.setCount();
    final count = AppData.getAppCount();
    if (count >= 5) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => AppReviewUtils.requestAppReview(),
      );
      await AppData.setCount(reset: true);
    }
  }
}
