import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/widgets/gradient_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

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
  InAppWebViewController? webViewController;
  late final WebViewController controller;
  bool _isWebViewAvailable = true;
  bool _isDisposed = false;

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
  void dispose() {
    _isDisposed = true;
    webViewController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(widget.title ?? controller.title.value),
      ),
      body: Stack(
        children: [
          if (_isWebViewAvailable && !_isDisposed)
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useOnLoadResource: true,
                mediaPlaybackRequiresUserGesture: false,
              ),
              onWebViewCreated: (controllerInstance) {
                if (!_isDisposed) {
                  webViewController = controllerInstance;
                }
              },
              onTitleChanged: widget.title == null
                  ? (controllerInstance, title) {
                if (!_isDisposed && title != null) {
                  controller.title.value = title;
                }
              }
                  : null,
              onLoadStart: (controllerInstance, url) {
                if (!_isDisposed && widget.showLoader) {
                  controller.isLoading.value = true;
                }
              },
              onLoadStop: (controllerInstance, url) {
                if (!_isDisposed && widget.showLoader) {
                  controller.isLoading.value = false;
                }
              },
              onReceivedError: (controller, request, error) {
                if (_isDisposed) return;

                // Handle missing WebView provider error on Android
                if (error.description.contains('MissingWebViewPackageException') ||
                    error.description.contains('No WebView installed') ||
                    error.description.contains('WebViewFactory')) {
                  if (mounted) {
                    setState(() {
                      _isWebViewAvailable = false;
                    });
                  }
                }
              },
            )
          else if (!_isWebViewAvailable)
            _buildWebViewMissingFallback(),
          if (widget.showLoader && _isWebViewAvailable && !_isDisposed)
            Obx(
                  () => controller.isLoading.value
                  ? const LinearProgressIndicator()
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  Widget _buildWebViewMissingFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "WebView is not available on this device.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Please make sure Android System WebView is installed and enabled.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse(widget.url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text("Open in External Browser"),
            ),
          ],
        ),
      ),
    );
  }
}