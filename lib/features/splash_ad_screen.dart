import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashAdScreen extends StatefulWidget {
  final Widget nextScreen;
  final int seconds;

  const SplashAdScreen({
    super.key,
    required this.nextScreen,
    this.seconds = 3,
  });

  @override
  State<SplashAdScreen> createState() => _SplashAdScreenState();
}

class _SplashAdScreenState extends State<SplashAdScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _navigated = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.seconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_isPaused) return;

      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _navigateToNext();
      }
    });
  }

  void _navigateToNext() {
    if (_navigated) return;
    _navigated = true;
    _timer?.cancel();
    _timer = null;

    // Ensure we use Get.off to replace the splash screen in the navigation stack
    Get.off(() => widget.nextScreen);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get device dimensions for image cache optimization
    final size = MediaQuery.sizeOf(context);
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onLongPressStart: (_) {
          setState(() {
            _isPaused = true;
          });
        },
        onLongPressEnd: (_) {
          setState(() {
            _isPaused = false;
          });
        },
        child: Stack(
          children: [
            // Full screen image with error handling and memory optimization
            Positioned.fill(
              child: Image.asset(
                'assets/slider/14.webp',
                fit: BoxFit.fill,
                // Optimization: Resize decoded image to actual screen resolution to save memory
                cacheWidth: (size.width * devicePixelRatio).toInt(),
                cacheHeight: (size.height * devicePixelRatio).toInt(),
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image is missing to prevent crash
                  return Container(
                    color: Colors.white,
                    child: const Center(
                      child: Icon(Icons.image_not_supported,
                          size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            // Skip button with timer positioned at top right
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 16,
              child: GestureDetector(
                onTap: _navigateToNext,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 1,
                        height: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_remainingSeconds',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
