// To parse this JSON data, do
//
//     final blueMessageModel = blueMessageModelFromJson(jsonString);

import 'dart:convert';

BlueMessageModel blueMessageModelFromJson(String str) =>
    BlueMessageModel.fromJson(json.decode(str));

String blueMessageModelToJson(BlueMessageModel data) =>
    json.encode(data.toJson());

class BlueMessageModel {
  BlueMessageModel({
    required this.date,
    required this.deviceId,
    required this.message,
    required this.messageType,
  });

  final String date;
  final String deviceId;
  final String message;
  final int messageType;

  BlueMessageModel copyWith({
    required String date,
    required String deviceId,
    required String message,
    required int messageType,
  }) =>
      BlueMessageModel(
        date: date ?? this.date,
        deviceId: deviceId ?? this.deviceId,
        message: message ?? this.message,
        messageType: messageType ?? this.messageType,
      );

  factory BlueMessageModel.fromJson(Map<String, dynamic> json) =>
      BlueMessageModel(
        date: json["date"],
        deviceId: json["deviceId"],
        message: json["message"],
        messageType: json["messageType"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "deviceId": deviceId,
        "message": message,
        "messageType": messageType,
      };
}
