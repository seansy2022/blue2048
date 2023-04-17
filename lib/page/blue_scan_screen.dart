import 'package:bluesun/comp/scan_item.dart';
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
    return Text("我的设备");
  }

  get connetedBlue {
    return Consumer<DeviceManger>(builder: (_, deviceManger, __) {
      final device = deviceManger.blueModel;
      return device == null
          ? Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text("暂无设备"),
            )
          : ScanItem(
              blueId: device.deviceId,
              ontap: () {
                // connect(context, device);
              },
              name: device.name,
              state: BlueConnectState.disconnect,
              subChild: Row(
                children: [
                  if (device.connectionState ==
                      DeviceConnectionState.disconnected)
                    Text("未连接"),
                  if (device.connectionState == DeviceConnectionState.connected)
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
        Text("其他设备"),
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
        return CustomScrollView(
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
            SliverList(
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
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
