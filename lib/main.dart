import 'package:aspirant/pages/changeusn.dart';
import 'package:aspirant/pages/homeadmin.dart';
import 'package:aspirant/pages/profile.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  final bool isLoggedIn;
  final int? roleId;

  const MyApp({super.key, required this.isLoggedIn, this.roleId});

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
      },
    );
  }
}
