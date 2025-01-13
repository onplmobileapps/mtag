import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/base/app_data.dart';
import 'package:mtag_flutterapp/widgets/dialog/cupertion_dialog.dart';

import '../../api/api_constants.dart';
import '../pages/login/user_model.dart';
import './auth_repo.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  AuthController({required this.authRepo});

  int? forgotUserId;
  String? forgotUserPhoneNo;
  final bool _notification = true;
  final bool _acceptTerms = true;
  bool get notification => _notification;
  bool get acceptTerms => _acceptTerms;
  String? _userPhoneNo;
  String? _userCountryCode;
  String? get userPhoneNo => _userPhoneNo;
  String? get userCountryCode => _userCountryCode;

  UserModel? getLoginUserData() {
    return authRepo.getLoginUserData();
  }

  String? getFcmToken() {
    return authRepo.getFcmToken();
  }

  void updateLoginUserData({required UserModel user}) {
    authRepo.saveLoginUserData(user: user);
  }

  bool isLoginUser({required int userId}) {
    return true;
  }

  void setThemeMode(String themeMode) {
    authRepo.setDarkTheme(themeMode);
  }

  String getThemeMode() {
    return authRepo.idarkTheme();
  }

  bool clearSharedData() {
    authRepo.clearSharedData();
    return true;
  }
  //Login Api

  Future<Map<String, dynamic>> login({
    required String cnic,
    required String mobileNumber,
    required String metaData,
  }) async {
    var fcm = AppData.getFcmToken();

    Map<String, dynamic> response = await authRepo.login(
      cnic: cnic,
      mobileNumber: mobileNumber,
      metaData: metaData,
      fcmToken: fcm,
    );

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      Map<String, dynamic> result = response[APIRESPONSE.SUCCESS];

      authRepo.saveLoginUserData(
          user: UserModel(code: result['Code'], data: Data(accessToken: result['Data']['access_token'])));

      if (result["Code"] == '00') {
        await generateOTP(cnic: cnic, islogin: 1, mobile: mobileNumber);
      }
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      log('controll here==>$response');
      showCupertinoModalPopup(
        context: Get.context!,
        builder: (_) => CupertinoAlertDialog(
          content: Text('${response[APIRESPONSE.ERROR]['Message'] ?? 'Something went wrong\nTry again later.'}'),
          actions: [
            CupertinoDialogAction(
              onPressed: Get.back,
              child: const Text('Ok'),
            )
          ],
        ),
      );
    } else if (response['Code'] == '02') {
      showCupertinoModalPopup(
          context: Get.context!,
          builder: (_) => CupertinoAlertDialog(
                content: Text('${response["Message"] ?? 'Something went wrong\nTry again later.'}'),
                actions: [
                  CupertinoDialogAction(
                    onPressed: Get.back,
                    child: const Text('Ok'),
                  )
                ],
              ));
    } else {
      showCupertinoModalPopup(
          context: Get.context!,
          builder: (_) => CupertinoAlertDialog(
                content: const Text('Something went wrong\nTry again later.'),
                actions: [
                  CupertinoDialogAction(
                    onPressed: Get.back,
                    child: const Text('Ok'),
                  )
                ],
              ));
    }
    return response;
  }

  //FleetLogin

  //Sign Up Api
  Future<Map<String, dynamic>> registerUser({
    required String cnic,
    required String fullName,
    required String mobileNumber,
    String? fcmToken,
  }) async {
    Map<String, dynamic> response =
        await authRepo.registerUser(cnic: cnic, fullName: fullName, mobileNumber: mobileNumber, fcmToken: fcmToken);
    log(response.toString());
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      if (response[APIRESPONSE.SUCCESS]["Code"] == '00') {
        updateLoginUserData(
            user: UserModel(
                code: response[APIRESPONSE.SUCCESS]['Code'],
                data: Data(accessToken: response[APIRESPONSE.SUCCESS]['Data']['access_token'])));
        await generateOTP(cnic: cnic, islogin: 0, mobile: mobileNumber);
      }
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showCupertinoModalPopup(
        context: Get.context!,
        builder: (_) => CupertinoAlertDialog(
          content: Text('${response[APIRESPONSE.ERROR]['Message'] ?? 'Something went wrong\nTry again later.'}'),
          actions: [
            CupertinoDialogAction(
              onPressed: Get.back,
              child: const Text('Ok'),
            )
          ],
        ),
      );
    } else if (response.containsKey(APIRESPONSE.SUCCESS)) {
      showCupertinoModalPopup(
        context: Get.context!,
        builder: (_) => CupertinoAlertDialog(
          content: Text('${response[APIRESPONSE.SUCCESS]['Message'] ?? 'Something went wrong\nTry again later.'}'),
          actions: [
            CupertinoDialogAction(
              onPressed: Get.back,
              child: const Text('Ok'),
            )
          ],
        ),
      );
    } else {
      showCupertinoModalPopup(
        context: Get.context!,
        builder: (_) => CupertinoAlertDialog(
          content: const Text('Something went wrong\nTry again later.'),
          actions: [
            CupertinoDialogAction(
              onPressed: Get.back,
              child: const Text('Ok'),
            )
          ],
        ),
      );
    }

    return response;
  }

