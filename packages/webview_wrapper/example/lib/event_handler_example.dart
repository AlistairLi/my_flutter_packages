import 'package:flutter/material.dart';
import 'package:webview_wrapper/webview_wrapper.dart';

import 'external_link_handlers.dart';

/// 插件式事件处理器使用示例
class EventHandlerExample {
  /// 演示如何使用插件式事件处理器
  static void demonstrateEventHandlers() {
    // 1. 创建自定义事件处理器
    final customPhoneHandler = CustomPhoneHandler();
    final customEmailHandler = CustomEmailHandler();

    // 2. 设置全局事件处理器
    WebViewGlobalConfig.setGlobalEventHandlers([
      PhoneLinkHandler(), // 内置电话处理器
      EmailLinkHandler(), // 内置邮件处理器
      SmsLinkHandler(), // 内置短信处理器
      MapLinkHandler(), // 内置地图处理器
      AppStoreLinkHandler(), // 内置应用商店处理器
      IntentLinkHandler(), // 内置Intent处理器
      CustomProtocolLinkHandler(), // 内置自定义协议处理器
    ]);

    // 3. 添加自定义处理器（会覆盖内置处理器）
    WebViewGlobalConfig.addGlobalEventHandler(customPhoneHandler);
    WebViewGlobalConfig.addGlobalEventHandler(customEmailHandler);
  }

  /// 打开WebView并演示事件处理器
  static void openWebViewWithEventHandlers(BuildContext context) {
    // 创建自定义事件处理器
    final customHandlers = [
      CustomPhoneHandler(),
      CustomEmailHandler(),
      CustomSmsHandler(),
    ];

    // 创建WebView配置
    final config = WebViewConfig(
      url: "https://example.com",
      scene: WebViewScene.game,
      needAppbar: true,
      title: "插件式事件处理器演示",
      eventHandlers: customHandlers, // 使用自定义事件处理器
    );

    // 打开WebView
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewPage(config: config),
      ),
    );
  }
}

/// 自定义电话处理器
class CustomPhoneHandler extends ExternalLinkEventHandler {
  static const String _tag = "CustomPhoneHandler";

  @override
  bool canHandleUrl(String url) {
    return url.startsWith("tel:");
  }

  @override
  bool handleUrl(String url) {
    print("$_tag: 自定义处理电话链接: $url");
    // 这里可以实现自定义的电话处理逻辑
    // 比如显示确认对话框、记录日志等
    return true;
  }

  @override
  int get priority => 1;

  @override
  String get name => "CustomPhoneHandler";
}

/// 自定义邮件处理器
class CustomEmailHandler extends ExternalLinkEventHandler {
  static const String _tag = "CustomEmailHandler";

  @override
  bool canHandleUrl(String url) {
    return url.startsWith("mailto:");
  }

  @override
  bool handleUrl(String url) {
    print("$_tag: 自定义处理邮件链接: $url");
    return true;
  }

  @override
  int get priority => 2;

  @override
  String get name => "CustomEmailHandler";
}

/// 自定义短信处理器
class CustomSmsHandler extends ExternalLinkEventHandler {
  static const String _tag = "CustomSmsHandler";

  @override
  bool canHandleUrl(String url) {
    return url.startsWith("sms:");
  }

  @override
  bool handleUrl(String url) {
    print("$_tag: 自定义处理短信链接: $url");
    return true;
  }

  @override
  int get priority => 3;

  @override
  String get name => "CustomSmsHandler";
}

/// 演示如何创建JS事件处理器（预留，后续实现）
class CustomJSEventHandler extends JSEventHandler {
  static const String _tag = "CustomJSEventHandler";

  @override
  bool canHandleJSEvent(String methodName, String message) {
    return methodName == 'custom';
  }

  @override
  bool handleJSEvent(BuildContext context, String methodName, String message) {
    print("$_tag: 处理自定义JS事件: $methodName, $message");
    return true;
  }

  @override
  int get priority => 1;

  @override
  String get name => "CustomJSEventHandler";
}
