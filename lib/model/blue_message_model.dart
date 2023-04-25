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
    required this.res,
    required this.initRes,
  });

  final List? res;
  final List? initRes;

  BlueMessageModel copyWith({
    List? res,
    List? initRes,
  }) =>
      BlueMessageModel(
        res: res ?? this.res,
        initRes: initRes ?? this.initRes,
      );

  factory BlueMessageModel.fromJson(Map json) => BlueMessageModel(
        res: json["RES"],
        initRes: json["INIT_RES"],
      );

  Map<String, dynamic> toJson() => {
        "date": res,
        "deviceId": initRes,
      };

  List<String>? showData() {
    if (res != null && res?.length == initRes?.length) {
      final List<String> result = [];
      initRes!.asMap().forEach((k, v) {
        final basevalue = res![k] ?? 10000;
        result.add(
            ((v / (basevalue as int) - 1) * 100).toStringAsFixed(4) + '% ');
      });
      return result;
    }

    return null;
  }
}
