import 'package:permission_handler/permission_handler.dart';

class CheckPermission {
  static Future<bool> check() async {
    // if (!_checkBlueOpen()) {
    //   return Future.value(false);
    // }
    final blueP = await _checkPermission();
    final locationL = await _checkLocationPermisson();

    // await Future.wait([, _checkLocationPermisson()]);
    return blueP && locationL;
  }

  static Future<bool> _checkPermission() async {
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();

    PermissionStatus status = await Permission.bluetoothConnect.status;
    if (status == PermissionStatus.granted) {
      //通过
      return true;
    } else if (status == PermissionStatus.restricted ||
        status == PermissionStatus.permanentlyDenied ||
        status == PermissionStatus.denied) {
      // EasyLoading.showToast("请打开蓝牙权限");
      return false;
    } else {
      await Permission.bluetooth.request();
      return _checkPermission();
    }
  }

  static Future<bool> _checkLocationPermisson() async {
    await Permission.location.request();
    PermissionStatus status = await Permission.location.status;
    if (status == PermissionStatus.granted) {
      //通过
      return true;
    } else if (status == PermissionStatus.restricted ||
        status == PermissionStatus.denied) {
      // EasyLoading.showToast("请打开定位权限");
      return false;
    } else {
      await Permission.locationWhenInUse.request();
      return _checkLocationPermisson();
    }
  }

  // bool _checkBlueOpen() {
  //   bool state = blueTool.isOpen;
  //   if (state == false) {
  //     EasyLoading.showToast("请打开蓝牙");
  //   }
  //   return state;
  // }
}
