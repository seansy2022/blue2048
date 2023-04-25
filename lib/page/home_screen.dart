import 'dart:math';

import 'package:bluesun/blue/check_premission.dart';
import 'package:bluesun/help_style.dart';
import 'package:bluesun/page/blue_scan_screen.dart';
import 'package:bluesun/provider/device_manger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String>? datas;
  @override
  void initState() {
    super.initState();
    CheckPermission.check();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "电阻测量仪",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const BlueScanScreen()),
              );
            },
            child: Text(
              "蓝牙设置",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        ],
      ),
      body: Consumer<DeviceManger>(builder: ((context, deviceManger, child) {
        final blueModel = deviceManger.blueModel;
        final message = deviceManger.messageModel.showData();
        final colors = deviceManger.messageModel.res;
        final resistances = deviceManger.messageModel.res;

        datas = message;
        if (blueModel == null) {
          return _nullBlue();
        } else if (blueModel.connectionState ==
            DeviceConnectionState.disconnected) {
          return _disconnect(blueModel.name);
        } else if (blueModel.connectionState ==
            DeviceConnectionState.connecting) {
          return _connecting();
        } else if (message?.isEmpty ?? true) {
          return _waitBlueData();
        } else {
          return _gridView(message!, colors, resistances);
        }
      })),
    );
  }

  Widget _gridView(List contents, List? colors, List? resistances) {
    return box(
      GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: contents.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              decoration: BoxDecoration(
                  color: colorFrom(colors![index]),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 1,
                      // blurRadius: 7,
                      offset: Offset(1, 1),
                    )
                  ]),
              child: Stack(
                children: [
                  Positioned(
                      top: 6,
                      right: 6,
                      child: Text(
                        index_map(index),
                        style: HelpStyle.contextStyle,
                      )),
                  Positioned(
                      top: 16,
                      left: 6,
                      bottom: 6,
                      right: 6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: SizedBox()),
                          Text(
                            resistances![index].toString() + 'Ω',
                            style: HelpStyle.contextStyle,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            contents[index],
                            maxLines: 2,
                            style: HelpStyle.contextStyle.copyWith(
                                color: Colors.black87,
                                fontSize: 18,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      )),
                ],
              ),
            );
          }),
    );
  }

  Widget _connecting() {
    return box(Column(
      children: [
        CupertinoActivityIndicator(),
        Text("蓝牙连接中"),
      ],
    ));
  }

  Widget _disconnect(String title) {
    return box(Text(
      "未发现$title蓝牙，请手动选择蓝牙",
      style: HelpStyle.titleStyle,
    ));
  }

//之前已连接过，现在未发现
  Widget _waitBlueData() {
    return box(Text(
      "已连接等待数据",
      style: HelpStyle.titleStyle,
    ));
  }

//从来没有连过蓝牙
  Widget _nullBlue() {
    return box(
      Text(
        "蓝牙未连接，请连接",
        style: HelpStyle.titleStyle,
      ),
    );
  }

  Widget box(Widget child) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints.tight(Size(
            MediaQuery.of(context).size.width - 10,
            MediaQuery.of(context).size.width - 10)),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: child,
      ),
    );
  }

  Color colorFrom(int data) {
    final value = max(min((data - 1800) / (3700 - 1800), 1.0), 0);

    return HSVColor.fromAHSV(1.0, 210.0, 0.1 + value * 0.9, 1.0).toColor();
  }

  String index_map(int index) {
    final pai = (index) ~/ 4;
    final ge = index % 4;

    final newIndex = ge * 4 + (pai);
    return newIndex.toString();
  }
}
