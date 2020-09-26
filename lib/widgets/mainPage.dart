import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:Tryton/widgets/sftpExplorer.dart';
import 'package:Tryton/apis/sftpApi.dart';

Future<SftpApi> getSftpApi(BuildContext context) async {
  SftpApi client = await SftpApi.loadProfile();
  int result;
  if (client != null) result = await client.login();

  while (client == null || result > 0) {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    await SftpApi.resetProfile();
                    Navigator.of(context).pushReplacementNamed("/");
                  },
                ),
              ],
            )),
          )),
      body: SftpExplorer(client: this.widget.client,),
    );
  }
}
