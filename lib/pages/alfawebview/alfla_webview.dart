import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/controller/home_controller.dart';

import 'package:webview_flutter/webview_flutter.dart';

class AlfaWebView extends StatefulWidget {
  final String? url;
  const AlfaWebView({super.key, this.url});
  @override
  State<AlfaWebView> createState() => _AlfaWebViewState();
}

class _AlfaWebViewState extends State<AlfaWebView> {
  late final WebViewController controller;
  var loadingPercentage = 0;
  bool isNoInternet = false;
  Future<void> handlePageFinished(String url) async {
    if (url.contains('Recharge%20Success') && url.contains('status=succes')) {
      await showSuccessPopup();
    }
  }

  Future<void> showSuccessPopup() async {
    await showCupertinoModalPopup(
      barrierDismissible: false,
      context: Get.context!,
      builder: (_) => CupertinoAlertDialog(
        content: const Text('M-Tag Successfully Recharged'),
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
    );
  }

  Future<void> showPaymentCancelledPopup() async {
    await showCupertinoModalPopup(
      barrierDismissible: false,
      context: Get.context!,
      builder: (_) => CupertinoAlertDialog(
        content: const Text('Payment has been cancelled'),
        actions: [
          CupertinoDialogAction(
            onPressed: () async {
              await Get.offAllNamed('/dashboard');
            },
            child: const Text('Ok'),
          )
        ],
      ),
    );
  }

  // String? url =

  @override
  void initState() {
    super.initState();
    log(widget.url.toString());
    controller = WebViewController(
      onPermissionRequest: (request) {
        request.grant();
      },
    )
      ..getUserAgent()
      ..scrollTo(0, 0)
      ..canGoBack()
      ..goBack()
      ..enableZoom(true)
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
          log('Finishedpage Result${url.toString()}');
          if (mounted) {
            await handlePageFinished(url);
          }
        },
        onWebResourceError: (error) {
          log(error.errorType.toString());
          if (error.errorType == WebResourceErrorType.proxyAuthentication ||
              error.errorType == WebResourceErrorType.failedSslHandshake ||
              error.errorType == WebResourceErrorType.connect ||
              error.errorType == WebResourceErrorType.fileNotFound ||
              error.errorType == WebResourceErrorType.hostLookup ||
              error.errorType == WebResourceErrorType.timeout) {
            isNoInternet = true;
            if (mounted) setState(() {});
          }
        },
      ))
      ..getTitle()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url ?? ''))
      ..scrollTo(0, 0)
      ..clearCache()
      ..setOnConsoleMessage((message) async {
        log("webview payment log${message.level} ${message.message}");
        if (message.message == 'Payment cancelled') {
          await showPaymentCancelledPopup();
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
  }

  @override
  void dispose() {
    controller.clearCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
        title: const Text('Recharge M-TAG'),
      ),
      body: Stack(children: [
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
            : WebViewWidget(
                controller: controller,
              ),
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            color: Theme.of(context).primaryColor,
            minHeight: 5.0,
            value: loadingPercentage / 100.00,
          )
      ]),
    );
  }

  String? getQueryString(String? url, String? tag) {
    try {
      Uri uri = Uri.parse(url ?? '');
      return uri.queryParameters[tag];
    } catch (e) {
      log('Webview: getQueryString() $e');
    }
    return '';
  }
}
