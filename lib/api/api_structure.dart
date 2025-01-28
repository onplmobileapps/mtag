// ignore_for_file: library_prefixes

import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart' as apiClient;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../base/connectivity_check.dart';
import '../../api/api_constants.dart';
import 'api_loader.dart';
import 'auth_controller.dart';

class APISTRUCTURE {
  final String apiUrl;
  dynamic body;
  final bool isWantSuccessMessage;
  final String apiRequestMethod;
  String? contentType;

  APISTRUCTURE({
    this.body,
    required this.apiUrl,
    required this.apiRequestMethod,
    this.isWantSuccessMessage = false,
    this.contentType,
  });

  Future<Map<String, dynamic>> requestAPI({bool isShowLoading = false, bool isCheckAuthorization = true}) async {
    String api = BASE_URL + apiUrl;
    if (isShowLoading) ApiLoader.show();

    try {
      Map<String, String> headers = {
        "Accept": "application/json",
        "Connection": "Keep-Alive",
        'User-agent': 'your bot 0.1',
        "Authorization": "Bearer ${Get.find<AuthController>().authRepo.getAuthToken()}"
      };
      if (contentType != null) headers["Content-Type"] = contentType!;

      apiClient.Dio dio = apiClient.Dio(apiClient.BaseOptions(
        connectTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
      ));

      apiClient.Options options = apiClient.Options(
        followRedirects: false,
        headers: headers,
        validateStatus: (status) => status != null && status < 600,
      );

      if (await ConnectionCheck.isConnected().then((value) => value.containsKey(APIRESPONSE.SUCCESS))) {
        apiClient.Response<dynamic> response;

        switch (apiRequestMethod) {
          case APIREQUESTMETHOD.GET:
            response = await dio.get(api, options: options);
            break;
          case APIREQUESTMETHOD.POST:
            response = await dio.post(api, data: body, options: options);
            break;
          case APIREQUESTMETHOD.DELETE:
            response = await dio.delete(api, options: options);
            break;
          case APIREQUESTMETHOD.PUT:
            response = await dio.put(api, data: body, options: options);
            break;
          default:
            throw Exception('Unsupported request method');
        }
        log("message$body");
        log('$api response:[${response.statusCode}]----> $response');
        if (isShowLoading) ApiLoader.hide();

        return _handleResponse(response);
      } else {
        if (isShowLoading) ApiLoader.hide();
        return {
          APIRESPONSE.ERROR: {
            "Message": await ConnectionCheck.isConnected().then((value) => value[APIRESPONSE.ERROR]['Message'])
          }
        };
      }
    } catch (e) {
      if (isShowLoading) ApiLoader.hide();
      return _handleException(e);
    }
  }

  Map<String, dynamic> _handleResponse(apiClient.Response<dynamic> response) {
    if (response.statusCode == 200) {
      return {APIRESPONSE.SUCCESS: response.data};
    } else if (response.statusCode == 504 ||
        response.statusCode == 404 ||
        response.statusCode == 500 ||
        response.statusCode == 522 ||
        response.statusCode == 429) {
      return {
        APIRESPONSE.ERROR: {'Message': 'Something went wrong\nTry again later.'}
      };
    } else if (response.statusCode == 502) {
      return {
        APIRESPONSE.ERROR: {'Message': 'Cannot process right now\nTry again later.'}
      };
    } else if (response.statusMessage == 'CONFLICT') {
      return {APIRESPONSE.ERROR: response.data};
    } else if (response.statusCode == 400 || response.statusCode == 404 || response.statusCode == 450) {
      return {APIRESPONSE.ERROR: response.data};
    } else {
      return {
        APIRESPONSE.ERROR: {"Message": "Something went wrong\nTry again later."}
      };
    }
  }

  Map<String, dynamic> _handleException(dynamic e) {
    if (e is SocketException) {
      _showDialog('Internet Connection Error');
      return {APIRESPONSE.EXCEPTION: APIEXCEPTION.SOCKET};
    } else if (e is HttpException) {
      _showDialog('Internet Connection Error');
      return {APIRESPONSE.EXCEPTION: APIEXCEPTION.HTTP};
    } else if (e is FormatException) {
      _showDialog('Server Bad response');
      return {APIRESPONSE.EXCEPTION: APIEXCEPTION.FORMAT};
    } else if (e is apiClient.DioException) {
      _showDialog('Something went wrong,\nTry again later.');
      return _handleDioException(e);
    } else {
      _showDialog(e.toString().contains("SocketException") ? "Internet Connection Error" : "Unknown error occurred");
      return {
        APIRESPONSE.EXCEPTION:
            e.toString().contains("SocketException") ? "Internet Connection Error" : APIEXCEPTION.UNKNOWN
      };
    }
  }

  Map<String, dynamic> _handleDioException(apiClient.DioException e) {
    switch (e.type) {
      case apiClient.DioExceptionType.connectionTimeout:
        return {APIRESPONSE.EXCEPTION: "Connection timeout"};
      case apiClient.DioExceptionType.sendTimeout:
        return {APIRESPONSE.EXCEPTION: "Sent timeout"};
      case apiClient.DioExceptionType.receiveTimeout:
        return {APIRESPONSE.EXCEPTION: "Receive timeout"};
      case apiClient.DioExceptionType.connectionError:
        return {APIRESPONSE.EXCEPTION: "Server error"};
      case apiClient.DioExceptionType.badCertificate:
        return {APIRESPONSE.EXCEPTION: "Server Certificate Error"};
      case apiClient.DioExceptionType.badResponse:
        return {APIRESPONSE.EXCEPTION: "Bad Request"};
      case apiClient.DioExceptionType.unknown:
        return {APIRESPONSE.EXCEPTION: "Server Unknown Error"};
      case apiClient.DioExceptionType.cancel:
        _showDialog('Request cancelled');
        return {APIRESPONSE.EXCEPTION: "Cancel"};
    }
  }

  void _showDialog(String message) {
    showCupertinoModalPopup(
      barrierDismissible: false,
      useRootNavigator: false,
      context: Get.context!,
      builder: (context) => PopScope(
        canPop: false,
        child: CupertinoAlertDialog(
          actions: [
            CupertinoDialogAction(
              onPressed: () => Get.back(),
              child: const Text('Ok'),
            )
          ],
          content: Text(message),
        ),
      ),
    );
  }
}
