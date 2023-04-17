import 'dart:async';
import 'dart:math';
import 'package:bluesun/provider/ble/reactive_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleScanner implements ReactiveState<BleScannerState> {
  BleScanner({
    required FlutterReactiveBle ble,
    required Function(String message) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage;

  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage;
  final StreamController<BleScannerState> _stateStreamController =
      StreamController();

  final TimeQueue<DiscoveredDevice> _devices = TimeQueue(2000);
  Map<String, DiscoveredDevice> oldDevice = {}; //上一次设备

  @override
  Stream<BleScannerState> get state => _stateStreamController.stream;

  void startScan(List<Uuid> serviceIds) {
    _devices.clear();
    _subscription?.cancel();
    _subscription =
        _ble.scanForDevices(withServices: serviceIds).listen((device) {
      _devices.push(device);
      _pushState();
    }, onError: (Object e) => _logMessage('Device scan fails with error: $e'));
    _pushState();
  }

  void _pushState() {
    final currentDevices = _devices.getList(1000);
    final Map<String, DiscoveredDevice> currentDeviceMap = {};
    for (final currentDevice in currentDevices) {
      currentDeviceMap[currentDevice.id] = currentDevice;
    }

    final isNotEq = currentDeviceMap.keys
        .toList()
        .where((e) => !oldDevice.keys.contains(e))
        .isNotEmpty;

    if (isNotEq) {
      oldDevice = currentDeviceMap;
    }
    _stateStreamController.add(
      BleScannerState(
        discoveredDevices: oldDevice.values.toList(),
        scanIsInProgress: _subscription != null,
      ),
    );
  }

  Future<void> stopScan() async {
    _logMessage('Stop ble discovery');

    await _subscription?.cancel();
    _subscription = null;
    _pushState();
  }

  Future<void> dispose() async {
    await _stateStreamController.close();
  }

  StreamSubscription? _subscription;
}

class TimeQueue<T> {
  List<TimeQueueModel> list = [];
  final int availableTime; //列表保存的时间长度 ms

  TimeQueue(this.availableTime);

  push(Object e) {
    list.add(TimeQueueModel(e));
    tidy();
  }

  List<T> getList(double time) {
    final timestamp = DateTime.now()
        .subtract(Duration(milliseconds: availableTime))
        .millisecondsSinceEpoch;

    final lists = list.where((element) => element.time >= timestamp);
    return lists.map((e) {
      return e.elemet as T;
    }).toList();
  }

  tidy() {
    final time = DateTime.now()
        .subtract(Duration(milliseconds: availableTime))
        .millisecondsSinceEpoch;
    list = list.where((element) => element.time >= time).toList();
  }

  clear() {
    list = [];
  }
}

class TimeQueueModel {
  late final int time; //ms
  final Object elemet;

  TimeQueueModel(this.elemet) {
    time = DateTime.now().millisecondsSinceEpoch;
  }
}

@immutable
class BleScannerState {
  const BleScannerState({
    required this.discoveredDevices,
    required this.scanIsInProgress,
  });

  final List<DiscoveredDevice> discoveredDevices;
  final bool scanIsInProgress;
}
