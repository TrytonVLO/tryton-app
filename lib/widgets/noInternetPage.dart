import 'package:flutter/material.dart';

class NoInternetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: NoInternetMessage(
        tryAgain: () => Navigator.of(context).pushReplacementNamed("/"),
      )),
    );
  }
}

class NoInternetMessage extends StatelessWidget {
  final Function tryAgain;

  NoInternetMessage({@required this.tryAgain});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.signal_cellular_connected_no_internet_4_bar,
            color: Colors.red[400],
            size: 50,
          ),
          Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                "Check your internet connection!",
                style: TextStyle(color: Colors.red[400]),
              )),
          FlatButton(
            onPressed: this.tryAgain,
            child: Text("Try again"),
          ),
        ],
      ),
    );
  }
}
