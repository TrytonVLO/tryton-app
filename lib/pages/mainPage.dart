import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:Tryton/apis/sftpApi.dart';

Future<SftpApi> getSftpApi(BuildContext context) async {
  SftpApi client = await SftpApi.loadProfile();
  int result = await client.login();

  while (client == null || result > 0) {
    await Navigator.of(context).pushNamed("/login");
    client = await SftpApi.loadProfile();
    result = await client.login();
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
      body: FutureBuilder<List>(
        future: this.widget.client.ls(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            // loading screen
            return Center(
                child: SpinKitCubeGrid(
                  color: Colors.blue,
                  size: 50.0,
                ),
            );
          
          return Text(snapshot.data.map((e) => e['filename']).join('\n'));
        },
      ),
    );
  }
}
