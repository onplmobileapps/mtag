import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import 'db/stations_database.dart';
import 'db/toll_database.dart';
import 'fcm_handeler.dart';
import 'pages/login/create_pin_page.dart';
import 'base/app_data.dart';
import 'bindings.dart';
import 'firebase_options.dart';
import 'remoteconfig/firebase_remote_config.dart';
import 'routes/approute.dart';
import 'theme/app_theme.dart';
import 'utils/utils.dart';
import 'pages/login/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppData.initialize();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    name: 'mtagFlutter',
  );
  //uncomment when go to production
// FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  final sharedPreferences = await SharedPreferences.getInstance();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  HttpOverrides.global = MyHttpOverrides();

  runApp(
    MTagApp(sharedPreferences: sharedPreferences),
  );
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
      if (Platform.isAndroid) AppUpdate.checkForUpdates();
      DeviceInfo.getDeviceInfo();
      FirebaseRemoteConfigService().fetchRemoteConfig();
      _messagingService.init(context);

      AppData.setCount(1);

      // preload DBs
      await TollDatabase.instance.importDataIfNeeded();
      await StationsDatabase.instance.importDataIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      smartManagement: SmartManagement.keepFactory,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 30),
      popGesture: false,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(textScaler: const TextScaler.linear(1)),
          child: child!,
        );
      },
      // ✅ pass sharedPreferences into Binding
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
          countryCode: "US",
          debugLogging: true,
          willDisplayUpgrade: (
              {required display,
                installedVersion,
                versionInfo}) =>
          display,
        ),
        dialogStyle: UpgradeDialogStyle.cupertino,
        cupertinoButtonTextStyle: const TextStyle(fontFamily: 'Poppins'),
        barrierDismissible: false,
        showIgnore: false,
        showLater: false,
        showReleaseNotes: true,
        child: AppData.getPinData() != null
            ? PinEntryPage()
            : AuthPage(),
      )
          : AppData.getPinData() != null
          ? const PinEntryPage()
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
