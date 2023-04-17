import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ScanProvider extends ChangeNotifier {
  bool isScan = false;
  final _deviceMap = {};

  addDevice(DiscoveredDevice device) {
    _deviceMap[device.id] = device;
    notifyListeners();
  }

  allDevice() {
    return _deviceMap.values;
  }

  removeDevice(String deviceID) {
    if (_deviceMap.keys.contains(deviceID)) {
      _deviceMap.remove(deviceID);
    }
    notifyListeners();
  }

  hasDevice(String deviceID) {
    return _deviceMap.keys.contains(deviceID);
  }
}
