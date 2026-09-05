import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

final class GlobalErrorHandler {
  GlobalErrorHandler._();

  static void initialize() {
    _handleFlutterErrors();
    _handlePlatformErrors();
  }

  static void _handleFlutterErrors() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final ex = details.exception;
      final msg = ex.toString().toLowerCase();

      if (_isIgnorable(ex, msg)) {
        if (kDebugMode) {
          _debug(
            'Ignored non-critical error (map/tile/network flake or known benign)',
            ex,
            details.stack,
          );
        } else {
          // Record as non-fatal → visible in Crashlytics but doesn't affect crash-free users
          FirebaseCrashlytics.instance.recordFlutterError(
            details,
            fatal: false,
          );
          // If you want complete silence, replace the line above with: return;
        }
        return;
      }

      // Real errors go here
      if (kDebugMode) {
        _debug('Flutter error', ex, details.stack);
        FirebaseCrashlytics.instance.recordFlutterError(details);
        return;
      }

      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
  }

  static void _handlePlatformErrors() {
    PlatformDispatcher.instance.onError = (error, stack) {
      final msg = error.toString().toLowerCase();

      if (_isIgnorable(error, msg)) {
        if (kDebugMode) {
          _debug(
            'Ignored async non-critical error (map/tile/network flake)',
            error,
          );
        }
        return true;
      }

      if (kDebugMode) {
        _debug('Async error', error, stack);
        return true;
      }

      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static bool _isIgnorable(dynamic ex, String msg) {
    final lowerMsg = msg.toLowerCase();

    // ────────────────────────────────────────────────
    // Your original ignored signatures
    // ────────────────────────────────────────────────
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
      'handshakeexception',
      'connection terminated during handshake',
      'connection closed before full header',
      'tlsv1_alert_decode_error',
    ];

    if (ignoredSignatures.any(lowerMsg.contains)) return true;

    // ────────────────────────────────────────────────
    // Empty / invalid asset paths
    // ────────────────────────────────────────────────
    if (lowerMsg.contains('unable to load asset: ""') ||
        (lowerMsg.contains('unable to load asset:') &&
            (ex.toString().contains('""') || ex.toString().contains("''")))) {
      return true;
    }

    // ────────────────────────────────────────────────
    // Map / Tile / flutter_map specific network flakes
    // (most common on iOS when backgrounding)
    // ────────────────────────────────────────────────
    if (lowerMsg.contains('bad file descriptor') ||
        lowerMsg.contains('errno = 9') ||
        lowerMsg.contains('networktileimageprovider') ||
        lowerMsg.contains('tile provider') ||
        lowerMsg.contains('tile_layer') ||
        (lowerMsg.contains('multi frame image stream') &&
            (lowerMsg.contains('error') ||
                lowerMsg.contains('failed') ||
                lowerMsg.contains('exception'))) ||
        lowerMsg.contains('image stream completer') &&
            lowerMsg.contains('flutter_map')) {
      return true;
    }

    // ────────────────────────────────────────────────
    // Broader socket / OS / network errors
    // (safety net for any map or http related failure)
    // ────────────────────────────────────────────────
    if (ex is SocketException ||
        ex is OSError ||
        ex is HandshakeException ||
        lowerMsg.contains('socketexception') ||
        lowerMsg.contains('clientexception') ||
        lowerMsg.contains('os error')) {
      return true;
    }

    return false;
  }

  static void _debug(String label, Object error, [StackTrace? stack]) {
    if (!kDebugMode) return;
    debugPrint('🧩 $label → $error');
    if (stack != null) {
      debugPrint('📍 Stack:\n$stack');
    }
  }
}
