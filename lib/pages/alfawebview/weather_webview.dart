import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/widgets/gradient_appbar.dart';

//weather code complete
class WebViewController extends GetxController {
  var title = ''.obs;
  var isLoading = true.obs;
}

void openWebView(String url, {String? title, bool showLoader = true}) {
  Get.to(
    () => InAppWebViewScreen(url: url, title: title, showLoader: showLoader),
  );
}

class InAppWebViewScreen extends StatefulWidget {
  final String url;
  final String? title;
  final bool showLoader;

  const InAppWebViewScreen({
    super.key,
    required this.url,
    this.title,
    this.showLoader = true,
  });

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  late InAppWebViewController webViewController;
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<WebViewController>()
        ? Get.find<WebViewController>()
        : Get.put(WebViewController());

    if (!widget.showLoader) {
      controller.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title:  Text(widget.title ?? '')),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useOnLoadResource: true,
              mediaPlaybackRequiresUserGesture: false,
            ),
            onWebViewCreated: (controllerInstance) {
              webViewController = controllerInstance;
            },
            onTitleChanged: widget.title == null
                ? (controllerInstance, title) {
                    if (title != null) {
                      controller.title.value = title;
                    }
                  }
                : null,
            onLoadStart: (controllerInstance, url) {
              if (widget.showLoader) {
                controller.isLoading.value = true;
              }
            },
            onLoadStop: (controllerInstance, url) {
              if (widget.showLoader) {
                controller.isLoading.value = false;
              }
            },
          ),
          if (widget.showLoader)
            Obx(
              () => controller.isLoading.value
                  ? LinearProgressIndicator(value: 100,)
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
