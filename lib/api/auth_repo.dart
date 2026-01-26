// ignore_for_file: library_prefixes

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart' as apiClient;
import 'package:get/get.dart';
import 'package:mtag_flutterapp/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_constants.dart';
import '../pages/login/user_model.dart';
import 'api_structure.dart';
import 'application_url.dart';
import 'auth_controller.dart';

class AuthRepo {
  final SharedPreferences sharedPreferences;

  AuthRepo({required this.sharedPreferences});

  String? getAuthToken() {
    try {
      UserModel? userInfo = getLoginUserData();

      return userInfo?.data?.accessToken;
    } catch (e) {
      throw Exception(e);
    }
  }

  void saveLoginUserData({required UserModel user}) {
    log('save time user ${user.toJson()}');
    try {
      sharedPreferences.setString('Login', json.encode(user.toJson()));
    } catch (e) {
      throw Exception(e);
    }
  }

  void setSharedPreferenceFcmToken({required String fcmToken}) {
    log('fcmSavedtime-->$fcmToken');
    try {
      sharedPreferences.setString('fcm_token', fcmToken);
    } catch (e) {
      throw Exception(e);
    }
  }

  String idarkTheme() {
    return sharedPreferences.getString('themeMode') ?? '';
  }

  void setDarkTheme(String themeMode) {
    sharedPreferences.setString('themeMode', themeMode);
  }

  String? getFcmToken() {
    log(sharedPreferences.getString('fcm_token').toString());
    var token = sharedPreferences.getString('fcm_token');

    return token;
  }

