import 'dart:io';

import 'package:google_adid/src/gid.dart';

class GoogleAdIdUtil {
  GoogleAdIdUtil._();

  static const String _defaultGoogleId = "00000000-0000-0000-0000-00000000000";

  /// google 设备广告id
  static String? _googleId;

  static String get googleId {
    return _googleId ?? _defaultGoogleId;
  }

  /// 初始化
  static Future<void> initData() async {
    if (Platform.isAndroid) {
      try {
        Gid gid = Gid();
        var result = await gid.getGid();
        if (result.gid != null && result.gid!.isNotEmpty) {
          _googleId = result.gid!;
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