//Update FCM Token
  Future<Map<String, dynamic>> updateFcmToken({required String fcmToken}) async {
    debugPrint("updateFcmToken:->$fcmToken");
    Map<String, dynamic> response = await authRepo.updateFcmToken(fcmToken: fcmToken);
    authRepo.setSharedPreferenceFcmToken(fcmToken: fcmToken);
    return response;
  }

//
  bool? isLogedIn() {
    return authRepo.isLoggedIn();
  }

//Logout
  Future<Map<String, dynamic>> logout() async {
    Map<String, dynamic> response = await authRepo.logout();
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      authRepo.clearSharedData();
      Get.offAllNamed('/login');
    }
    return response;
  }

  //Generate OTP
  Future<Map<String, dynamic>> generateOTP({String? smsText, String? cnic, int? islogin, String? mobile}) async {
    Map<String, dynamic> response = await authRepo.genearateOtp(cnic: cnic, islogin: islogin);
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      authRepo.saveLoginUserData(user: UserModel(data: Data(accessToken: response[APIRESPONSE.SUCCESS]['Data'])));
      updateLoginUserData(
          user: UserModel(
              code: response[APIRESPONSE.SUCCESS]['Code'],
              data: Data(accessToken: response[APIRESPONSE.SUCCESS]['Data'])));
      await Get.offAllNamed('/otp', arguments: {'mobileNum': mobile, 'loginKey': islogin, 'cnic': cnic});
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () => Get.back());
    } else {
      showPopDialog('Something went wrong\nTry again later.', () => Get.back());
    }

    return response;
  }

  //resend
  Future<Map<String, dynamic>> resendOTP({
    String? smsText,
    String? cnic,
    int? islogin,
  }) async {
    Map<String, dynamic> response = await authRepo.genearateOtp(cnic: cnic, islogin: islogin);

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      authRepo.saveLoginUserData(user: UserModel(data: Data(accessToken: response[APIRESPONSE.SUCCESS]['Data'])));
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () => Get.back());
    } else {
      showPopDialog('Something went wrong\nTry again later.', () => Get.back());
    }

    return response;
  }

  //Verify OTP
  Future<Map<String, dynamic>> verifyOTP(
    String? code,
    int? islogin,
  ) async {
    var fcm = AppData.getFcmToken();

    Map<String, dynamic> response = await authRepo.verifyOTP(code: code, islogin: islogin, fcmToken: fcm);
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      authRepo.saveLoginUserData(
          user: UserModel(
              code: response[APIRESPONSE.SUCCESS]['Code'],
              data: Data(accessToken: response[APIRESPONSE.SUCCESS]['Data'], iscoporate: false)));
      Future.delayed(const Duration(seconds: 1), () async {
        await Get.offAllNamed('/dashboard');
      });
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () => Get.back());
    } else {
      showPopDialog('Something went wrong\nTry again later.', () => Get.back());
    }

    return response;
  }
}
