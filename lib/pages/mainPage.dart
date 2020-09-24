import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tryton"),
      ),
      body: MainPageContent(),
    );
  }
}

class MainPageContent extends StatefulWidget {
  @override
  _MainPageContentState createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        onPressed: () async {},
        child: Text("Scan QR to login"),
      ),
    );
  }
}
