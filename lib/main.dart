import 'package:bluesun/page/home_screen.dart';
import 'package:bluesun/provider/ble/ble_device_connectors.dart';
import 'package:bluesun/provider/ble/ble_device_interactor.dart';
import 'package:bluesun/provider/ble/ble_device_interactors.dart';
import 'package:bluesun/provider/ble/ble_logger.dart';
import 'package:bluesun/provider/ble/ble_status_monitor.dart';
import 'package:bluesun/provider/device_manger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import 'provider/ble/ble_scanner.dart';

const _themeColor = Colors.blue;
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final _bleLogger = BleLogger();
  final _ble = FlutterReactiveBle();
  final _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
  final _monitor = BleStatusMonitor(_ble);
  final _connectors = BleDeviceConnectors(
    ble: _ble,
    logMessage: _bleLogger.addToLog,
  );
  final _serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: _ble.discoverServices,
    readCharacteristic: _ble.readCharacteristic,
    writeWithResponse: _ble.writeCharacteristicWithResponse,
    writeWithOutResponse: _ble.writeCharacteristicWithoutResponse,
    subscribeToCharacteristic: _ble.subscribeToCharacteristic,
    logMessage: _bleLogger.addToLog,
  );
  final _serviceDiscoverers =
      BleDeviceInteractors(ble: _ble, logMessage: _bleLogger.addToLog);
  runApp(MultiProvider(
    providers: [
      Provider.value(value: _scanner),
      ChangeNotifierProvider<DeviceManger>(
        create: (ctx) => DeviceManger(
            connectors: _connectors, bleinteracor: _serviceDiscoverer),
      ),
      StreamProvider<BleScannerState?>(
        create: (_) => _scanner.state,
        initialData: const BleScannerState(
          discoveredDevices: [],
          scanIsInProgress: false,
        ),
      ),
      StreamProvider<ConnectionStateUpdate?>(
          create: (_) => _connectors.state,
          initialData: const ConnectionStateUpdate(
            deviceId: "",
            connectionState: DeviceConnectionState.disconnecting,
            failure: null,
          )),
      Provider.value(value: _serviceDiscoverer),
      Provider.value(value: _serviceDiscoverers),
    ],
    child: MaterialApp(
      title: 'Flutter Reactive BLE example',
      color: _themeColor,
      theme: ThemeData(
        primarySwatch: _themeColor,
      ),
      home: const HomeScreen(),
      builder: EasyLoading.init(),
    ),
  ));
}
// }
