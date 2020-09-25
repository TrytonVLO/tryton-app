import 'package:flutter/material.dart';
import 'package:Tryton/apis/sftpApi.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: LoginForm(),
        ));
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  String errorMessage = "";
  bool loggingIn = false;

  String username;
  String password;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: Center(
                  child: Text(
                    "Login to Tryton",
                  ),
                )),
            Center(
              child: Text(
                this.errorMessage,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Username",
              ),
              validator: (value) {
                if (value.isEmpty) return "Enter username";
                if (!value.startsWith("s"))
                  return "Valid usernames have format: s<number>";
                return null;
              },
              onSaved: (newValue) {
                this.username = newValue;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Password",
              ),
              obscureText: true,
              validator: (value) {
                if (value.isEmpty) return "Enter password";
                return null;
              },
              onSaved: (newValue) {
                this.password = newValue;
              },
            ),
            Padding(
              padding: EdgeInsets.only(
                right: 15,
                top: 7,
              ),
              child: (loggingIn
                  ? SpinKitRing(
                      color: Colors.blue,
                      size: 50.0,
                    )
                  : RaisedButton(
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            this.loggingIn = true;
                          });

                          // verify data with server
                          _formKey.currentState.save();

                          SftpApi sftpApi = SftpApi(
                              username: this.username, password: this.password);

                          int loginResult = await sftpApi.login();
                          if (loginResult == 1) {
                            // wrong password
                            setState(() {
                              this.errorMessage = "Wrong login or password";
                              this.loggingIn = false;
                            });
                            return;
                          }
                          if (loginResult > 1) {
                            // some unknown error
                            setState(() {
                              this.errorMessage = "Something went wrong :/";
                              this.loggingIn = false;
                            });
                            return;
                          }

                          await sftpApi.saveProfile();  // save good credentials
                          Navigator.of(context).popAndPushNamed("/home"); // go back home
                        }
                      },
                      child: Text("Login"),
                    )),
            ),
          ],
        ),
      ),
    );
  }
}
