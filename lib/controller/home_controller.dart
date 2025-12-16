// ignore_for_file: non_constant_identifier_names

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
  // Observables
  final balances = <String, String>{}.obs;
  final hiddenStates = <String, bool>{}.obs;
  final RxInt currentPage = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;

  // Loading states
  final balanceUpdate = false.obs;
  final transferBalance = false.obs;
  final chassisNumberUpdate = false.obs;

  // Back press handling
  final RxBool _backPressedOnce = false.obs;
  Timer? _backPressTimer;

  // Data models
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

  // Dependencies
  final UserRepo userRepo;
  final OtherConsts _otherConstants = OtherConsts();

  // Constructor with proper initialization
  HomeController({required this.userRepo}) {
    log('HomeController constructor called');
    // Initialize observables safely
    _initializeController();
  }

  @override
  void onInit() {
    super.onInit();
    log('HomeController onInit called');

    // Start initialization
    _initializeAsync();
  }

  void _initializeController() {
    try {
      // Initialize hidden states for existing balances
      for (var key in balances.keys) {
        hiddenStates.putIfAbsent(key, () => true);
      }

      // Initialize other constants
      _otherConstants.jazzCode.value = 0;
      _otherConstants.creditCode.value = 0;

      log('HomeController initialized successfully');
    } catch (e) {
      log('Error initializing HomeController: $e');
    }
  }

  Future<void> _initializeAsync() async {
    try {
      if (!isInitialized.value) {
        await getDashboardData();
        isInitialized.value = true;
      }
    } catch (e) {
      log('Error in async initialization: $e');
      // Don't crash the app, just log the error
      isLoading.value = false;
    }
  }

  void setCurrentIndex(int value) => currentPage.value = value;

  Future<Map<String, dynamic>> getDashboardData({
    String? appVersion,
    String? deviceID,
    bool? isLoadingValue,
  }) async {
    try {
      if (isLoading.value) {
        log('Dashboard data already loading, skipping duplicate call');
        return {};
      }

      isLoading.value = true;
      log('Fetching dashboard data...');

      final response = await userRepo.getdashBoardData();

      if (response.containsKey(APIRESPONSE.SUCCESS)) {
        log('Dashboard data fetched successfully');
        _updateDashboardData(response[APIRESPONSE.SUCCESS]);
      } else {
        log(
          'Dashboard data fetch failed: ${response.containsKey(APIRESPONSE.ERROR) ? response[APIRESPONSE.ERROR] : 'Unknown error'}',
        );
        _handleError(response);
      }

      return response;
    } catch (e, stackTrace) {
      log('Exception in getDashboardData: $e\n$stackTrace');
      _handleError({'Error': 'Network error occurred: $e'});
      return {'Error': 'Exception occurred: $e'};
    } finally {
      // Always set loading to false
      Future.delayed(const Duration(milliseconds: 300), () {
        isLoading.value = false;
      });
    }
  }

  void _updateDashboardData(Map<String, dynamic> data) {
    try {
      final newData = DashBoardModel.fromJson(data);
      dashboradData.value = newData;

      // Update constants safely
      final customer = newData.customerDetail;
      if (customer != null) {
        _otherConstants.ownerName.value = customer.fullName ?? '';
        _otherConstants.ownerCNIC.value = customer.cNIC ?? '';
        _otherConstants.mobile.value = customer.mobileNumber ?? '';
        _otherConstants.email.value = customer.email ?? '';
        _otherConstants.password.value = customer.password ?? '';
      }

      // Update jazz and credit codes
      _otherConstants.jazzCode(newData.jazzCashRecharge);
      _otherConstants.creditCode(newData.creditCardRecharge);

      // Initialize hidden states for new MTags
      if (newData.activeMtags != null) {
        for (var mtag in newData.activeMtags!) {
          hiddenStates.putIfAbsent(mtag.tokenno.toString(), () => true);
        }
      }

      log('Dashboard data updated successfully');
    } catch (e, stackTrace) {
      log('Error updating dashboard data: $e\n$stackTrace');
      // Don't crash, just log the error
    }
  }

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
          response[APIRESPONSE.SUCCESS]['Message']?.toString() ??
              'Operation successful',
        );
      } else {
        _handleError(response);
      }
      return response;
    } catch (e) {
      log('Error in sendNetworkOperator: $e');
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
              'Chassis number updated',
        );
      } else {
        _handleError(response);
      }
      return response;
    } catch (e) {
      log('Error in updateChassisCall: $e');
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
              'Balance transferred successfully',
        );
      } else {
        _handleError(response);
      }
      return response;
    } catch (e) {
      log('Error in transferBalanceCall: $e');
      _handleError({'Error': 'Failed to transfer balance'});
      return {'Error': 'Exception occurred'};
    }
  }

  Future<Map<String, dynamic>> sendCheckBalance([List<String>? mtagIds]) async {
    try {
      balanceUpdate.value = true;
      final response = await userRepo.checkBalance(mtagIds ?? []);

      if (response.containsKey("Success")) {
        final actualData = response["Success"];
        final code = actualData["Code"]?.toString();

        if (code == "00" && actualData["Data"] != null) {
          final data = actualData["Data"] as List<dynamic>;

          for (final e in data) {
            final id = e["itokenno"].toString();
            final amount = (e["amount"] != null)
                ? e["amount"].toString()
                : "0.00";

            balances[id] = amount;
            hiddenStates.putIfAbsent(id, () => true);
          }

          hiddenStates.refresh();
          log('Balance check successful. Found ${data.length} accounts');
        } else {
          log('Balance check failed with code: $code');
        }
      } else {
        log('Balance check API error: $response');
      }

      return response;
    } catch (e, stackTrace) {
      log('Error in sendCheckBalance: $e\n$stackTrace');
      return {'Error': 'Failed to check balance'};
    } finally {
      balanceUpdate.value = false;
    }
  }

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
    try {
      String message =
          'We couldn\'t complete your request. Please try again or contact assistance.';

      if (response.containsKey(APIRESPONSE.ERROR)) {
        if (response[APIRESPONSE.ERROR] is Map) {
          message =
              response[APIRESPONSE.ERROR]['Message']?.toString() ?? message;
        } else {
          message = response[APIRESPONSE.ERROR]?.toString() ?? message;
        }
      }

      log('Error handled: $message');

      if (Get.context != null && Get.context!.mounted) {
        showPopDialog(message, _resetAndNavigate);
      }
    } catch (e) {
      log('Error in _handleError: $e');
    }
  }

  void _resetAndNavigate() {
    try {
      Get.find<AuthController>().clearSharedData();
      Get.offAllNamed('/pinPage');
    } catch (e) {
      log('Error in _resetAndNavigate: $e');
    }
  }

  Future<void> refreshDashboardData() async {
    try {
      await getDashboardData();
      _otherConstants.isRefresh(false);
    } catch (e) {
      log('Error in refreshDashboardData: $e');
    }
  }

  Future<void> pullRefreshDashboardData() async {
    try {
      await getDashboardData();
      _otherConstants.isRefresh(false);
    } catch (e) {
      log('Error in pullRefreshDashboardData: $e');
    }
  }

  // Back press handling methods
  void initializeBackHandler(BuildContext context) {
    try {
      SystemChannels.platform.setMethodCallHandler((call) async {
        if (call.method == 'SystemNavigator.pop') {
          return await handleBackPress();
        }
        return null;
      });
    } catch (e) {
      log('Error initializing back handler: $e');
    }
  }

  Future<bool> handleBackPress() async {
    try {
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

      _backPressTimer = Timer(const Duration(seconds: 2), () {
        _backPressedOnce.value = false;
      });

      return false;
    } catch (e) {
      log('Error in handleBackPress: $e');
      return false;
    }
  }

  @override
  void onClose() {
    log('HomeController onClose called');
    _backPressTimer?.cancel();
    super.onClose();
  }

  void refreshBalance() {
    // Implement balance refresh logic here
    sendCheckBalance();
  }

  // App lifecycle methods
  Future<void> _handleAppCountAndReview() async {
    try {
      await AppData.setCount();
      final count = AppData.getAppCount();

      log("App launch count: $count");

      if (count >= 5) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            AppReviewUtils.requestAppReview();
          } catch (e) {
            log('Error requesting app review: $e');
          }
        });

        await AppData.setCount(reset: true);
      }
    } catch (e) {
      log('Error in _handleAppCountAndReview: $e');
    }
  }

  void _handlePostInitActions() {
    try {
      if (dashboradData.value.customerDetail != null &&
          dashboradData.value.customerDetail!.mobileNumber != null &&
          dashboradData.value.customerDetail!.mobileNumber!.isNotEmpty &&
          dashboradData.value.customerDetail?.sim_operator == 0) {
        if (Get.context != null && Get.context!.mounted) {
          OperatorSelectionDialog.show(
            Get.context!,
            (value) {
              sendNetworkOperator(
                CnicNumber: dashboradData.value.customerDetail!.cNIC,
                MobileNum: dashboradData.value.customerDetail!.mobileNumber,
                sim_operator: value,
              );
            },
            mobileNumber: dashboradData.value.customerDetail!.mobileNumber,
          );
        }
      }
    } catch (e) {
      log('Error in _handlePostInitActions: $e');
    }
  }

  @override
  void onReady() {
    super.onReady();
    log('HomeController onReady called');

    // Handle post-init actions after a small delay to ensure UI is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        _handlePostInitActions();
        _handleAppCountAndReview();
      } catch (e) {
        log('Error in onReady delayed tasks: $e');
      }
    });
  }

  // Helper method to check if controller is ready
  bool get isReady => isInitialized.value && !isLoading.value;
}
