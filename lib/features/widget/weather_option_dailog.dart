import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/api/application_url.dart';
import 'package:mtag_flutterapp/controller/home_controller.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';

import '../../pages/alfawebview/weather_webview.dart';

Future<void> showWeatherUpdateDialog(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent, // important for gradient

        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// Gradient Card
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: Theme.of(context).extension<AppGradients>()!.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Title
                  Text(
                    'Weather Update',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '(Isb-Lhr Only)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _WeatherOption(
                        icon: 'assets/gate.png',
                        label: 'Plaza (M2)\nWeather Details ',
                        onTap: () async {
                          Get.back();
                          openWebView(
                            ApplicationUrl.WEATHER_TIMELINE_VIEW_URL,
                            title: 'WeatherWalay',
                          );
                        },
                      ),
                      _WeatherOption(
                        icon: 'assets/motorway-sign.png',
                        label: 'Motorway (M2)\nWeather Map',
                        onTap: () async {
                          Get.back();
                          openWebView(
                            ApplicationUrl.WEATHER_MAP_VIEW_URL,
                            title: 'WeatherWalay',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Close Button (Floating)
            Positioned(
              top: 1,
              right: 1,
              child: Material(
                color: scheme.surface,
                shape: const CircleBorder(),
                elevation: 4,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Get.back();
                    Get.find<HomeController>().changePage(0);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.close_rounded, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _WeatherOption extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _WeatherOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: scheme.surfaceContainerHighest,
        ),
        child: Column(
          children: [
            FittedBox(
              fit: .scaleDown,
              child: Image.asset(icon, height: 38, width: 38),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: .w500, fontSize: 12),
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }
}
