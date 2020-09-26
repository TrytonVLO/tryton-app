import 'package:flutter/material.dart';
import 'package:Tryton/widgets/mainPage.dart';
import 'package:Tryton/widgets/loginPage.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}