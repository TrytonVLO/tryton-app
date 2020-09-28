import 'package:flutter/cupertino.dart';
import 'package:ssh/ssh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_widget/connectivity_widget.dart';

class SftpApi {
  static String hostname = "tryton.vlo.gda.pl";

  String username;
  String password;
  SSHClient ftpConnect;

  SftpApi({@required this.username, @required this.password}) {
    this.ftpConnect = SSHClient(
      host: hostname,
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
      if (username.isEmpty || password.isEmpty) return null;
    } catch (e) {
      print("Loading error: $e"); // debug
      return null;
    }

    //print("Loaded: $username : $password");  // debug
    return SftpApi(username: username, password: password);
  }

  static Future<void> resetProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', "");
    await prefs.setString('password', "");
  }

  // --------------- Operations on server ---------------

  static Future<bool> isConnected() async {
    ConnectivityUtils.instance
        .setCallback((response) => response.contains("<!DOCTYPE html>"));
    ConnectivityUtils.instance.setServerToPing("https://$hostname");

    try {
      return ConnectivityUtils.instance.isPhoneConnected();
    } catch (e) {
      return false;
    }
  }

  // --------------- Operations on sftp ---------------

  Future<int> login() async {
    // returns 0 when login succeded
    // 1 when login or password are wrong
    // 2 when something else went wrong
    try {
      //print("connecting...");
      String result = await this.ftpConnect.connect();
      if (result != "session_connected") return 2;
      result = await this.ftpConnect.connectSFTP();
      if (result != "sftp_connected") return 2;
      //print("done");
      return 0;
    } catch (e) {
      print("sftp login: ${e.message}; ${e.code}");
      if (e.message == "Auth fail") return 1;
      return 2;
    }
  }

  // ----- navigation -----
  String currentPath = ".";
  dynamic parentDir = {
    "filename": "..",
    "isDirectory": true,
    "permissions": "",
  };

  Future<List> ls({String path = ""}) async {
    List res = await this._ls(path: path);
    if (res.length == 1 && res[0] == "error") {
      int r = await this.login();
      if (r == 2) {
        return [
          "error",
        ];
      }
      res = await this._ls(path: path);
    }
    return res;
  }

  Future<List> _ls({String path = ""}) async {
    if (path.isEmpty) path = this.currentPath;
    List<dynamic> files;

    try {
      files = await this.ftpConnect.sftpLs(path);
    } catch (e) {
      print("sftp ls: $e");
      return [
        "error",
      ];
    }

    // add parent directory
    if (currentPath != ".") files = [parentDir] + files;

    return files;
  }

  void cd(String dir) {
    if (dir == "..") {
      this.currentPath =
          this.currentPath.substring(0, this.currentPath.lastIndexOf("/"));
      return;
    }
    this.currentPath += "/" + dir;
  }

  // ----- updates to file structure -----
  // TODO
}
