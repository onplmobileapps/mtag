import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/api/api_constants.dart';
import 'package:mtag_flutterapp/widgets/gradient_appbar.dart';
import '../../api/auth_controller.dart';
import '../../controller/home_controller.dart';

class AlfaWebView2 extends StatefulWidget {
  final String? url;
  final bool? isSaveCard;

  const AlfaWebView2({super.key, this.url, this.isSaveCard});

  @override
  State<AlfaWebView2> createState() => _AlfaWebViewState();
}

class _AlfaWebViewState extends State<AlfaWebView2> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? _appWebViewController;
  bool _isDisposed = false;

  InAppWebViewSettings settings = InAppWebViewSettings(
    underPageBackgroundColor: Colors.white,
    javaScriptCanOpenWindowsAutomatically: true,
    useHybridComposition: true,
    iframeAllow: "camera; microphone",
    javaScriptEnabled: true,
    cacheEnabled: true,
    clearCache: true,
    userAgent: "",
    useOnLoadResource: true,
    horizontalScrollBarEnabled: false,
    useShouldOverrideUrlLoading: true,
    verticalScrollBarEnabled: true,
    safeBrowsingEnabled: true,
    iframeAllowFullscreen: true,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    pageZoom: 1,
  );

  int loadingPercentage = 0;
  bool isNoInternet = false;

  Future<void> handlePageFinished(String url) async {
    // Critical: Check if widget is disposed
    if (_isDisposed || !mounted) return;

    try {
      if (url.contains('status') && url.contains('status=succes')) {
        if (!_isDisposed && mounted) {
          await showSuccessPopup(context);
        }
        return;
      } else if (url.contains('status=failure')) {
        if (!_isDisposed && mounted) {
          showPaymentCancelledPopup('Payment Failed');
        }
        return;
      } else if (url.contains('status=cancel')) {
        if (!_isDisposed && mounted) {
          showPaymentCancelledPopup('Payment Cancelled');
        }
      } else if (url.contains('invalid')) {
        if (!_isDisposed && mounted) {
          showPaymentCancelledPopup('Payment Failed Due to Invalid Card Details');
        }
      }
    } catch (e) {
      log('Error handling page finish: $e');
    }
  }

  Future<void> showSuccessPopup(BuildContext context) async {
    if (_isDisposed || !mounted) return;

    await showCupertinoModalPopup(
      barrierDismissible: false,
      context: context,
      builder: (_) => Theme(
        data: ThemeData.dark(),
        child: PopScope(
          canPop: false,
          child: CupertinoAlertDialog(
            content: Column(
              children: [
                SizedBox(
                  height: 120,
                  width: MediaQuery.sizeOf(context).width,
                  child: Image.asset(
                    'assets/mcsuccess.gif',
                    cacheHeight: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      log("Image decompression error: $error");
                      return const Icon(Icons.check_circle, color: Colors.green, size: 60);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                const Text('M-Tag Successfully Recharged'),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () async {
                  Get.find<HomeController>().pullRefreshDashboardData();
                  await Get.offAllNamed('/dashboard');
                },
                child: const Text('Ok'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showPaymentCancelledPopup(String message) async {
    if (_isDisposed || !mounted) return;

    await showCupertinoModalPopup(
      semanticsDismissible: false,
      useRootNavigator: false,
      barrierDismissible: false,
      context: Get.context!,
      builder: (_) => Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: PopScope(
          canPop: false,
          child: CupertinoAlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [const SizedBox(height: 10), Text(message)],
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () async {
                  await Get.offAllNamed('/dashboard');
                },
                child: const Text('Ok'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _appWebViewController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!_isDisposed && mounted) {
          showPaymentCancelledPopup('Payment has been cancelled');
        }
        return;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: GradientAppBar(
          title: const Text('Recharge M-TAG'),
        ),
        body: isNoInternet
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.warning_sharp, color: Colors.red, size: 100),
              Text(
                APIEXCEPTION.UNPROCESS,
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
            : Stack(
          children: [
            InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(
                url: WebUri(widget.url.toString()),
                headers: {
                  "Accept": "application/json",
                  "User-Agent":
                  "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.0.0 Mobile Safari/537.36",
                  "Connection": "Keep-Alive",
                  "Access-Control-Allow-Origin": "*",
                  "Authorization":
                  "Bearer ${Get.find<AuthController>().authRepo.getAuthToken()}",
                },
              ),
              initialSettings: settings,
              onWebViewCreated: (controller) async {
                if (!_isDisposed) {
                  _appWebViewController = controller;
                }
              },
              onDidReceiveServerRedirectForProvisionalNavigation: (controller) {},
              onLoadStart: (controller, url) {
                if (!_isDisposed && mounted) {
                  setState(() {});
                }
              },
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
              onPageCommitVisible: (controller, url) {
                if (!_isDisposed && mounted) {
                  handlePageFinished(url.toString());
                }
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                if (!_isDisposed) {
                  log(
                    "navigation Url==>${navigationAction.request.url} $navigationAction",
                  );
                }
                return NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) {
                if (!_isDisposed) {
                  log('load stop==>${url?.data}');
                }
              },
              onReceivedError: (controller, request, error) {
                if (_isDisposed) return;

                log("Error on Load==>${error.description}");

                if (error.type == WebResourceErrorType.BAD_SERVER_RESPONSE ||
                    error.type == WebResourceErrorType.NETWORK_CONNECTION_LOST ||
                    error.type == WebResourceErrorType.CANNOT_LOAD_FROM_NETWORK ||
                    error.type == WebResourceErrorType.NOT_CONNECTED_TO_INTERNET ||
                    error.type == WebResourceErrorType.BAD_URL ||
                    error.type == WebResourceErrorType.HOST_LOOKUP ||
                    error.type == WebResourceErrorType.FILE_NOT_FOUND ||
                    error.type == WebResourceErrorType.CANCELLED ||
                    error.type == WebResourceErrorType.CLIENT_CERTIFICATE_REJECTED ||
                    error.type == WebResourceErrorType.CANNOT_CONNECT_TO_HOST ||
                    error.type == WebResourceErrorType.CANNOT_LOAD_FROM_NETWORK) {
                  isNoInternet = true;
                  if (mounted) setState(() {});
                }
              },
              onProgressChanged: (controller, progress) {
                if (!_isDisposed && mounted) {
                  setState(() {
                    loadingPercentage = progress;
                  });
                }
              },
              onUpdateVisitedHistory: (controller, url, isReload) {
                if (!_isDisposed && mounted) {
                  setState(() {});
                }
              },
              onConsoleMessage: (controller, consoleMessage) {
                if (!_isDisposed) {
                  // Handle console messages if needed
                }
              },
              onReceivedHttpError: (controller, request, errorResponse) {
                if (!_isDisposed) {
                  log(errorResponse.toString());
                }
              },
              onLoadResource: (controller, resource) {
                if (!_isDisposed) {
                  log(resource.toString());
                }
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async =>
                  ServerTrustAuthResponse(
                    action: ServerTrustAuthResponseAction.PROCEED,
                  ),
            ),
            if (loadingPercentage < 100 && !_isDisposed)
              LinearProgressIndicator(
                color: Theme.of(context).primaryColor,
                minHeight: 5.0,
                value: loadingPercentage / 100.00,
              ),
          ],
        ),
      ),
    );
  }
}