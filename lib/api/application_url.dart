// ignore_for_file: non_constant_identifier_names, constant_identifier_names

class ApplicationUrl {
  static final ApplicationUrl _instance = ApplicationUrl._internal();

  ApplicationUrl._internal();

  factory ApplicationUrl() {
    return _instance;
  }

  // static const String _BASE_URL = 'https://10.0.1.127:5000';

  static const String _BASE_URL = 'https://ocotapp.com';

  // static const String _BASE_URL = 'https://ocottapp.com';

  static const String _IMAGE_ULR = _BASE_URL;

  static String get IMAGE_ULR => _IMAGE_ULR;
  static const String _LOGIN_URL = '$_BASE_URL/loginUser_new';

  static String get LOGIN_URL => _LOGIN_URL;
  static const String _VERIFYOTP_URL = '$_BASE_URL/verifyOTP';

  static String get VERIFYOTP_URL => _VERIFYOTP_URL;
  static const String _GENERATEOTP_URL = '$_BASE_URL/generateOTP_6';

  static String get GENERATEOTP_URL => _GENERATEOTP_URL;
  static const String _DASHBOARD_URL = '$_BASE_URL/Dashboard';

  static String get DASHBOARD_URL => _DASHBOARD_URL;
  static const String _GETMTAGS_URL = '$_BASE_URL/getActiveMtags_new3';

  static String get GETMTAGS_URL => _GETMTAGS_URL;
  static const String _GETALLTARNSACTIONS_URL = '$_BASE_URL/getAllTrans_New3';

  static String get GETALLTARNSACTIONS_URL => _GETALLTARNSACTIONS_URL;
  static const String _UPDATEMAIL_URL = '$_BASE_URL/updateEmail_New';

  static String get UPDATEMAIL_URL => _UPDATEMAIL_URL;
  static const String _GETREACHARGE_URL = '$_BASE_URL/getRech_Details';

  static String get GETREACHARGE_URL => _GETREACHARGE_URL;
  static const String _GETRNSDETAILS_URL = '$_BASE_URL/getTrans_Details';

  static String get GETRNSDETAILS_URL => _GETRNSDETAILS_URL;
  static const String _GETACTIVITIES_URL =
      '$_BASE_URL/Get_PaymentMethod_And_Transactions_new3';

  static String get GEACTIVITIES_URL => _GETACTIVITIES_URL;
  static const String _GETMOTORWAYS_URL = '$_BASE_URL/Get_Motorways_V2';

  static String get GETMOTORWAYS_URL => _GETMOTORWAYS_URL;
  static const String _GETMOTOSTATIONS_URL = '$_BASE_URL/getMotStations';

  static String get GETMOTOSTATIONS_URL => _GETMOTOSTATIONS_URL;
  static const String _CALCULATETOLL_URL = '$_BASE_URL/calculateToll';

  static String get CALCULATETOLL_URL => _CALCULATETOLL_URL;
  static const String _CUSTOMERDETAILS_URL = '$_BASE_URL/customerDetails';

  static String get CUSTOMERDETAILS_URL => _CUSTOMERDETAILS_URL;
  static const String _GETOWNERCHARGES_URL =
      '$_BASE_URL/get_OwnerNameAndCharges_New';

  static String get GETOWNERCHARGES_URL => _GETOWNERCHARGES_URL;
  static const String _GETFLEETCHARGES_URL =
      '$_BASE_URL/company/get_OwnerNameAndCharges_New';

  static String get GETFLEETCHARGES_URL => _GETFLEETCHARGES_URL;
  static const String _GETCARDETAILS_URL = '$_BASE_URL/Get_Card_Details_New3';

  static String get GETCARDETAILS_URL => _GETCARDETAILS_URL;
  static const String _JAZZCASHRECHARGE_URL = '$_BASE_URL/JazzCash_Recharge';

  static String get JAZZCASHRECHARGE_URL => _JAZZCASHRECHARGE_URL;
  static const String _GETNOTIFICATION_URL =
      '$_BASE_URL/Notification_Check_New';

  static String get GETNOTIFICATION_URL => _GETNOTIFICATION_URL;
  static const String _DELETENOTIFICATION_URL =
      '$_BASE_URL/Delete_Notification/new';

