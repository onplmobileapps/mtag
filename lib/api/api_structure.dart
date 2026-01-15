// ignore_for_file: library_prefixes

import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart' as apiClient;
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

          // Check connectivity
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

      log("Request Body: $body");
      log("$apiUrl response:[${response.statusCode}] ---> $response");

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
    final int statusCode = response.statusCode ?? 0;

    if (statusCode == 200) {
      return {APIRESPONSE.SUCCESS: response.data, 'statusCode': statusCode};
    } else if ([500, 502, 504, 522, 429].contains(statusCode)) {
      return {
        APIRESPONSE.ERROR: {
          'Message':
              'We couldn’t complete your request\nTry again or contact assistance.',
        },
        'statusCode': statusCode,
      };
    } else if ([400, 404, 409, 450].contains(statusCode) ||
        response.statusMessage == 'CONFLICT') {
      return {
        APIRESPONSE.ERROR: response.data ?? {'Message': 'Unknown error'},
        'statusCode': statusCode,
      };
    } else {
      return {
        APIRESPONSE.ERROR: {
          'Message': 'We couldn’t complete your request\nTry again later.',
        },
        'statusCode': statusCode,
      };
    }
  }

  static Map<String, dynamic> _handleException(dynamic e) {
    String errorMessage = "Unknown error";

    if (e is apiClient.DioException) {
      switch (e.type) {
        case apiClient.DioExceptionType.connectionTimeout:
          errorMessage = 'Connection timeout';
          break;
        case apiClient.DioExceptionType.sendTimeout:
          errorMessage = 'Send timeout';
          break;
        case apiClient.DioExceptionType.receiveTimeout:
          errorMessage = 'Receive timeout';
          break;
        case apiClient.DioExceptionType.connectionError:
          errorMessage = 'Server error';
          break;
        case apiClient.DioExceptionType.badCertificate:
          errorMessage = 'Server Certificate Error';
          break;
        case apiClient.DioExceptionType.badResponse:
          errorMessage = 'Bad Request';
          break;
        case apiClient.DioExceptionType.unknown:
          errorMessage = 'Server Unknown Error';
          break;
        case apiClient.DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
      }
    } else if (e is SocketException) {
      errorMessage = 'Internet Connection Error';
    } else if (e is HttpException) {
      errorMessage = 'Internet Connection Error';
    } else if (e is FormatException) {
      errorMessage = 'Server Bad response';
    }

    return {APIRESPONSE.EXCEPTION: errorMessage, 'statusCode': 0};
  }
}

Future<Map<String, dynamic>> safeRequest({
  required APISTRUCTURE api,
  bool showLoader = true,
}) async {
  try {
    // Show loader if requested
    if (showLoader) ApiLoader.show();

    final response = await api.requestAPI(
      isShowLoading: false, // prevent double hiding
      isCheckAuthorization: true,
    );

    // Hide loader automatically if error
    if ((response['statusCode'] ?? 0) != 200 && showLoader) {
      ApiLoader.hide();
    }

    return response;
  } catch (e) {
    if (showLoader) ApiLoader.hide();
    // Convert unexpected exceptions to standard response
    return {APIRESPONSE.EXCEPTION: e.toString(), 'statusCode': 0};
  } finally {
    if (showLoader) ApiLoader.hide();
  }
}
