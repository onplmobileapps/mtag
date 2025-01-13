import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import '../../api/application_url.dart';
import '../../base/app_data.dart';
import '../../utils/utils.dart';
import '../widgets/dialog/promo_dialog.dart';
import '../widgets/dialog/update_dialog.dart';
import '../api/api_constants.dart';
import '../api/auth_controller.dart';
import '../api/user_repo.dart';
import '../constants/other_consts.dart';
import '../pages/dashboard/model/dashboard_model.dart';
import '../pages/dashboard/model/mtag_model.dart';
import '../widgets/dialog/cupertion_dialog.dart';

class HomeController extends GetxController implements GetxService {
  final UserRepo userRepo;

  HomeController({required this.userRepo});
  RxInt currentPage = 0.obs;
  setCurrentIndex(vale) {
    currentPage.value = vale;
  }

  final _otherConstants = OtherConsts();
  final List<MtagModel> dashBoardModel = [
    MtagModel(
      routeName: '/mTag',
      title: 'M-TAG',
      image: 'assets/my_tag.svg',
    ),
    MtagModel(
      routeName: '/tollHostory',
      title: 'Toll History',
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

  var dashboradData = DashBoardModel().obs;
  Future<Map<String, dynamic>> getdashBoardData({
    String? appVersion,
    String? deviceID,
  }) async {
    Map<String, dynamic> response = await userRepo.getdashBoardData();

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      dashboradData.value = DashBoardModel.fromJson(response[APIRESPONSE.SUCCESS]);
      _otherConstants.ownerName.value = dashboradData.value.customerDetail?.fullName ?? '';
      _otherConstants.ownerCNIC.value = dashboradData.value.customerDetail?.cNIC ?? '';
      _otherConstants.mobile.value = dashboradData.value.customerDetail?.mobileNumber ?? '';
      _otherConstants.email.value = dashboradData.value.customerDetail?.email ?? '';
      _otherConstants.password.value = dashboradData.value.customerDetail?.password ?? '';
      _otherConstants.jazzCode(dashboradData.value.jazzCashRecharge);
      _otherConstants.creditCode(dashboradData.value.creditCardRecharge);
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog('${response[APIRESPONSE.ERROR]['Message']}', () {
        Get.find<AuthController>().clearSharedData();
        Get.delete<HomeController>(force: true);
        Get.offAllNamed('/login');
      });
    } else {
      showPopDialog('Something went wrong\nTry again later.', () {
        Get.find<AuthController>().clearSharedData();
        Get.delete<HomeController>(force: true);
        Get.offAllNamed('/login');
      });
    }

    return response;
  }

  refreshDashBoardData() async {
    await getdashBoardData();
    _otherConstants.isRefresh(false);
  }

pullrefreshDashBoardData() async {
   var data= await getdashBoardData();
   log(data.toString());
    _otherConstants.isRefresh(false);
  }
 

  @override
  void onReady() async {

    AppData.setCount(1);
    await getdashBoardData(); // Wait for data to be loaded
    Future.delayed(const Duration(seconds: 3), () {
      if (dashboradData.value.promotionalPopUpImage?.code == '00') {
        Get.dialog(
            PromoDialog(
              imageUrl: "${ApplicationUrl.IMAGE_ULR}${dashboradData.value.promotionalPopUpImage?.imgURL}",
            ),
            barrierDismissible: false); // Show promo dialog after a delay
      }
    });

  

    if (AppData.getAppCount() == 5) AppReviewUtils.requestAppReview();
    if (dashboradData.value.versionCheck?.code == '01' && Platform.isIOS) {
      showUpdateDialog(dashboradData.value.versionCheck?.message ?? '');
      return;
    }
    super.onReady();
  }
}
