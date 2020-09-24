import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';

// TODO: add requesting permission

class QrLoginApi{
  static Future<String> scanQr() async {
    return await scanner.scan();
  }
}