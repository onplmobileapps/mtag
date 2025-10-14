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
  static final apiClient.Dio _dio = _configureDio();

  APISTRUCTURE({
    this.body,
    required this.apiUrl,
    required this.apiRequestMethod,
    this.isWantSuccessMessage = false,
    this.contentType,
  });

  // Configure Dio with interceptors
  static apiClient.Dio _configureDio() {
    final dio = apiClient.Dio(
      apiClient.BaseOptions(
        baseUrl: BASE_URL,
        connectTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
        headers: {
          "Accept": "application/json",
          "Connection": "Keep-Alive",
          'User-agent': 'your bot 0.1',
        },
        followRedirects: false,
        validateStatus: (status) => status != null && status < 600,
      ),
    );

    dio.interceptors.add(
      apiClient.InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add Authorization header dynamically
          final authToken = Get.find<AuthController>().authRepo.getAuthToken();
          if (authToken != null) {
            options.headers["Authorization"] = "Bearer $authToken";
          }
          // Add Content-Type if provided
          if (options.extra['contentType'] != null) {
            options.headers["Content-Type"] = options.extra['contentType'];
          }
          // Check connectivity before proceeding
          final connectivityResult = await ConnectionCheck.isConnected();
          if (!connectivityResult.containsKey(APIRESPONSE.SUCCESS)) {
            handler.reject(
              apiClient.DioException(
                requestOptions: options,
                error: Exception(
                  connectivityResult[APIRESPONSE.ERROR]['Message'],
                ),
                type: apiClient.DioExceptionType.connectionError,
              ),
              true,
            );
            return;
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError:
            (
              apiClient.DioException e,
              apiClient.ErrorInterceptorHandler handler,
            ) {
              // Handle errors globally
              final response = _handleException(e);
              handler.resolve(
                apiClient.Response(
                  requestOptions: e.requestOptions,
                  statusCode: e.response?.statusCode ?? 500,
                  data: response,
                ),
              );
            },
      ),
    );

    return dio;
  }

  Future<Map<String, dynamic>> requestAPI({
    bool isShowLoading = false,
    bool isCheckAuthorization = false,
  }) async {
    if (isShowLoading) ApiLoader.show();

    try {
      apiClient.Response<dynamic> response;

      switch (apiRequestMethod) {
        case APIREQUESTMETHOD.GET:
          response = await _dio.get(
            apiUrl,
            options: apiClient.Options(extra: {'contentType': contentType}),
          );
          break;
        case APIREQUESTMETHOD.POST:
          response = await _dio.post(
            apiUrl,
            data: body,
            options: apiClient.Options(extra: {'contentType': contentType}),
          );
          break;
        case APIREQUESTMETHOD.DELETE:
          response = await _dio.delete(
            apiUrl,
            options: apiClient.Options(extra: {'contentType': contentType}),
          );
          break;
        case APIREQUESTMETHOD.PUT:
          response = await _dio.put(
            apiUrl,
            data: body,
            options: apiClient.Options(extra: {'contentType': contentType}),
          );
          break;
        default:
          throw Exception('Unsupported request method');
      }

      log("message$body");
      log('$apiUrl response:[${response.statusCode}]----> $response');
      if (isShowLoading) ApiLoader.hide();

      return _handleResponse(response);
    } catch (e) {
      if (isShowLoading) ApiLoader.hide();
      return _handleException(e);
    } finally {
      if (isShowLoading) ApiLoader.hide();
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
        APIRESPONSE.ERROR: {
          'Message':
              'We couldn’t complete your request\n Try again or contact assistance.',
        },
      };
    } else if (response.statusCode == 502) {
      return {
        APIRESPONSE.ERROR: {
          'Message': 'Cannot process right now\nTry again later.',
        },
      };
    } else if (response.statusMessage == 'CONFLICT' ||
        response.statusCode == 400 ||
        response.statusCode == 404 ||
        response.statusCode == 450 ||
        response.statusCode == 409) {
      log('controll here${response.statusCode}');
      return {APIRESPONSE.ERROR: response.data};
    } else {
      log('controll here${response.statusCode}');
      return {
        APIRESPONSE.ERROR: {
          "Message":
              "We couldn’t complete your request\n Try again or contact assistance.\nTry again later.",
        },
      };
    }
  }

  static Map<String, dynamic> _handleException(dynamic e) {
    if (e is apiClient.DioException) {
      switch (e.type) {
        case apiClient.DioExceptionType.connectionTimeout:
          _showDialog('Connection timeout');
          return {APIRESPONSE.EXCEPTION: "Connection timeout"};
        case apiClient.DioExceptionType.sendTimeout:
          _showDialog('Sent timeout');
          return {APIRESPONSE.EXCEPTION: "Sent timeout"};
        case apiClient.DioExceptionType.receiveTimeout:
          _showDialog('Receive timeout');
          return {APIRESPONSE.EXCEPTION: "Receive timeout"};
        case apiClient.DioExceptionType.connectionError:
          _showDialog('Server error');
          return {APIRESPONSE.EXCEPTION: "Server error"};
        case apiClient.DioExceptionType.badCertificate:
          _showDialog('Server Certificate Error');
          return {APIRESPONSE.EXCEPTION: "Server Certificate Error"};
        case apiClient.DioExceptionType.badResponse:
          _showDialog('Bad Request');
          return {APIRESPONSE.EXCEPTION: "Bad Request"};
        case apiClient.DioExceptionType.unknown:
          _showDialog('Server Unknown Error');
          return {APIRESPONSE.EXCEPTION: "Server Unknown Error"};
        case apiClient.DioExceptionType.cancel:
          _showDialog('Request cancelled');
          return {APIRESPONSE.EXCEPTION: "Cancel"};
      }
    } else if (e is SocketException) {
      _showDialog('Internet Connection Error');
      return {APIRESPONSE.EXCEPTION: APIEXCEPTION.SOCKET};
    } else if (e is HttpException) {
      _showDialog('Internet Connection Error');
      return {APIRESPONSE.EXCEPTION: APIEXCEPTION.HTTP};
    } else if (e is FormatException) {
      _showDialog('Server Bad response');
      return {APIRESPONSE.EXCEPTION: APIEXCEPTION.FORMAT};
    } else {
      _showDialog(
        e.toString().contains("SocketException")
            ? "Internet Connection Error"
            : "Unknown error occurred",
      );
      return {
        APIRESPONSE.EXCEPTION: e.toString().contains("SocketException")
            ? "Internet Connection Error"
            : APIEXCEPTION.UNKNOWN,
      };
    }
  }

  static void _showDialog(String message) {
    showCupertinoModalPopup(
      barrierDismissible: false,
      useRootNavigator: false,
      context: Get.context!,
      builder: (context) => PopScope(
        canPop: false,
        child: CupertinoAlertDialog(
          actions: [
            GestureDetector(
              onTap: () => Get.close(1),
              child: CupertinoDialogAction(
                onPressed: () => Get.close(1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: const Text('Ok', style: TextStyle(fontSize: 17)),
                ),
              ),
            ),
          ],
          content: Center(child: Text(message)),
        ),
      ),
    );
  }
}
