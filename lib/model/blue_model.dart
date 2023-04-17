// To parse this JSON data, do
//
//     final blueModel = blueModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

BlueModel blueModelFromJson(String str) => BlueModel.fromJson(json.decode(str));

String blueModelToJson(BlueModel data) => json.encode(data.toJson());

class BlueModel {
  BlueModel(
      {this.connectionState,
      this.mssage,
      required this.deviceId,
      required this.name,
      this.serverId,
      this.alias});

  DeviceConnectionState? connectionState;
  String? mssage;
  final String deviceId;
  final String name;
  String? serverId;
  String? alias;
  QualifiedCharacteristic? qualifiedCharacteristic;
  factory BlueModel.fromJson(Map<String, dynamic> json) => BlueModel(
        connectionState:
            json["connectionState"] ?? DeviceConnectionState.disconnected,
        deviceId: json["deviceId"],
        name: json["name"],
        serverId: json["serverId"],
        alias: json["alias"],
      );

  Map<String, dynamic> toJson() => {
        "deviceId": deviceId,
        "name": name,
        "serverId": serverId,
        "alias": alias,
      };
}
