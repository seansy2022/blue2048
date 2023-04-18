import 'package:bluesun/comp/scan_item.dart';
import 'package:bluesun/help_style.dart';
import 'package:bluesun/model/blue_model.dart';
import 'package:bluesun/model/blue_state.dart';
import 'package:bluesun/provider/ble/ble_scanner.dart';

import 'package:bluesun/provider/device_manger.dart';
import 'package:bluesun/provider/scan_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class BlueScanScreen extends StatefulWidget {
  const BlueScanScreen({Key? key}) : super(key: key);

  @override
  State<BlueScanScreen> createState() => _BlueScanScreenState();
}

class _BlueScanScreenState extends State<BlueScanScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScanProvider>(
      create: (ctx) => ScanProvider(),
      builder: (ctx, child) => Scaffold(
        appBar: AppBar(
          title: Text("扫描蓝牙"),
        ),
        body: blues,
      ),
    );
  }

  mineWidget() {
    return Text(
      "我的设备",
      style: HelpStyle.contextStyle,
    );
  }

  get connetedBlue {
    return Consumer2<DeviceManger, BleScannerState?>(
        builder: (_, deviceManger, bleScannerState, __) {
      final device = deviceManger.blueModel;

      DiscoveredDevice? discoveredDevice = null;
      if (bleScannerState != null) {
        for (final element in bleScannerState.discoveredDevices) {
          if (element.id == device?.deviceId) {
            discoveredDevice = element;
            break;
          }
        }
      }
      return device == null
          ? Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Text(
                "暂无设备",
                style: HelpStyle.contextStyle,
              ),
            )
          : ScanItem(
              blueId: device.deviceId,
              disable: discoveredDevice == null,
              ontap: () {
                if (device.connectionState ==
                        DeviceConnectionState.disconnected &&
                    discoveredDevice != null) {
                  connect(context, discoveredDevice);
                }
              },
              name: device.name,
              state: BlueConnectState.disconnect,
              subChild: Row(
                children: [
                  if (discoveredDevice == null) Text("蓝牙扫描中..."),
                  if (device.connectionState ==
                          DeviceConnectionState.disconnected &&
                      discoveredDevice != null)
                    Text("未连接"),
                  if (device.connectionState ==
                          DeviceConnectionState.connected &&
                      discoveredDevice != null)
                    Text("已连接"),
                  if (device.connectionState ==
                      DeviceConnectionState.connecting)
                    CupertinoActivityIndicator(),
                  IconButton(
                      onPressed: () {
                        deviceManger.removeDevice();
                      },
                      icon: Icon(Icons.delete_outline_rounded))
                ],
              ),
            );
    });
  }

  loading() {
    return Row(
      children: [
        Text(
          "其他设备",
          style: HelpStyle.contextStyle,
        ),
        SizedBox(width: 12),
        CupertinoActivityIndicator(),
      ],
    );
  }

  get blues {
    return Consumer4<BleScanner, BleScannerState?, ScanProvider, DeviceManger>(
      builder:
          (_, bleScanner, bleScannerState, scanProvider, deviceManger, __) {
        if (!scanProvider.isScan) {
          bleScanner.startScan([]);
          scanProvider.isScan = true;
        }
        final devices = _filterBlue(
            bleScannerState?.discoveredDevices, deviceManger.blueModel);
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: mineWidget(),
              ),
              SliverToBoxAdapter(
                child: connetedBlue,
              ),
              SliverToBoxAdapter(
                child: loading(),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  final device = devices![index];
                  return ScanItem(
                    blueId: device.id,
                    ontap: () => connect(context, device),
                    name: device.name,
                    state: BlueConnectState.disconnect,
                  );
                }, childCount: devices?.length),
              ),
            ],
          ),
        );
      },
    );
  }

  List<DiscoveredDevice>? _filterBlue(
      List<DiscoveredDevice>? blue, BlueModel? filterBlue) {
    return blue?.where((element) {
      return element.name.isNotEmpty && element.id != filterBlue?.deviceId;
    }).toList();
  }

//event
  void connect(BuildContext context, DiscoveredDevice device) {
    final deviceManger = Provider.of<DeviceManger>(context, listen: false);
    deviceManger.add(name: device.name, deviceId: device.id);
    deviceManger.connect([device.id]);
  }
}
