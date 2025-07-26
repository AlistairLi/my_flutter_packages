import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_adid/src/gid_result_model.dart';

import 'gid_platform_interface.dart';

/// An implementation of [GidPlatform] that uses method channels.
class MethodChannelGid extends GidPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('gid');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<GidResultModel> getGid() async {
    try {
      final jsonStr = await methodChannel.invokeMethod<String>('getGid');
      if (jsonStr == null) return GidResultModel("", -1, "jsonStr is null");
      return GidResultModel.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      print(e);
      return GidResultModel("", -1, "getGid(), error: ${e.toString()}");
    }
  }
}
