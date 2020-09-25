import 'package:flutter/cupertino.dart';
import 'package:ssh/ssh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SftpApi {
  final String hostname = "tryton.vlo.gda.pl";

  String username;
  String password;
  SSHClient ftpConnect;

  SftpApi({@required this.username, @required this.password}) {
    this.ftpConnect = SSHClient(
      host: this.hostname,
      port: 22,
      username: this.username,
      passwordOrKey: this.password,
    );

    //print("New instance: ${this.username} : ${this.password}");  // debug
  }

  // --------------- Operations on saved profile ---------------

  Future<void> saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', this.username);
    await prefs.setString('password', this.password);
    //print("Saved: ${this.username} : ${this.password}");  // debug
  }

  static Future<SftpApi> loadProfile() async {
    // returns SftApi object if login data is in memory
    // else returns null
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String username, password;
    try {
      username = prefs.getString('username');
      password = prefs.getString('password');
      //print("Loading data: $username : $password"); // debug
    } catch (e) {
      print("Loading error: $e"); // debug
      return null;
    }
    if (username.isEmpty || password.isEmpty) return null;

    //print("Loaded: $username : $password");  // debug
    return SftpApi(username: username, password: password);
  }

  static Future<void> resetProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', "");
    await prefs.setString('password', "");
  }

  // --------------- Operations on sftp ---------------
  String currentPath = ".";

  Future<int> login() async {
    // returns 0 when login succeded
    // 1 when login or password are wrong
    // 2 when something else went wrong
    try {
      print("connecting...");
      String result = await this.ftpConnect.connect();
      if (result != "session_connected") return 2;
      result = await this.ftpConnect.connectSFTP();
      if (result != "sftp_connected") return 2;
      print("done");
      return 0;
    } catch (e) {
      print(e.message);
      if (e.message == "Auth fail") return 1;
      return 2;
    }
  }

  Future<List> ls({String path = ""}) async {
    if (path.isEmpty) path = this.currentPath;
    return this.ftpConnect.sftpLs(path);
  }

  void cd(String dir) {
    this.currentPath += "/" + dir;
  }
}
