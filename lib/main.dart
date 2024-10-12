import 'package:aspirant/pages/homeadmin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aspirant/provider/theme.dart';
import 'package:aspirant/pages/login.dart';
import 'package:aspirant/pages/homeuser.dart';
import 'package:aspirant/pages/register.dart';
import 'package:aspirant/pages/forgot.dart';
import 'package:aspirant/pages/verif.dart';
import 'package:aspirant/pages/change.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        appBarTheme: AppBarTheme(
          // color: Colors.lightGreenAccent[400], 
          color: Colors.lightGreenAccent[400], 
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
      initialRoute: "/",
      routes: {
        "/": (context) => Login(),
        "/register": (context) => Register(),
        "/forgot": (context) => Forgot(),
        "/verif": (context) => Verif(),
        "/change": (context) => Change(),
        "/homeuser": (context) => HomeUser(),
        "/homeadmin": (context) => HomeAdmin(),
      },
    );
  }
}
