import 'package:flutter/material.dart';
import 'package:Tryton/pages/mainPage.dart';
import 'package:Tryton/pages/loginPage.dart';

import 'package:Tryton/apis/sftpApi.dart';

void main() async {
  runApp(MyApp(initialRoute: await isLoggedIn() ? "/home" : "/login",));
}

Future<bool> isLoggedIn() async {
  SftpApi profile = null;//await SftpApi.loadProfile();

  if(profile == null)
    return false;
  else
    return true;
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({this.initialRoute="/login"});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tryton',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        accentColor: Colors.blueAccent,
        hintColor: Colors.grey[500],
        textSelectionHandleColor: Colors.blueAccent,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey[700],
          contentTextStyle: TextStyle(
            color: Colors.grey[300],
          ),
        ),
      ),
      initialRoute: this.initialRoute,
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => MainPage(),
      },
    );
  }
}