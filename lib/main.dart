import 'package:aspirant/pages/addstok.dart';
import 'package:aspirant/pages/buah.dart';
import 'package:aspirant/pages/cart.dart';
import 'package:aspirant/pages/changeusn.dart';
import 'package:aspirant/pages/setting.dart';
import 'package:aspirant/pages/stok.dart';
import 'package:aspirant/pages/homeadmin.dart';
import 'package:aspirant/pages/lainnya.dart';
import 'package:aspirant/pages/profile.dart';
import 'package:aspirant/pages/rempah.dart';
import 'package:aspirant/pages/sayur.dart';
import 'package:aspirant/provider/bahasa.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:aspirant/provider/theme.dart';
import 'package:aspirant/pages/login.dart';
import 'package:aspirant/pages/homeuser.dart';
import 'package:aspirant/pages/register.dart';
import 'package:aspirant/pages/forgot.dart';
import 'package:aspirant/pages/verif.dart';
import 'package:aspirant/pages/change.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void requestNotificationPermission() async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await Firebase.initializeApp();

  requestNotificationPermission();

  AwesomeNotifications().initialize(
    'resource://drawable/notifaspirant', 
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Colors.teal,
        ledColor: Colors.white,
        channelShowBadge: true,
        importance: NotificationImportance.Low,
      )
    ],
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  int? roleId = prefs.getInt('roleId');
  String? savedLanguageCode = prefs.getString('languageCode');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (context) => LocaleProvider()
            ..setLocale(
              savedLanguageCode != null ? Locale(savedLanguageCode) : Locale('en'),
            ),
        ),
      ],
      child: MyApp(isLoggedIn: isLoggedIn, roleId: roleId),
    ),
  );
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final bool isLoggedIn;
  final int? roleId;

  MyApp({super.key, required this.isLoggedIn, this.roleId});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('id'),
        const Locale('zh'),
      ],
      locale: localeProvider.locale,
      title: 'My App',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        appBarTheme: AppBarTheme(
          color: Colors.green,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        appBarTheme: AppBarTheme(
          color: Colors.green[900],
        ),
      ),
      themeMode: themeProvider.themeMode,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      home: isLoggedIn ? (roleId == 1 ? HomeAdmin() : HomeUser()) : Login(),
      routes: {
        "/login": (context) => Login(),
        "/register": (context) => Register(),
        "/forgot": (context) => Forgot(),
        "/verif": (context) => Verif(),
        "/change": (context) => Change(),
        "/homeadmin": (context) => HomeAdmin(),
        "/homeuser": (context) => HomeUser(),
        "/profile": (context) => Profile(),
        "/changeusn": (context) => UpdateUsername(),
        "/sayur": (context) => Sayur(),
        "/buah": (context) => Buah(),
        "/rempah": (context) => Rempah(),
        "/other": (context) => Other(),
        "/stok": (context) => Stok(),
        "/addstok": (context) => AddStok(),
        "/setting": (context) => LanguageSettings(),
        "/cart": (context) => Cart(),
      },
    );
  }
}
