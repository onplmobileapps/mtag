import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/db/stations_database.dart';
import 'package:mtag_flutterapp/db/toll_database.dart';
import 'package:upgrader/upgrader.dart';
import '/../fcm_handeler.dart';
import '/pages/login/create_pin_page.dart';
import '../../base/app_data.dart';
import '../../bindings.dart';
import '../../firebase_options.dart';
import '../../remoteconfig/firebase_remote_config.dart';
import '../../routes/approute.dart';
import '../../theme/app_theme.dart';
import '../../utils/utils.dart';
import 'pages/login/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppData.initialize();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    const MTagApp(),
  );
}

class MTagApp extends StatefulWidget {
  const MTagApp({super.key});

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
      // await FirebaseRemoteConfigService().initializeNotifications();

      AppData.setCount(1);

      //load toll data
      // await TollDatabase.instance.loadDataFromCsvAndInsert();
      await TollDatabase.instance.importDataIfNeeded();

      // await StationsDatabase.instance.loadStationsFromCsv();
      await StationsDatabase.instance.importDataIfNeeded();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Base GetMaterialApp widget
    return GetMaterialApp(
        smartManagement: SmartManagement.keepFactory,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 30),
        popGesture: false,
        useInheritedMediaQuery: true,
        builder: (context, child) {
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(
              textScaler: const TextScaler.linear(1),
            ),
            child: child!,
          );
        },
        initialBinding: Binding(),
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
        home: Platform.isIOS // Check if the platform is iOS
            ? UpgradeAlert(
                upgrader: Upgrader(
                  upgraderOS: UpgraderOS(),
                  languageCode: "en",
                  countryCode: "US",
                  debugLogging: true,
                  willDisplayUpgrade: (
                          {required display, installedVersion, versionInfo}) =>
                      display,
                ),
                dialogStyle: UpgradeDialogStyle.cupertino,
                cupertinoButtonTextStyle:
                    const TextStyle(fontFamily: 'Poppins'),
                barrierDismissible: false,
                showIgnore: false,
                showLater: false,
                showReleaseNotes: true,
                child:
                    AppData.getPinData() != null ? PinEntryPage() : AuthPage(),
              )
            : AppData.getPinData() != null
                ? const PinEntryPage()
                : AuthPage());
    // : KisokLogin());

    // Apply UpgradeAlert only for iOS
  }
}

const Color redAccent = Color(0XffE73B3E);

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.idleTimeout =
        const Duration(seconds: 30); // Increase timeout duration
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}
