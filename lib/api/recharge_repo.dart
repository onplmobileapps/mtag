
import 'package:mtag_flutterapp/api/application_url.dart';
import 'api_constants.dart';
import 'api_structure.dart';
abstract class PaymentRepo {
  jazzCashRecharg() {}
  getCardDetails() {}
  getCardDetails1() {}
  deleteCardDetails() {}
  getPayUUID() {}
  getHtMLURL() {}
  genearatePSID() {}
  genearatePSIDTOPUP() {}
  getAmountBreakDown(){}
}

class RechargRepo implements PaymentRepo {
  @override
  Future<Map<String, dynamic>> jazzCashRecharg({String? mobileNumber, String? mtagID, String? amount}) async {

    APISTRUCTURE apiObject = APISTRUCTURE(
      apiUrl: ApplicationUrl.JAZZCASHRECHARGE_URL,
      apiRequestMethod: APIREQUESTMETHOD.POST,
      isWantSuccessMessage: true,
      body: {
        'Amount': amount.toString(),
        'Jazz_MobileNo': mobileNumber.toString(), // mobileNumber,//03123456789
        'MTagId': mtagID.toString(),
      },
    );

    return await apiObject.requestAPI(isShowLoading: false, isCheckAuthorization: true);
  }

  @override
  Future<Map<String, dynamic>> getCardDetails({
    String? payId,
  }) async {
    APISTRUCTURE apiObject = APISTRUCTURE(
      apiUrl: ApplicationUrl.GETCARDETAILS_URL,
      apiRequestMethod: APIREQUESTMETHOD.POST,
      body: {
        "Pay_Id": payId,
      },
      isWantSuccessMessage: true,
    );
    return await apiObject.requestAPI(isShowLoading: false, isCheckAuthorization: true);
  }

  @override
  Future<Map<String, dynamic>> getCardDetails1({
    String? payId,
  }) async {
    APISTRUCTURE apiObject = APISTRUCTURE(
      apiUrl: ApplicationUrl.GETCARDETAILS_URL,
      apiRequestMethod: APIREQUESTMETHOD.POST,
      body: {
        "Pay_Id": payId,
      },
      isWantSuccessMessage: true,
    );
    return await apiObject.requestAPI(isShowLoading: false, isCheckAuthorization: true);
  }

  @override
  Future<Map<String, dynamic>> deleteCardDetails({String? token, String? payId}) async {
    APISTRUCTURE apiObject = APISTRUCTURE(
        apiUrl: ApplicationUrl.DELETCARD_URL,
        apiRequestMethod: APIREQUESTMETHOD.POST,
        isWantSuccessMessage: true,
        body: {"token": token, "Pay_Id": payId});
    return await apiObject.requestAPI(isShowLoading: true, isCheckAuthorization: true);
  }

  @override
  Future<Map<String, dynamic>> getPayUUID({
    String? mtagId,
    String? amount,
    String? token,
    bool isFleet = false,
  }) async {
    APISTRUCTURE apiObject = APISTRUCTURE(
        apiUrl: ApplicationUrl.GETPAYUUID_URL,
        apiRequestMethod: APIREQUESTMETHOD.POST,
        isWantSuccessMessage: true,
        body: {
          "mtag_id": mtagId,
          "amount": amount,
          'token': token,
          'is_company': isFleet,
        });
    return await apiObject.requestAPI(isShowLoading: true, isCheckAuthorization: true);
  }

  @override
  getHtMLURL({String? security, String? uuid}) async {
    APISTRUCTURE apiObject = APISTRUCTURE(
        apiUrl: ApplicationUrl.GETHTML_URL,
        apiRequestMethod: APIREQUESTMETHOD.POST,
        isWantSuccessMessage: true,
        body: {"_id": uuid, "security_code": security});
    return await apiObject.requestAPI(isShowLoading: true, isCheckAuthorization: true);
  }

  @override
  Future<Map<String, dynamic>> genearatePSID(
      {String? mtagID, double? amount, String? cnic, String? mobileNum, bool? isBlocked, bool? isInvoice}) async {
    APISTRUCTURE apiObject = APISTRUCTURE(
      apiUrl: ApplicationUrl.GENERATE_PSID,
      apiRequestMethod: APIREQUESTMETHOD.POST,
      isWantSuccessMessage: true,
      body: {
        "mtag_id": mtagID,
        "amount": amount,
        "cnic": cnic,
        "mobile_num": mobileNum,
        "is_blocked": isBlocked,
        "is_invoice": isInvoice,
      },
    );
    return await apiObject.requestAPI(isShowLoading: true, isCheckAuthorization: true);
  }

  @override
  Future<Map<String, dynamic>> genearatePSIDTOPUP({
    String? mtagID,
    String? cnic,
    String? mobileNum,
    bool? isBlocked,
  }) async {
    APISTRUCTURE apiObject = APISTRUCTURE(
      apiUrl: ApplicationUrl.GENERATE_PSIDTOPUP,
      apiRequestMethod: APIREQUESTMETHOD.POST,
      isWantSuccessMessage: true,
      body: {
        "mtag_id": mtagID,
        "cnic": cnic,
        "mobile_num": mobileNum,
        "is_blocked": isBlocked,
      },
    );
    return await apiObject.requestAPI(isShowLoading: true, isCheckAuthorization: true);
  }
  @override
 Future<Map<String, dynamic>> getAmountBreakDown({
    String? amount,
   
  }) async {
    APISTRUCTURE apiObject = APISTRUCTURE(
      apiUrl: ApplicationUrl.GET_AMOUNTBREAK_DOWNURL,
      apiRequestMethod: APIREQUESTMETHOD.POST,
      isWantSuccessMessage: true,
      body: {
       "amount":amount
      },
    );
    return await apiObject.requestAPI(isShowLoading: true, isCheckAuthorization: false);
  }
}
