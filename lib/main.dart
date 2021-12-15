import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'values/values.dart';
import 'locator.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen_base.dart';
import 'screens/intro_screen.dart';
import 'services/api.dart';
import 'utils/translations.dart';
import 'utils/utils.dart';
import 'viewmodels/user_model.dart';
import 'viewmodels/db_model.dart';

void main() async {
  Widget homePage;

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  var settings = await Utils.getAppPrefs();
  await Utils.configureLocalTimeZone();

  await Firebase.initializeApp();
  FirebaseAnalytics analytics = FirebaseAnalytics();

  await FlutterInappPurchase.instance.initConnection;

  setupLocator();
  Api _api = locator<Api>();

  if (_api.user == null) {
    homePage = settings['showSliders'] != null && !settings['showSliders'] ? WelcomeScreen() : IntroScreen();
  } else {
    if (!_api.user.emailVerified) {
      await _api.signOut();
      homePage = settings['showSliders'] != null && !settings['showSliders'] ? WelcomeScreen() : IntroScreen();
    } else {
      homePage = HomeScreenBase();
    }
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserModel>(create: (_) => locator<UserModel>()),
        ChangeNotifierProvider<DbModel>(create: (_) => locator<DbModel>()),
      ],
      child: FeatureDiscovery(
        child: GetMaterialApp(
          translations: Messages(),
          locale: Utils.currentLocale,
          title: StringConst.appName,
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.native,
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            primarySwatch: Colors.grey,
            primaryColor: Colors.black,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: AppColors.nord0,
              selectionColor: AppColors.grey2,
              selectionHandleColor: AppColors.nord0,
            ),
            fontFamily: 'TRT',
          ),
          home: homePage,
        ),
      ),
    ),
  );
}
