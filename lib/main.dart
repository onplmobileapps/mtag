import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../pages/login/login_screen.dart';
import '../../api/auth_controller.dart';
import '../../api/auth_repo.dart';
import '../../base/app_data.dart';
import '../../pages/dashboard/home_page.dart';
import '../../pages/splash/splash_screen.dart';
import '../../remoteconfig/firebase_remote_config.dart';
import '../../utils/utils.dart';
import '../../bindings.dart';
import '../../theme/app_theme.dart';
import '/../fcm_handeler.dart';
import '../../firebase_options.dart';
import '../../routes/approute.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppData.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
    FirebaseInAppMessaging.instance.triggerEvent('open_app');
    WidgetsBinding.instance.addPostFrameCallback((_) {
    if(Platform.isAndroid)  AppUpdate.checkForUpdates();
      DeviceInfo.getDeviceInfo();
      FirebaseRemoteConfigService().fetchRemoteConfig();
      _messagingService.init(context);
      AppData.setCount(1);
    });
  }

  @override
  void dispose() {
    super.dispose();
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
        themeMode: AppData.theme == false || AppData.theme == null ? ThemeMode.light : ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: Get.put(AuthController(authRepo: AuthRepo(sharedPreferences: AppData.preference))).isLogedIn() == true
            ? HomePage()
            : Platform.isIOS
                ? const SplashScreen()
                : LoginScreen());
  }
}

const Color redAccent = Color(0XffE73B3E);

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
