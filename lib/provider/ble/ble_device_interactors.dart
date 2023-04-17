import 'dart:async';

import 'package:bluesun/provider/ble/reactive_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleDeviceInteractors extends ReactiveState<BlueMessageUpdate> {
  BleDeviceInteractors({
    required FlutterReactiveBle ble,
    required Function(String message) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage;

  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage;

  @override
  Stream<BlueMessageUpdate> get state => _subScribeController.stream;

  final StreamController<BlueMessageUpdate> _subScribeController =
      StreamController<BlueMessageUpdate>();

  subScribeToCharacteristic(
      QualifiedCharacteristic characteristic, String deviceId) {
    _logMessage('Subscribing to: ${characteristic.characteristicId} ');
    _ble.subscribeToCharacteristic(characteristic).listen((event) {
      _subScribeController
          .add(BlueMessageUpdate(deviceId: deviceId, mssage: event));
    });
  }
}

@immutable
class BlueMessageUpdate {
  final String deviceId;
  final List<int> mssage;

  /// Field `error` is null if there is no error reported.

  const BlueMessageUpdate({required this.deviceId, required this.mssage});
}
