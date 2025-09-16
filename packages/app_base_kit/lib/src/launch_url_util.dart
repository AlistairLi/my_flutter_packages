import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// 打开网页,应用商店
class LaunchUrlUtil {
  LaunchUrlUtil._();

  /// 加载http/https网页
  static Future<void> launchHttp(String? url,
      [LaunchMode mode = LaunchMode.inAppWebView]) async {
    if (url == null || url.isEmpty) return;

    var uri = Uri.parse(url);
    if (uri.scheme.isEmpty) {
      uri = Uri.https(url);
    }
    try {
      var result = await launchUrl(
        uri,
        mode: Platform.isAndroid ? mode : LaunchMode.platformDefault,
      );
      if (kDebugMode) {
        print("LaunchUrlUtil.launchHttp() result: $result");
      }
    } catch (e) {
      if (kDebugMode) {
        print("LaunchUrlUtil.launchHttp() error:\n$e");
      }
    }
  }

  /// 打开应用商店
  static Future<void> launchAppStore({
    String iosAppId = "",
    String androidPackageName = "",
    String? storeLink,
  }) async {
    if (Platform.isIOS) {
      String url = 'https://apps.apple.com/app/id$iosAppId';
      launchHttp(url);
    } else if (Platform.isAndroid) {
      var link = storeLink ?? "https://play.google.com/store/apps/details?id=";
      // String url = 'market://details?id=$androidPackageName';
      String url = '$link$androidPackageName';
      launchHttp(url, LaunchMode.externalApplication);
    }
  }
}
