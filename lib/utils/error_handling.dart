import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

final class GlobalErrorHandler {
  GlobalErrorHandler._();

  static void initialize() {
    _handleFlutterErrors();
    _handlePlatformErrors();
  }

  static void _handleFlutterErrors() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (_shouldIgnore(details.exception)) {
        _debug('Ignored Flutter error', details.exception);
        return;
      }

      if (kDebugMode) {
        _debug('Flutter error', details.exception, details.stack);
        return;
      }

      FirebaseCrashlytics.instance
          .recordFlutterFatalError(details);
    };
  }

  static void _handlePlatformErrors() {
    PlatformDispatcher.instance.onError = (error, stack) {
      if (_shouldIgnore(error)) {
        _debug('Ignored async error', error);
        return true;
      }

      if (kDebugMode) {
        _debug('Async error', error, stack);
        return true;
      }

      FirebaseCrashlytics.instance
          .recordError(error, stack, fatal: true);
      return true;
    };
  }

  static bool _shouldIgnore(dynamic exception) {
    final message = exception.toString().toLowerCase();

    const ignoredSignatures = [
      'could not launch',
      'no application found',
      'no activity found',
      'no installed applications',
      'err_unknown_url_scheme',
      'basemaps.cartocdn.com',
      'failed host lookup',
      'libflutter.so',
      'looked for: [x86]',
      'executionexception',
    ];

    return ignoredSignatures.any(message.contains);
  }

  static void _debug(
      String label,
      Object error, [
        StackTrace? stack,
      ]) {
    if (!kDebugMode) return;

    debugPrint('🧩 $label → $error');
    if (stack != null) {
      debugPrint('📍 Stack trace:\n$stack');
    }
  }
}