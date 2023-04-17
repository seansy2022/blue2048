import 'dart:async';

import 'package:bluesun/provider/ble/ble_device_connector.dart';
import 'package:bluesun/provider/ble/reactive_state.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleDeviceConnectors extends ReactiveState<ConnectionStateUpdate> {
  BleDeviceConnectors({
    required FlutterReactiveBle ble,
    required Function(String message) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage;

  final FlutterReactiveBle _ble;

  final void Function(String message) _logMessage;

  @override
  Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;
  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();
  final Map<String, BleDeviceConnector> connectorMap = {};

  Future<void> findandConectBlue({
    required String id,
    required List<Uuid> withServices,
    required Duration prescanDuration,
    Map<Uuid, List<Uuid>>? servicesWithCharacteristicsToDiscover,
    Duration? connectionTimeout,
  }) async {
    _ble
        .connectToAdvertisingDevice(
            id: id,
            withServices: withServices,
            prescanDuration: prescanDuration)
        .listen((event) {
      _deviceConnectionController.add(event);
    });
  }

  Future<void> connect(String deviceId) async {
    if (deviceId.isEmpty) return;
    if (connectorMap.containsKey(deviceId)) {
      connectorMap.remove(deviceId);
    }

    final connnector = BleDeviceConnector(
      ble: _ble,
      logMessage: _logMessage,
    );
    connectorMap[deviceId] = connnector;
    addlisten(connnector);
    await connnector.connect(deviceId);
  }

  Future<void> disconnect(String deviceId) async {
    if (deviceId.isEmpty) return;
    final connnector = connectorMap[deviceId];
    connnector?.disconnect(deviceId);
  }

  addlisten(BleDeviceConnector connnector) {
    connnector.state.listen((event) {
      _deviceConnectionController.add(event);
    });
  }

  listenBlue() {
    _ble.statusStream.listen((status) {
      //code for handling status update
    });
  }
}
