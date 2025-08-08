import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/base/app_data.dart';
import 'package:mtag_flutterapp/widgets/dialog/cupertino_dialog.dart';

import '../../api/api_constants.dart';
import '../pages/login/create_pin_page.dart';
import '../pages/login/user_model.dart';
import '../widgets/dialog/otp_verification_dialog.dart';
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

  // Login Api
  Future<Map<String, dynamic>> login({
    required String cnic,
    required String mobileNumber,
    required String metaData,
    int? operator, // Added optional operator parameter
    int? isForgetPin,
  }) async {
    var fcm = AppData.getFcmToken();

    Map<String, dynamic> response = await authRepo.login(
      cnic: cnic,
      mobileNumber: mobileNumber,
      metaData: metaData,
      fcmToken: fcm,
      operator: operator, // Pass operator to repository
    );

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      Map<String, dynamic> result = response[APIRESPONSE.SUCCESS];

      authRepo.saveLoginUserData(
          user: UserModel(
              code: result['Code'],
              data: Data(accessToken: result['Data']['access_token'])));

      if (result["Code"] == '00') {
        await generateOTP(
            cnic: cnic,
            islogin: 1,
            mobile: mobileNumber,
            isForgetPin: isForgetPin);
      }
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(
          '${response[APIRESPONSE.ERROR]['Message'] ?? 'We couldn’t complete your request\n Try again or contact assistance.'}',
          Get.back);
    } else if (response['Code'] == '02') {
      showPopDialog(
          '${response[APIRESPONSE.ERROR]['Message'] ?? 'We couldn’t complete your request\n Try again or contact assistance.'}',
          Get.back);
    } else {
      showPopDialog(
          '${response[APIRESPONSE.ERROR]['Message'] ?? 'We couldn’t complete your request\n Try again or contact assistance.'}',
          Get.back);
    }
    return response;
  }

  // Sign Up Api
  Future<Map<String, dynamic>> registerUser({
    required String cnic,
    required String fullName,
    required String mobileNumber,
    String? fcmToken,
    int? operator, // Added optional operator parameter
  }) async {
    Map<String, dynamic> response = await authRepo.registerUser(
      cnic: cnic,
      fullName: fullName,
      mobileNumber: mobileNumber,
      fcmToken: fcmToken,
      operator: operator, // Pass operator to repository
    );
    log(response.toString());
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      if (response[APIRESPONSE.SUCCESS]["Code"] == '00') {
        updateLoginUserData(
            user: UserModel(
                code: response[APIRESPONSE.SUCCESS]['Code'],
                data: Data(
                    accessToken: response[APIRESPONSE.SUCCESS]['Data']
                    ['access_token'])));
        await generateOTP(cnic: cnic, islogin: 0, mobile: mobileNumber);
      }
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showCupertinoModalPopup(
        context: Get.context!,
        builder: (_) => CupertinoAlertDialog(
          content: Text('${response[APIRESPONSE.ERROR]['Message']}'),
          actions: [
            CupertinoDialogAction(
              onPressed: Get.back,
              child: const Text('Ok'),
            )
          ],
        ),
      );
    } else if (response.containsKey(APIRESPONSE.SUCCESS)) {
      showPopDialog(
          '${response[APIRESPONSE.ERROR]['Message'] ?? 'We couldn’t complete your request\n Try again or contact assistance.'}',
          Get.back);
    } else {
      showPopDialog(
          'We couldn’t complete your request\n Try again or contact assistance.',
              () {});
    }

    return response;
  }

  // Update FCM Token
  Future<Map<String, dynamic>> updateFcmToken(
      {required String fcmToken}) async {
    debugPrint("updateFcmToken:->$fcmToken");
    Map<String, dynamic> response =
    await authRepo.updateFcmToken(fcmToken: fcmToken);
    authRepo.setSharedPreferenceFcmToken(fcmToken: fcmToken);
    return response;
  }

  // Is Logged In
  bool? isLogedIn() {
    return authRepo.isLoggedIn();
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    Map<String, dynamic> response = await authRepo.logout();
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      authRepo.clearSharedData();
      Get.offAllNamed('/pinPage');
    }
    return response;
  }

  // Generate OTP
  Future<Map<String, dynamic>> generateOTP({
    String? smsText,
    String? cnic,
    int? islogin,
    String? mobile,
    int? isForgetPin,
  }) async {
    Map<String, dynamic> response =
    await authRepo.genearateOtp(cnic: cnic, islogin: islogin);
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      authRepo.saveLoginUserData(
          user: UserModel(
              data: Data(accessToken: response[APIRESPONSE.SUCCESS]['Data'])));
      updateLoginUserData(
          user: UserModel(
              code: response[APIRESPONSE.SUCCESS]['Code'],
              data: Data(accessToken: response[APIRESPONSE.SUCCESS]['Data'])));
      Get.dialog(OtpVerificationDialog(
        onOtpSubmit: (otp) {
          verifyOTP(otp, islogin,
              cnic: cnic, mobile: mobile, isForgetPin: isForgetPin);
        },
        onResendOtp: () {
          resendOTP(cnic: cnic, islogin: islogin);
        },
        mobileNumber: mobile,
      ));
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () => Get.back());
    } else {
      showPopDialog(
          'We couldn’t complete your request\n Try again or contact assistance.',
              () => Get.back());
    }

    return response;
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOTP({
    String? smsText,
    String? cnic,
    int? islogin,
  }) async {
    Map<String, dynamic> response =
    await authRepo.genearateOtp(cnic: cnic, islogin: islogin);

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      authRepo.saveLoginUserData(
          user: UserModel(
              data: Data(accessToken: response[APIRESPONSE.SUCCESS]['Data'])));
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () => Get.back());
    } else {
      showPopDialog(
          'We couldn’t complete your request\n Try again or contact assistance.',
              () => Get.back());
    }

    return response;
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP(
      String? code,
      int? islogin, {
        String? mobile,
        String? cnic,
        int? isForgetPin,
      }) async {
    var fcm = AppData.getFcmToken();

    Map<String, dynamic> response =
    await authRepo.verifyOTP(code: code, islogin: islogin, fcmToken: fcm);
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      AppData.clearPinData();
      Get.back();
      authRepo.saveLoginUserData(
          user: UserModel(
              code: response[APIRESPONSE.SUCCESS]['Code'],
              data: Data(
                  accessToken: response[APIRESPONSE.SUCCESS]['Data'],
                  iscoporate: false)));

      Get.off(() => PinEntryPage(
        isForgetPin: isForgetPin,
        isCreatePin:
        response[APIRESPONSE.SUCCESS]['has_mpin'] ? false : true,
        cnicNumber: cnic,
        mobileNumber: mobile,
      ));
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(
          response[APIRESPONSE.ERROR]['Message'], null, otpVerificationError: true);
    } else {
      showPopDialog('We couldn’t complete your request\n Try again or contact assistance.',
          null, otpVerificationError: true);
    }

    return response;
  }

  // Create PIN
  Future<Map<String, dynamic>> createPIN({
    String? cnic,
    String? mobileNum,
    int? isResetPin,
    int? isCreatePin,
    int? isForgetPin,
    String? pin,
    String? newPin,
  }) async {
    var response = await authRepo.createPin(
        cnic: cnic,
        mobileNum: mobileNum,
        isResetPin: isResetPin,
        isCreatePin: isCreatePin,
        isForgetPin: isForgetPin,
        pin: pin,
        newPin: newPin);

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      AppData.savePinData(pinData: {
        'mobile': mobileNum,
        'cnic': cnic,
        'pin': isForgetPin == 1 || isResetPin == 1 ? newPin : pin
      });

      showPopDialog(
        response[APIRESPONSE.SUCCESS]['Message'],
            () {
          if (isResetPin == 1) {
            Get.back();
          } else {
            verifyPIN(
                cnic: cnic,
                mobileNum: mobileNum,
                pin: AppData.getPinData()?['pin']);
            Get.back();
            Get.back();
          }
        },
      );
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      log(response.toString());
      showPopDialog(
        response[APIRESPONSE.ERROR]['Message'],
            () {
          Get.back();
        },
      );
    }

    return response;
  }

  // Verify PIN
  Future<void> verifyPIN({
    String? cnic,
    String? mobileNum,
    String? pin,
    VoidCallback? onTap,
  }) async {
    var fcm = AppData.getFcmToken();
    var response = await authRepo.verifyPin(
      cnic: cnic,
      mobileNum: mobileNum,
      fcm: fcm,
      pin: pin,
    );

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      log('ontapp:$onTap');
      authRepo.saveLoginUserData(
          user: UserModel(
              code: response[APIRESPONSE.SUCCESS]['Code'],
              data: Data(
                  accessToken: response[APIRESPONSE.SUCCESS]['Data']
                  ['access_token'],
                  iscoporate: false)));
      AppData.savePinData(
          pinData: {'mobile': mobileNum, 'cnic': cnic, 'pin': pin});
      Get.offAllNamed(
        '/home',
      );
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], onTap);
    }
  }
}