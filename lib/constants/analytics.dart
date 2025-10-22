import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class Analytics {
  static late FirebaseAnalytics _analytics;

  static Future<void> initialize() async {
    try {
      debugPrint("🔥 Starting Analytics initialization");
      _analytics = FirebaseAnalytics.instance;
      await _analytics.setAnalyticsCollectionEnabled(true);
      debugPrint("✅ Analytics initialized");
    } catch (e) {
      debugPrint("❌ Error initializing analytics: $e");
    }
  }

  static Future<void> screenOpened(String screenName) async {
    try {
      debugPrint("📊 Logging screen: $screenName");
      await _analytics.logEvent(
        name: "screen_opened",
        parameters: {"screen": screenName},
      );
      debugPrint("✅ Screen event logged: $screenName");
    } catch (e) {
      debugPrint("❌ Error logging screen: $e");
    }
  }

  static Future<void> featureUsed(String featureName) async {
    try {
      debugPrint("📊 Logging feature: $featureName");
      await _analytics.logEvent(
        name: "feature_used",
        parameters: {"feature": featureName},
      );
      debugPrint("✅ Feature event logged: $featureName");
    } catch (e) {
      debugPrint("❌ Error logging feature: $e");
    }
  }
}
