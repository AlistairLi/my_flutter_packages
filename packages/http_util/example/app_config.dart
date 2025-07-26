class AppConfig {
  AppConfig._();

  static const String baseUrl = "http://test-app.bigegg.work/";
  static String requestToken = "";

  static Map<String, dynamic> getHeaders() {
    Map<String, dynamic> requestHeader = {};
    requestHeader['ver'] = "1.0.0";
    requestHeader['pkg'] = "test.bigegg.android";
    requestHeader['sys_lan'] = "zh";
    requestHeader['lang'] = "zh";
    requestHeader['device_lang'] = "zh";

    requestHeader['device-id'] = "d95140f1b6b1d8fa";
    requestHeader['platform'] = 'Android';
    requestHeader['model'] = 'sdk_arm64';
    requestHeader['platform_ver'] = "34";
    requestHeader['google_ad_id'] = "00000000-0000-0000-0000-00000000000";
    requestHeader["is_anchor"] = "false";
    requestHeader["attribution_sdk"] = "AJ";
    requestHeader["attribution_sdk_ver"] = "android4.38.5";

    if (AppConfig.requestToken.isNotEmpty) {
      requestHeader['Authorization'] = 'Bearer${AppConfig.requestToken}';
    }

    requestHeader['rc_type'] = "SG";
    requestHeader['sec_ver'] = '0';
    return requestHeader;
  }
}
