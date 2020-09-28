import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:Tryton/apis/sftp_api.dart';
import 'package:Tryton/widgets/no_internet_page.dart';

class SftpExplorer extends StatefulWidget {
  final SftpApi client;

  SftpExplorer({@required this.client});

  @override
  _SftpExplorerState createState() => _SftpExplorerState();
}

class _SftpExplorerState extends State<SftpExplorer> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        // go back in file structure via back button
        onWillPop: () async {
          if (this.widget.client.currentPath != ".") {
            this.widget.client.cd("..");
            refresh();
            return false;
          }

          return true;
        },
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Text(this.widget.client.currentPath),
              color: Colors.grey[800],
            ),
            Expanded(
                child: FutureBuilder<List>(
              future: this.widget.client.ls(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done)
                  // loading screen
                  return Center(
                    child: SpinKitCubeGrid(
                      color: Colors.blue,
                      size: 50.0,
                    ),
                  );
                if (snapshot.data.length == 1 && snapshot.data[0] == "error")
                  // no internet
                  return NoInternetMessage(
                    tryAgain: () => this.setState(() {}),
                  );
                return ListView(
                  children: snapshot.data
                      .map<Widget>((e) => FileTile(
                            filedata: e,
                            client: this.widget.client,
                            refresh: refresh,
                          ))
                      .toList(),
                );
              },
            )),
          ],
        ));
  }
}

class FileTile extends StatelessWidget {
  final dynamic filedata;
  final SftpApi client;
  final Function refresh;

  FileTile(
      {@required this.filedata, @required this.client, @required this.refresh});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: (filedata['isDirectory']
          ? Icon(Icons.folder, color: Colors.yellowAccent[100])
          : Icon(Icons.insert_drive_file)),
      title: Text(filedata['filename']),
      trailing: Text(filedata['permissions']),
      onTap: () {
        if (filedata['isDirectory']) {
          client.cd(filedata['filename']);
          refresh();
        }
      },
    );
  }
}
