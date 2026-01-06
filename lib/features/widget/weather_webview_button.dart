import 'package:flutter/material.dart';

import '../../pages/alfawebview/weather_webview.dart';

class WeatherExpandButton extends StatefulWidget {
  const WeatherExpandButton({super.key});

  @override
  State<WeatherExpandButton> createState() => _WeatherExpandButtonState();
}

class _WeatherExpandButtonState extends State<WeatherExpandButton> {
  bool _expanded = false;

  void _onOptionSelected(VoidCallback action) {
    action(); // execute the option
    setState(() => _expanded = false); // collapse after selection
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      height: _expanded ? 100 : 50, // height grows when expanded
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: .only(
          topLeft: .circular(_expanded ? 10 : 12),
          bottomLeft: .circular(_expanded ? 10 : 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: _expanded
                      ? const SizedBox()
                      : GestureDetector(
                          onTap: () => setState(() => _expanded = true),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/weather-news.png',
                                height: 20,
                              ),

                              SizedBox(width: 4),
                              Text(
                                'Weather',
                                style: TextTheme.of(context).bodyMedium
                                    ?.copyWith(
                                      color: Colors.black,
                                      fontSize: 11,
                                    ),
                              ),
                            ],
                          ),
                        ),
                ),

                /// Options (shown when expanded)
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: _expanded
                      ? Row(
                          children: [
                            _WeatherAction(
                              icon: Icons.timeline_rounded,
                              label: 'Timeline',
                              onTap: () => _onOptionSelected(() {
                                openWebView(
                                  'https://weatherwalay.com/wowtimeline/m2',
                                );
                              }),
                            ),
                            const SizedBox(width: 12),
                            _WeatherAction(
                              icon: Icons.map_rounded,
                              label: 'Map',
                              onTap: () => _onOptionSelected(() {
                                openWebView(
                                  'https://one-network-portal.weatherwalay.com/embed-map/m2?token=IsImEiOiJjbHYwazJ0bjgxcWZuMmpyengwNWw4bHQ2In0',
                                );
                              }),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),

          // ── Close button on top-right corner ──
          if (_expanded)
            Positioned(
              top: -8,
              right: -8,
              child: GestureDetector(
                onTap: () => setState(() => _expanded = false),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeatherAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _WeatherAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
