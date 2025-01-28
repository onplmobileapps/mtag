import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../api/auth_controller.dart';
import '../../controller/home_controller.dart';
import 'package:video_player/video_player.dart';

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
      pageZoom: 1);
  late VideoPlayerController _videocontroller;
  int loadingPercentage = 0;
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
    else if(url.contains('invalid')){
       showPaymentCancelledPopup('Payment Failed Due to Invalid Card Details');
    }
  }


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
    _videocontroller = VideoPlayerController.asset('assets/mcsuccess.mp4',
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: true,
        ))
      ..setLooping(false)
      ..initialize();
    super.initState();
  }

  @override
  void dispose() {
    _videocontroller.dispose();
    _appWebViewController?.stopLoading();
    _appWebViewController?.dispose();

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
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
          title: const Text('Recharge M-TAG'),
        ),
        body: isNoInternet
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
            : Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(widget.url.toString()),
                      headers: {
                        "Accept": "application/json",
                        "User-Agent":
                            "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.0.0 Mobile Safari/537.36",
                        "Connection": "Keep-Alive",
                        "Access-Control-Allow-Origin":"*",
                        "Authorization":
                            "Bearer ${Get.find<AuthController>().authRepo.getAuthToken()}"
                      },
                    ),
                    initialSettings: settings,
                    onWebViewCreated: (controller) async {
                    if(_appWebViewController!=null){
                      _appWebViewController?.dispose();
                      _appWebViewController= controller;
                    }
                       

                    },
                    onDidReceiveServerRedirectForProvisionalNavigation:
                        (controller) {
                        
                         
                        },
                    onLoadStart: (controller, url) {
if(mounted)                      setState(() {});
                    },
                    onPermissionRequest: (controller, request) async {
                      return PermissionResponse(
                          resources: request.resources,
                          action: PermissionResponseAction.GRANT);
                    },
                    onPageCommitVisible: (controller, url) {
                      if (mounted) handlePageFinished(url.toString());
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async{
                          log("navigation Url==>${navigationAction.request.url} $navigationAction");
                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStop: (controller, url) {
                      log('load stope==>${url?.data}');
                    },
                    onReceivedError: (controller, request, error) {
                   
                      log("Error on Load==>${error.description}");
                      if (error.type ==
                              WebResourceErrorType.BAD_SERVER_RESPONSE || 
                          error.type ==
                              WebResourceErrorType.NETWORK_CONNECTION_LOST ||
                          error.type ==
                              WebResourceErrorType.CANNOT_LOAD_FROM_NETWORK ||
                          error.type ==
                              WebResourceErrorType.NOT_CONNECTED_TO_INTERNET ||
                          error.type == WebResourceErrorType.BAD_URL ||
                          error.type == WebResourceErrorType.HOST_LOOKUP ||
                          error.type == WebResourceErrorType.FILE_NOT_FOUND ||
                          error.type == WebResourceErrorType.CANCELLED ||
                          error.type ==
                              WebResourceErrorType
                                  .CLIENT_CERTIFICATE_REJECTED ||error.type==WebResourceErrorType.CANNOT_CONNECT_TO_HOST||
                          error.type ==
                              WebResourceErrorType.CANNOT_LOAD_FROM_NETWORK) {
                        isNoInternet = true;
                        if (mounted) setState(() {});
                      }
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() {
                        loadingPercentage = progress;
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, isReload) {
                      setState(() {});
                    },
                    onConsoleMessage: (controller, consoleMessage) {},
                    onReceivedHttpError: (controller, request, errorResponse) =>
                        log(errorResponse.toString()),
                    onLoadResource: (controller, resource) =>
                        log(resource.toString()),
                    onReceivedServerTrustAuthRequest:
                        (controller, challenge) async =>
                            ServerTrustAuthResponse(
                                action: ServerTrustAuthResponseAction.PROCEED),
                               
                  ),
                  if (loadingPercentage < 100)
                    LinearProgressIndicator(
                      color: Theme.of(context).primaryColor,
                      minHeight: 5.0,
                      value: loadingPercentage / 100.00,
                    )
                ],
              ),
      ),
    );
  }
}
