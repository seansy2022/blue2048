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

  final TimeQueue<DiscoveredDevice> _devices = TimeQueue(5000);
  Map<String, DiscoveredDevice> oldDevice = {}; //上一次设备

  @override
  Stream<BleScannerState> get state => _stateStreamController.stream;

  void startScan(List<Uuid> serviceIds) {
    _devices.clear();
    _subscription?.cancel();
    _subscription =
        _ble.scanForDevices(withServices: serviceIds).listen((device) {
      _devices.push(device, device.id);
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

  push(Object e, String id) {
    // final old = (list as List<TimeQueueModel?>)
    //     .firstWhere((element) => element!.id == id, orElse: () => null);
    // list.add(TimeQueueModel(e, id));
    TimeQueueModel? old = null;
    for (final e in list) {
      if (e.id == id) {
        old = e;
        break;
      }
    }
    if (old == null) {
      list.add(TimeQueueModel(e, id));
    }
    // list.remove(old);
    // list.add(TimeQueueModel(e, id));
    // tidy();
  }

  List<T> getList(double time) {
    // final timestamp = DateTime.now().millisecondsSinceEpoch - time;
    // final lists = list.where((element) => element.time >= timestamp);
    return list.map((e) {
      return e.elemet as T;
    }).toList();
    // return list;
  }

  tidy() {
    final time = DateTime.now().millisecondsSinceEpoch - availableTime;
    // list = list.where((element) {
    //   return element.time >= time;
    // }).toList();
    return list;
  }

  clear() {
    list = [];
  }
}

class TimeQueueModel {
  late int time; //ms
  final String id;
  final Object elemet;

  TimeQueueModel(this.elemet, this.id) {
    time = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  bool operator ==(other) {
    // 判断是否是非
    if (other is! TimeQueueModel) {
      return false;
    }
    return id == (other).time;
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
