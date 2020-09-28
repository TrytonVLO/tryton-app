import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:Tryton/widgets/sftp_explorer.dart';
import 'package:Tryton/apis/sftp_api.dart';

Future<SftpApi> getSftpApi(BuildContext context) async {
  print("started!");
  SftpApi client = await SftpApi.loadProfile();
  int result;
  if (client != null) result = await client.login();

  if(result == 2 || !await SftpApi.isConnected()){
    // show no internet error
    print("No internet!");
    Navigator.of(context).pushReplacementNamed("/noInternet");
    return null;
  }

  while (client == null || result == 1) {
    print("login");
    await Navigator.of(context).pushNamed("/login");
    client = await SftpApi.loadProfile();
    if (client != null) result = await client.login();
  }

  return client;
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SftpApi>(
        future: getSftpApi(context),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            // loading screen
            return Scaffold(
              body: Center(
                child: SpinKitCubeGrid(
                  color: Colors.blue,
                  size: 100.0,
                ),
              ),
            );

          return MainPageContent(client: snapshot.data);
        });
  }
}

class MainPageContent extends StatefulWidget {
  final SftpApi client;

  MainPageContent({@required this.client});

  @override
  _MainPageContentState createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text("Tryton"),
      ),
      drawer: Container(
          width: 180,
          child: Drawer(
            child: SafeArea(
                child: ListView(
              children: [
                // profile view
                Container(
                  height: 100,
                  color: Colors.grey[700],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        color: Color.fromRGBO(30, 21, 21, 100),
                        child: Center(
                          child: Text(
                            this.widget.client.username.toUpperCase(),
                            style: TextStyle(
                              color: Color.fromRGBO(139, 93, 93, 100),
                              fontSize: 40,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Text(
                            "Logged in as ${this.widget.client.username}",
                            style: TextStyle(color: Colors.grey[400]),
                          )),
                    ],
                  ),
                ),
                // QR code login - TODO
                ListTile(
                  leading: Icon(Icons.border_style),
                  title: Text("Login with QR"),
                  subtitle: Text("(WIP)"),
                  onTap: () {},
                ),
                // Logging out
                ListTile(
                  leading: Icon(
                    Icons.arrow_back,
                    color: Colors.red[400],
                  ),
                  title: Text(
                    "Log out",
                    style: TextStyle(color: Colors.red[400]),
                  ),
                  onTap: () async {

                    // confirm logout
                    bool confirmLogout = false;

                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Log out?"),
                        content: Text("Are you sure you want to log out?"),
                        actions: [
                          FlatButton(
                            child: Text(
                              "Yes",
                              style: TextStyle(color: Colors.red[400]),
                            ),
                            onPressed: () {
                              confirmLogout = true;
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              confirmLogout = false;
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );

                    if (!confirmLogout) return;

                    // log out
                    await SftpApi.resetProfile();
                    Navigator.of(context).pushReplacementNamed("/");
                  },
                ),
              ],
            )),
          )),
      body: WillPopScope(
          // close drawer via back button
          onWillPop: () async {
            if (_key.currentState.isDrawerOpen) {
              Navigator.of(context).pop();
              return false;
            }
            return true;
          },
          child: SftpExplorer(
            client: this.widget.client,
          )),
    );
  }
}
