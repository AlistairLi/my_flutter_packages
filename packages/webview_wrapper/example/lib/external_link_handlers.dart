import 'package:webview_wrapper/src/event_handlers/base_event_handler.dart';

/// 电话链接处理器
class PhoneLinkHandler extends ExternalLinkEventHandler {
  @override
  bool canHandleUrl(String url) {
    return url.startsWith("tel:");
  }

  @override
  bool handleUrl(String url) {
    // 这里可以使用url_launcher等库来打开电话应用
    // launchUrl(Uri.parse(url));
    return true; // 已处理
  }

  @override
  int get priority => 10;

  @override
  String get name => "PhoneLinkHandler";
}

/// 邮件链接处理器
class EmailLinkHandler extends ExternalLinkEventHandler {
  @override
  bool canHandleUrl(String url) {
    return url.startsWith("mailto:");
  }

  @override
  bool handleUrl(String url) {
    // 这里可以使用url_launcher等库来打开邮件应用
    // launchUrl(Uri.parse(url));
    return true; // 已处理
  }

  @override
  int get priority => 20;

  @override
  String get name => "EmailLinkHandler";
}

/// 短信链接处理器
class SmsLinkHandler extends ExternalLinkEventHandler {
  @override
  bool canHandleUrl(String url) {
    return url.startsWith("sms:");
  }

  @override
  bool handleUrl(String url) {
    // 这里可以使用url_launcher等库来打开短信应用
    // launchUrl(Uri.parse(url));
    return true; // 已处理
  }

  @override
  int get priority => 30;

  @override
  String get name => "SmsLinkHandler";
}

/// 地图链接处理器
class MapLinkHandler extends ExternalLinkEventHandler {
  @override
  bool canHandleUrl(String url) {
    return url.startsWith("geo:");
  }

  @override
  bool handleUrl(String url) {
    // 这里可以使用url_launcher等库来打开地图应用
    // launchUrl(Uri.parse(url));
    return true; // 已处理
  }

  @override
  int get priority => 40;

  @override
  String get name => "MapLinkHandler";
}

/// 应用商店链接处理器
class AppStoreLinkHandler extends ExternalLinkEventHandler {
  @override
  bool canHandleUrl(String url) {
    return url.startsWith("market:");
  }

  @override
  bool handleUrl(String url) {
    // 这里可以使用url_launcher等库来打开应用商店
    // launchUrl(Uri.parse(url));
    return true; // 已处理
  }

  @override
  int get priority => 50;

  @override
  String get name => "AppStoreLinkHandler";
}

/// Android Intent链接处理器
class IntentLinkHandler extends ExternalLinkEventHandler {
  @override
  bool canHandleUrl(String url) {
    return url.startsWith("intent:");
  }

  @override
  bool handleUrl(String url) {
    // 这里可以使用url_launcher等库来处理Intent
    // launchUrl(Uri.parse(url));
    return true; // 已处理
  }

  @override
  int get priority => 60;

  @override
  String get name => "IntentLinkHandler";
}

/// 自定义协议链接处理器
class CustomProtocolLinkHandler extends ExternalLinkEventHandler {
  @override
  bool canHandleUrl(String url) {
    return url.contains("://") &&
        !url.startsWith("http://") &&
        !url.startsWith("https://") &&
        !url.startsWith("tel:") &&
        !url.startsWith("mailto:") &&
        !url.startsWith("sms:") &&
        !url.startsWith("geo:") &&
        !url.startsWith("market:") &&
        !url.startsWith("intent:");
  }

  @override
  bool handleUrl(String url) {
    // 这里可以处理自定义协议
    return true; // 已处理
  }

  @override
  int get priority => 100; // 最低优先级，作为兜底处理器

  @override
  String get name => "CustomProtocolLinkHandler";
}
