import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/auth_controller.dart';
import '../../controller/home_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AlfaWebView2 extends StatefulWidget {
  final String? url;
  final bool? isSaveCard;
  const AlfaWebView2({super.key, this.url, this.isSaveCard});
  @override
  State<AlfaWebView2> createState() => _AlfaWebViewState();
}

class _AlfaWebViewState extends State<AlfaWebView2> {
  late final WebViewController controller;
  late VideoPlayerController _videocontroller;
  var loadingPercentage = 0;
  bool isNoInternet = false;
  Future<void> handlePageFinished(String url) async {
    // 'Recharge%20Success' old
    if (url.contains('status') && url.contains('status=succes')) {
      await showSuccessPopup();
      return;
    } else if (url.contains('status=failure')) {
      //status=failure
      showPaymentCancelledPopup('Payment Failed');
      return;
    } else if (url.contains('status=cancel')) {
      showPaymentCancelledPopup('Payment Cancelled');
    }
  }

//VideoPlayer(VideoPlayerController.asset('assets/video/mc_success.mp4')..play()),
  Future<void> showSuccessPopup() async {
    await showCupertinoModalPopup(
      barrierDismissible: false,
      context: Get.context!,
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
                  child: VideoPlayer(
                    _videocontroller..play(),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text('M-Tag Successfully Recharged'),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () async {
                  await Get.find<HomeController>().refreshDashBoardData();
                  await Get.offAllNamed('/dashboard');
                },
                child: const Text('Ok'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showPaymentCancelledPopup(String message) async {
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
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(message),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () async {
                  await Get.offAllNamed('/dashboard');
                },
                child: const Text('Ok'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _videocontroller = VideoPlayerController.asset('assets/mcsuccess.mp4',
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: true,
        ))
      ..setLooping(false)
      ..initialize();
    if (widget.isSaveCard == true) {
      controller = WebViewController(
        onPermissionRequest: (request) {
          request.grant();
        },
      )
        ..setNavigationDelegate(NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) {
              setState(() {});
            }
          },
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                loadingPercentage = progress;
              });
            }
          },
          onPageFinished: (url) async {
            log('Finished page Result ==::${url.toString()}');
            if (mounted) {
              await handlePageFinished(url);
            }
          },
          onWebResourceError: (error) {
            log(error.errorType.toString());
            if (error.errorType == WebResourceErrorType.proxyAuthentication ||
                error.errorType == WebResourceErrorType.failedSslHandshake ||
                error.errorType == WebResourceErrorType.hostLookup ||
                error.errorType == WebResourceErrorType.fileNotFound ||
                error.errorType == WebResourceErrorType.badUrl ||
                error.errorType == WebResourceErrorType.connect ||
                error.errorType == WebResourceErrorType.badUrl) {
              isNoInternet = true;
              if (mounted) setState(() {});
            }
          },
        ))
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..platform.params
        ..scrollTo(0, 0)
        ..clearCache()
        ..setOnConsoleMessage((message) async {
          log("webview payment log${message.level} ${message.message}");
          if (message.message == 'Payment cancelled') {
            await showPaymentCancelledPopup(message.message);
          }
          if (message.message == 'Recharge Success') {
            showSuccessPopup();
          }
          if (message.message == 'Payment timeout') {
            showCupertinoModalPopup(
              context: Get.context!,
              builder: (_) => CupertinoAlertDialog(
                content: const Text('Error while processing your payment'),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () async {
                      if (mounted) {
                        await Get.toNamed('/dashboard');
                      }
                    },
                    child: const Text('Ok'),
                  )
                ],
              ),
            );
          }
        });
    } else {
      controller = WebViewController(
        onPermissionRequest: (request) {
          request.grant();
        },
      )
        ..addJavaScriptChannel('CHANNEL_NAME', onMessageReceived: (v) {
          log('channel message${v.toString()}');
        })
        ..setNavigationDelegate(NavigationDelegate(
          onHttpError: (error) {
            log('HTTP ERORR:$error');
          },
          onPageStarted: (url) {
            if (mounted) {
              setState(() {});
            }
          },
          onNavigationRequest: (request) async {
            log('navigatioback-->${request.url}');
            return NavigationDecision.navigate;
          },
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                loadingPercentage = progress;
              });
            }
          },
          onPageFinished: (url) async {
            log('Finished page Result ==::${url.toString()}');
            if (mounted) {
              await handlePageFinished(url);
            }
          },
          onWebResourceError: (error) {
            log("ERROR:${error.errorType}".toString());
            if (error.errorType == WebResourceErrorType.proxyAuthentication) {
              isNoInternet = true;
              if (mounted) setState(() {});
            }
          },
        ))
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.url.toString()), headers: {
          "Accept": "application/json",
          "Connection": "Keep-Alive",
          "Authorization": "Bearer ${Get.find<AuthController>().authRepo.getAuthToken()}"
        })
        ..scrollTo(0, 0)
        ..clearCache()
        ..getUserAgent()
        ..canGoBack()
        ..currentUrl()
        ..goBack()
        ..enableZoom(true);
    }
  }

  @override
  void dispose() {
    controller.clearCache();
    _videocontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        showPaymentCancelledPopup('Payment has been cancelled');

        return;
      },
      child: Scaffold(resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
          title: const Text('Recharge M-TAG'),
        ),
        body: Stack(
          children: [
            isNoInternet
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning_sharp,
                          color: Colors.red,
                          size: 100,
                        ),
                        Text(
                          'Something went wrong\n Try again later.',
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  )
                : 
                WebViewWidget(
                    controller: controller,
                  ),
            if (loadingPercentage < 100)
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
