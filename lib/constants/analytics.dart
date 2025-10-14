import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  static late FirebaseAnalytics _analytics;

  static Future<void> initialize() async {
    try {
      print("🔥 Starting Analytics initialization");
      _analytics = FirebaseAnalytics.instance;
      await _analytics.setAnalyticsCollectionEnabled(true);
      print("✅ Analytics initialized");
    } catch (e) {
      print("❌ Error initializing analytics: $e");
    }
  }

  static Future<void> screenOpened(String screenName) async {
    try {
      print("📊 Logging screen: $screenName");
      await _analytics.logEvent(
        name: "screen_opened",
        parameters: {"screen": screenName},
      );
      print("✅ Screen event logged: $screenName");
    } catch (e) {
      print("❌ Error logging screen: $e");
    }
  }

  static Future<void> featureUsed(String featureName) async {
    try {
      print("📊 Logging feature: $featureName");
      await _analytics.logEvent(
        name: "feature_used",
        parameters: {"feature": featureName},
      );
      print("✅ Feature event logged: $featureName");
    } catch (e) {
      print("❌ Error logging feature: $e");
    }
  }
}
