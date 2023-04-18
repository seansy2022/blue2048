import 'dart:async';
import 'dart:convert';
import 'package:bluesun/db/blue_message_db.dart';
import 'package:bluesun/model/blue_model.dart';

import 'package:bluesun/provider/ble/ble_device_connectors.dart';
import 'package:bluesun/provider/ble/ble_device_interactor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

const KServer = "ffe0";
const KCharacteristic = "ffe1";

class DeviceManger extends ChangeNotifier {
  final BleDeviceConnectors connectors;
  final BleDeviceInteractor bleinteracor;
  QualifiedCharacteristic? sendBlue;
  BlueModel? blueModel;
  final blueDb = BlueMessageDB();
  Timer? _timer;
  List<int>? _receivedMessage;
  StreamSubscription? _stream;
  DeviceManger({
    required this.connectors,
    required this.bleinteracor,
  }) {
    initConfig();
  }
  initConfig() async {
    await _loadData();
    listenConnectState();
    _blueState();
  }

  _blueState() {
    FlutterReactiveBle().connectedDeviceStream.listen((state) {
      connectionStateMseeage(state);
    });
  }

  _loadData() async {
    await blueDb.config();
    blueModel = await blueDb.getDevice();
    if (blueModel != null) _connectSaveBlue(blueModel!);
    notifyListeners();
  }

  _connectSaveBlue(BlueModel blueModel) {
    if (blueModel.connectionState == DeviceConnectionState.connected) return;
    if (blueModel.serverId != null)
      // ignore: curly_braces_in_flow_control_structures
      connectors.findandConectBlue(
          id: blueModel.deviceId,
          withServices: [Uuid.parse(blueModel.serverId!)],
          prescanDuration: const Duration(seconds: 3));
  }

  add({required String name, required String deviceId}) {
    if (blueModel != null) removeDevice();
    final blue = BlueModel(
      name: name,
      deviceId: deviceId,
    );
    blueModel = blue;
    blueDb.addDevice(blue);
    notifyListeners();
  }

  removeDevice() {
    if (blueModel != null) {
      if (blueModel!.connectionState == DeviceConnectionState.connected) {
        disconnect(blueModel!.deviceId);
      }
      blueDb.removeDevice(blueModel!.deviceId);
      blueModel = null;
    }
    notifyListeners();
  }

  receivedMessageBuf(String deviceId, List<int> datas) {
    final timer = _timer;
    var message = _receivedMessage;
    if (timer != null) {
      timer.cancel();
    }
    message ??= [];
    message.addAll(datas);

    _timer = Timer(const Duration(milliseconds: 100), () {
      updateModel(mssage: json.decode(utf8.decode(_receivedMessage!)));
      _timer?.cancel();
      _receivedMessage?.clear();
    });
  }

  updateModel({
    DeviceConnectionState? state,
    List<int>? mssage,
    String? alias,
    String? serverId,
  }) {
    if (state != null) {
      blueModel?.connectionState = state;
    }
    if (mssage != null) {
      blueModel?.mssage = mssage;
    }

    if (serverId != null) {
      blueModel?.serverId = serverId;
      updateBlue();
    }
    notifyListeners();
  }

  updateBlue() {
    if (blueModel != null) {
      blueDb.addDevice(blueModel!);
    }
  }

  connect(List<String> devices) {
    for (final device in devices) {
      connectors.connect(device);
    }
  }

  disconnect(String deviceID) {
    connectors.disconnect(deviceID);
  }

//connected message
  subScribe(String device) async {
    List<DiscoveredService> serviceIds =
        await bleinteracor.discoverServices(device);

    DiscoveredService? server =
        serviceIds.where((s) => s.serviceId.toString().contains(KServer)).first;
    final characteristic = server.characteristics
        .where(
          (c) => c.characteristicId.toString().contains(KCharacteristic),
        )
        .first;

    final qcharacteristic = QualifiedCharacteristic(
        serviceId: characteristic.serviceId,
        characteristicId: characteristic.characteristicId,
        deviceId: device);
    blueModel?.qualifiedCharacteristic = qcharacteristic;
    updateModel(serverId: characteristic.serviceId.toString());
    listenCharacteristic(qcharacteristic);
  }

  listenConnectState() {
    connectors.state.listen((ConnectionStateUpdate state) {
      connectionStateMseeage(state);
    });
  }

  connectionStateMseeage(ConnectionStateUpdate state) {
    updateModel(state: state.connectionState);
    if (state.connectionState == DeviceConnectionState.connected) {
      FlutterReactiveBle().requestMtu(deviceId: state.deviceId, mtu: 128);
      subScribe(state.deviceId);
    }
  }

  listenCharacteristic(QualifiedCharacteristic characteristic) {
    _stream?.cancel();

    final scribe = bleinteracor
        .subScribeToCharacteristic(characteristic)
        .listen((message) {
      debugPrint(message.toString());
      receivedMessageBuf(characteristic.deviceId, message);
    });
    _stream = scribe;
  }

  sendMessage(final deviceId, List<int> message) {
    if (blueModel?.qualifiedCharacteristic != null) {
      bleinteracor.writeCharacterisiticWithoutResponse(
          blueModel!.qualifiedCharacteristic!, message);
    }
  }
}
