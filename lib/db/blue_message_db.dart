import 'dart:convert';
import 'dart:io';

import 'package:bluesun/model/blue_message_model.dart';
import 'package:bluesun/model/blue_model.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class BlueMessageDB {
  late CollectionBox collection;
  late CollectionBox deviceCollection;
  config() async {
    Directory appDocDir = await getTemporaryDirectory();
    String appDocPath = appDocDir.path;
    final boxCollection = await BoxCollection.open(
      'BlueMessageModel', // Name of your database
      {'blueMessage', 'blueDevice'}, // Names of your boxes
      path: appDocDir
          .path, // Path where to store your boxes (Only used in Flutter / Dart IO)
      // Key to encrypt your boxes (Only used in Flutter / Dart IO)
    );

    collection = await boxCollection.openBox<String>('blueMessage');
    deviceCollection = await boxCollection.openBox<String>('blueDevice');
  }

  save(BlueMessageModel model) async {
    // collection.save(model);
    // final catsBox = await collection.openBox('blueMessage');
    final dateString = DateTime.now().millisecondsSinceEpoch.toString();
    collection.put("${model.deviceId}|$dateString", json.encode(model.toJson));
  }

  get(String deviceId) async {
    final allKeys = await collection.getAllKeys();
    final List<String> devicekeys = allKeys
        .where((element) => deviceId == element.split("|").first)
        .toList();
    final modelStrings = await collection.getAll(devicekeys);
    return modelStrings
        .map((e) => BlueMessageModel.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<BlueModel?> getDevice() async {
    final blues = await deviceCollection.getAllValues();

    if (blues.isNotEmpty) {
      return BlueModel.fromJson(jsonDecode(blues.values.first));
    }
    return null;
  }

  addDevice(BlueModel model) async {
    deviceCollection.put(model.deviceId, json.encode(model.toJson()));
  }

  removeDevice(String deviceId) {
    deviceCollection.delete(deviceId);
  }
}