  static String get DELETENOTIFICATION_URL => _DELETENOTIFICATION_URL;
  static const String _GETSMSSTATUS_URL = '$_BASE_URL/updateSmSStatus';

  static String get GETSMSSTATUS_URL => _GETSMSSTATUS_URL;
  static const String _GETDLINKOPTIONS_URL = '$_BASE_URL/Veh_Delink_Options';

  static String get GETDLINKOPTIONS_URL => _GETDLINKOPTIONS_URL;
  static const String _DELETEACCOUNT_URL = '$_BASE_URL/Delete_Account';

  static String get DELETEACCOUNT_URL => _DELETEACCOUNT_URL;
  static const String _REGISTER_URL = '$_BASE_URL/signupUser_new';

  static String get REGISTER_URL => _REGISTER_URL;
  static const String _TOLLCALCULATE_URL = '$_BASE_URL/calculateToll';

  static String get TOLLCALCULATE_URL => _TOLLCALCULATE_URL;
  static const String _FEEDBACKURL = '$_BASE_URL/insertFeedback';

  static String get FEEDBACKURL => _FEEDBACKURL;
  static const String _LOGOUT_URL = '$_BASE_URL/logout';

  static String get LOGOUT_URL => _LOGOUT_URL;
  static const String _DELINK_URL = '$_BASE_URL/Delink_Vehicle_New';

  static String get DELINK_URL => _DELINK_URL;
  static const String _DELETCARD_URL = '$_BASE_URL/Delete_Card_Details_New2';

  static String get DELETCARD_URL => _DELETCARD_URL;
  static const String _GETPAYUUID_URL = '$_BASE_URL/insert_recharge_log';

  static String get GETPAYUUID_URL => _GETPAYUUID_URL;
  static const String _VALIDATE_MTAG_URL = '$_BASE_URL/validate/mtag/recharge';

  static String get VALIDATE_MTAG_URL => _VALIDATE_MTAG_URL;
  static const String _GETHTML_URL = '$_BASE_URL/pay/v4/';

  static String get GETHTML_URL => _GETHTML_URL;
  static const String _GENERATE_PSID = '$_BASE_URL/generate/consumerNumber';

  static String get GENERATE_PSID => _GENERATE_PSID;
  static const String _GENERATE_PSIDTOPUP =
      '$_BASE_URL/generate/topup/consumerNumber';

  static String get GENERATE_PSIDTOPUP => _GENERATE_PSIDTOPUP;
  static const String _GET_AMOUNTBREAK_DOWNURL = '$_BASE_URL/amount/breakdown';

  static String get GET_AMOUNTBREAK_DOWNURL => _GET_AMOUNTBREAK_DOWNURL;
  static const String _PINCREATEURL = '$_BASE_URL/user/pin';

  static String get PINCREATEURL => _PINCREATEURL;
  static const String _VERIFY_PIN_URL = '$_BASE_URL/verify/pin';

  static String get VERIFY_PIN_URL => _VERIFY_PIN_URL;

  static const String _UPDATE_OPERATOR = '$_BASE_URL/update/sim-operator';

  static String get UPDATE_OPERATOR => _UPDATE_OPERATOR;

  static const String _BALANCE_CHECK = '$_BASE_URL/get/balance';

  static String get BALANCE_CHECK => _BALANCE_CHECK;

  static const String _UPDATE_CHASSIS = '$_BASE_URL/update/chasis-number';

  static String get UPDATE_CHASSIS => _UPDATE_CHASSIS;

  static const String _BALANCE_TRANSFER = '$_BASE_URL/balance/transfer';

  static String get BALANCE_TRANSFER => _BALANCE_TRANSFER;

  static const String _WEATHER_MAP_VIEW_URL =
      'https://one-network-portal.weatherwalay.com/embed-map/m2?token=IsImEiOiJjbHYwazJ0bjgxcWZuMmpyengwNWw4bHQ2In0';

  static String get WEATHER_MAP_VIEW_URL => _WEATHER_MAP_VIEW_URL;
  static const String _WEATHER_TIMELINE_VIEW_URL =
      'https://weatherwalay.com/wowtimeline/m2';

  static String get WEATHER_TIMELINE_VIEW_URL => _WEATHER_TIMELINE_VIEW_URL;
}