  Future<Map<String, dynamic>> updateFcmToken({
    required String fcmToken,
  }) async {
    try {
      APISTRUCTURE apiObject = APISTRUCTURE(
        apiUrl: 'updateFcmtokenurlhere',
        apiRequestMethod: APIREQUESTMETHOD.POST,
        isWantSuccessMessage: false,
        body: apiClient.FormData.fromMap({"fcm_token": fcmToken}),
      );
      return await apiObject.requestAPI(
        isShowLoading: false,
        isCheckAuthorization: true,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  UserModel? getLoginUserData() {
    try {
      String? userData = sharedPreferences.getString('Login');

      return userData != null
          ? UserModel.fromJson(json.decode(userData))
          : null;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String cnic,
    required String mobileNumber,
    String? fcmToken,
    String? metaData,
    // int? operator
  }) async {
    APISTRUCTURE apiObject = APISTRUCTURE(
      apiUrl: ApplicationUrl.LOGIN_URL,
      apiRequestMethod: APIREQUESTMETHOD.POST,
      isWantSuccessMessage: true,
      body: {
        "CnicNumber": cnic,
        "MobileNum": mobileNumber,
        "meta_data": metaData,
        "fcmToken": fcmToken,
        // "sim_operator":operator
      },
    );

    return await apiObject.requestAPI(
      isShowLoading: true,
      isCheckAuthorization: false,
    );
  }

  // Register
  Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String cnic,
    required String mobileNumber,
    String? fcmToken,
    int? operator, // Added operator parameter
  }) async {
    APISTRUCTURE apiObject = APISTRUCTURE(
      apiUrl: ApplicationUrl.REGISTER_URL,
      apiRequestMethod: APIREQUESTMETHOD.POST,
      isWantSuccessMessage: true,
      body: apiClient.FormData.fromMap({
        "fullName": fullName,
        "cnicNumber": cnic,
        "mobileNumber": mobileNumber,
        "sim_operator": operator,
        // 'fcm_token': getFcmToken(),
      }),
    );

    return await apiObject.requestAPI(
      isShowLoading: true,
      isCheckAuthorization: false,
    );
  }

  // OTP Generating Api
  Future<Map<String, dynamic>> genearateOtp({
    String? smsText,
    String? cnic,
    int? islogin,
  }) async {
    APISTRUCTURE apiObject = APISTRUCTURE(
      apiUrl: ApplicationUrl.GENERATEOTP_URL,
      apiRequestMethod: APIREQUESTMETHOD.POST,
      isWantSuccessMessage: true,
      body: {
        "sms_text":
            "Your authentication code for M-TAG One Network app is VERIFICATION_CODE_HERE. Never share it with anyone, ever.",
        "CnicNumber": cnic,
        "is_login": islogin,
      },
    );

    return await apiObject.requestAPI(
      isShowLoading: false,
      isCheckAuthorization: false,
    );
  }

  //Verify Otp
  Future<Map<String, dynamic>> verifyOTP({
    String? code,
    int? islogin,
    String? fcmToken,
  }) async {
    var release = await DeviceInfo.getDeviceInfo();
    APISTRUCTURE apiObject = APISTRUCTURE(
      apiUrl: ApplicationUrl.VERIFYOTP_URL,
      apiRequestMethod: APIREQUESTMETHOD.POST,
      isWantSuccessMessage: true,
      body: {
        "Code": code,
        "is_login": islogin,
        "fcmToken": fcmToken,
        "meta_data":
            '${Platform.isAndroid ? "Android" : 'iOS'} __${release['release']} __${release['manufacturer']} ${release['model']} __android_id__$fcmToken __3.1.4',
      },
    );

    return await apiObject.requestAPI(
      isShowLoading: true,
      isCheckAuthorization: true,
    );
  }

  Future<Map<String, dynamic>> logout() async {
    APISTRUCTURE apiObject = APISTRUCTURE(
      apiUrl: ApplicationUrl.LOGOUT_URL,
      apiRequestMethod: APIREQUESTMETHOD.POST,
      isWantSuccessMessage: true,
      body: apiClient.FormData.fromMap({
        "token_value": Get.find<AuthController>().authRepo.getAuthToken(),
      }),
    );
    return await apiObject.requestAPI(
      isShowLoading: true,
      isCheckAuthorization: false,
    );
  }

  //Uppdate Info

  Future<Map<String, dynamic>> updateUserInfo({
    required String name,
    required String email,
    String? userName,
    String? registerationNo,
    String? signature,
  }) async {
    APISTRUCTURE apiObject = APISTRUCTURE(
      apiUrl: '',
      apiRequestMethod: APIREQUESTMETHOD.PUT,
      isWantSuccessMessage: true,
      body: {
        "name": name,
        "email": email,
        "username": userName,
        "signature": signature,
        "registration_no": registerationNo,
      },
    );
    return await apiObject.requestAPI(
      isShowLoading: true,
      isCheckAuthorization: true,
    );
  }

  bool? isLoggedIn() {
    if ((getLoginUserData()?.data?.iscoporate == false &&
        getLoginUserData() != null)) {
      return true;
    }
    return false;
  }

  Future<bool> clearSharedData() async {
    // await sharedPreferences.clear();

    try {
      await sharedPreferences.remove('Login');
    } catch (e) {
      log('Error While Reading Prefrences: $e');
    }

    return true;
  }

  Future<void> saveUserNumberAndPassword(
    String number,
    String password,
    String countryCode,
  ) async {
    try {
      await sharedPreferences.setString('AppConstants.USER_PASSWORD', password);
    } catch (e) {
      rethrow;
    }
  }

  String getUserPassword() {
    return sharedPreferences.getString('AppConstants.USER_PASSWORD') ?? "";
  }

  bool isNotificationActive() {
    return sharedPreferences.getBool('AppConstants.NOTIFICATION') ?? true;
  }

  Future<Map<String, dynamic>> createPin({
    String? cnic,
    String? mobileNum,
    int? isResetPin,
    int? isForgetPin,
    int? isCreatePin,
    String? pin,
    String? newPin,
  }) async {
    APISTRUCTURE apiObject = APISTRUCTURE(
      apiUrl: ApplicationUrl.PINCREATEURL,
      apiRequestMethod: APIREQUESTMETHOD.POST,
      isWantSuccessMessage: true,
      body: {
        "cnic": cnic,
        "mobile_num": mobileNum,
        "is_reset_pin": isResetPin,
        "is_create_pin": isCreatePin,
        "is_forgot_pin": isForgetPin,
        "pin": pin,
        "new_pin": newPin,
      },
    );
    return await apiObject.requestAPI(
      isShowLoading: false,
      isCheckAuthorization: true,
    );
  }

  Future<Map<String, dynamic>> verifyPin({
    String? cnic,
    String? mobileNum,
    String? fcm,
    String? metaData,
    String? pin,
  }) async {
    var release = await DeviceInfo.getDeviceInfo();
    final api = APISTRUCTURE(
      apiUrl: ApplicationUrl.VERIFY_PIN_URL,
      apiRequestMethod: APIREQUESTMETHOD.POST,
      isWantSuccessMessage: true,
      body: {
        "cnic": cnic,
        "mobile_num": mobileNum,
        "pin": pin,
        "meta_data":
            '${Platform.isAndroid ? "Android" : 'iOS'} __${release['release']} __${release['manufacturer']} ${release['model']} __android_id__$fcm __3.1.4',
        "fcmToken": fcm,
      },
    );
    return await safeRequest(api: api, showLoader: true);
  }
Future<Map<String, dynamic>> updateSimOperator({
  String? cnicNumber,
  mobileNum,
  int? simOperator,
}) async {
  APISTRUCTURE apiObject = APISTRUCTURE(
    apiUrl: ApplicationUrl.UPDATE_OPERATOR,
    apiRequestMethod: APIREQUESTMETHOD.POST,
    isWantSuccessMessage: true,
    body: {
      "CnicNumber": cnicNumber,
      "MobileNum": mobileNum,
      "sim_operator": simOperator,
    },
  );

  return await apiObject.requestAPI(
    isShowLoading: true,
    isCheckAuthorization: true,
  );
}
}
