import 'package:aspirant/pages/buah.dart';
import 'package:aspirant/pages/changeusn.dart';
import 'package:aspirant/pages/homeadmin.dart';
import 'package:aspirant/pages/lainnya.dart';
import 'package:aspirant/pages/profile.dart';
import 'package:aspirant/pages/rempah.dart';
import 'package:aspirant/pages/sayur.dart';
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
// import 'package:firebase_analytics/observer.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  int? roleId = prefs.getInt('roleId');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
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
    return MaterialApp(
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
      },
      
    );
  }
}
