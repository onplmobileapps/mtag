import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/pages/login/auth_page.dart';
import 'package:mtag_flutterapp/pages/login/create_pin_page.dart';
import 'package:mtag_flutterapp/widgets/connectivity_banner.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'base/app_data.dart';
import 'bindings.dart';
import 'db/stations_database.dart';
import 'db/toll_database.dart';
import 'fcm_handeler.dart';
import 'firebase_options.dart';
import 'remoteconfig/firebase_remote_config.dart';
import 'routes/approute.dart';
import 'theme/app_theme.dart';
import 'utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppData.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    name: 'mtagFlutter',
  );

  setupErrorHandling();

  final sharedPreferences = await SharedPreferences.getInstance();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  HttpOverrides.global = MyHttpOverrides();

  runApp(MTagApp(sharedPreferences: sharedPreferences));
}

class MTagApp extends StatefulWidget {
  final SharedPreferences sharedPreferences;

  const MTagApp({super.key, required this.sharedPreferences});

  @override
  State<MTagApp> createState() => _MTagAppState();
}

class _MTagAppState extends State<MTagApp> {
  final _messagingService = MessagingService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Platform.isAndroid) await AppUpdate.checkForUpdates();
      await DeviceInfo.getDeviceInfo();
      FirebaseRemoteConfigService().fetchRemoteConfig();
      if (mounted) _messagingService.init(context);

      // preload DBs
      await TollDatabase.instance.importDataIfNeeded();
      await StationsDatabase.instance.importDataIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      smartManagement: SmartManagement.keepFactory,
      defaultTransition: Transition.native,
      transitionDuration: const Duration(milliseconds: 30),
      popGesture: Platform.isIOS,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: ConnectionBanner(child: child ?? const SizedBox()),
        );
      },
      initialBinding: Binding(widget.sharedPreferences),
      getPages: getPages,
      theme: (AppData.theme == null || AppData.theme == false)
          ? appTheme
          : AppData.theme == true
          ? darkTheme
          : appTheme,
      darkTheme: darkTheme,
      themeMode: AppData.theme == false || AppData.theme == null
          ? ThemeMode.light
          : ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Platform.isIOS
          ? UpgradeAlert(
              upgrader: Upgrader(
                upgraderOS: UpgraderOS(),
                languageCode: "en",
                countryCode: "PK",
                durationUntilAlertAgain: const Duration(days: 1),
                messages: CustomUpgraderMessages()..languageCode,
                debugLogging: kDebugMode,
                willDisplayUpgrade:
                    ({
                      required bool display,
                      String? installedVersion,
                      UpgraderVersionInfo? versionInfo,
                    }) {
                      if (kDebugMode) {
                        debugPrint('🟢 Upgrade check:');
                        debugPrint('Installed version: $installedVersion');
                        debugPrint(
                          'App Store version: ${versionInfo?.appStoreVersion}',
                        );
                        debugPrint('Display = $display');
                      }

                      if (installedVersion != null &&
                          versionInfo?.appStoreVersion != null) {
                        final installed = Version.parse(installedVersion);
                        final store = versionInfo!.appStoreVersion!;

                        if (store > installed) {
                          if (kDebugMode) debugPrint('⬆️ Update available!');
                          Upgrader.clearSavedSettings();
                        } else {
                          if (kDebugMode) debugPrint('✅ App is up-to-date.');
                        }
                      }
                    },
              ),
              dialogStyle: UpgradeDialogStyle.cupertino,
              cupertinoButtonTextStyle: const TextStyle(fontFamily: 'Poppins'),
              barrierDismissible: false,
              showIgnore: false,
              showLater: false,
              showReleaseNotes: true,
              child: AppData.getPinData() != null ? PinEntryPage() : AuthPage(),
            )
          : AppData.getPinData() != null
          ? PinEntryPage()
          : AuthPage(),
    );
  }
}

const Color redAccent = Color(0XffE73B3E);

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.idleTimeout = const Duration(seconds: 30);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

class CustomUpgraderMessages extends UpgraderMessages {
  @override
  String get title => '🚀 New Update Available!';

  @override
  String get body =>
      'We’ve made some great improvements and bug fixes. Please update now for the best experience.';

  @override
  String get buttonTitleUpdate => 'Update Now';

  @override
  String get buttonTitleIgnore => 'Skip';

  @override
  String get buttonTitleLater => 'Remind Me Later';
}

void setupErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (_shouldIgnoreError(details.exception)) {
      if (kDebugMode) {
        debugPrint('🚫 Ignored error: ${details.exception}');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('🐛 Debug mode - Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
      return;
    }

    debugPrint('📊 Production - Logging to Crashlytics: ${details.exception}');
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (_shouldIgnoreError(error)) {
      if (kDebugMode) {
        debugPrint('🚫 Ignored async error: $error');
      }
      return true;
    }

    if (kDebugMode) {
      debugPrint('🐛 Debug mode - Async error: $error');
      debugPrint('Stack trace: $stack');
      return true;
    }

    debugPrint('📊 Production - Logging async error to Crashlytics: $error');
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

bool _shouldIgnoreError(dynamic exception) {
  final errorString = exception.toString();

  final ignoredPatterns = [
    'Could not launch',
    'No application found',
    'No Activity found',
    'No installed applications',
    'url_launcher',
    'No directions apps',
    'Maps app not available',
    'No map application',
    'ERR_UNKNOWN_URL_SCHEME',

    'basemaps.cartocdn.com',
    'a.basemaps.cartocdn.com',
    'b.basemaps.cartocdn.com',
    'c.basemaps.cartocdn.com',
  ];

  final shouldIgnore = ignoredPatterns.any(
    (pattern) => errorString.toLowerCase().contains(pattern.toLowerCase()),
  );

  if (errorString.contains('Failed host lookup') &&
      errorString.contains('basemaps.cartocdn.com')) {
    return true;
  }

  return shouldIgnore;
}
