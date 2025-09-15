import 'package:flutter/cupertino.dart';
import 'package:webview_wrapper/webview_wrapper.dart';

/// 应用层的webview工具
class AppWebviewUtilExample {
  AppWebviewUtilExample._();

  static WebViewWrapperController controller1 = WebViewWrapperController();

  // 约定好的事件
  static Map<String, String> webViewEvents = {
    "close": "close",
    "yyy": "yyy",
    "zzz": "zzz",
  };

  static void initialize() {
    WebViewGlobalConfig.setGlobalCustomEvents(webViewEvents);
    WebViewGlobalConfig.setGlobalEventHandlers([
      AppJsEventHandlerExample(supportMethods: webViewEvents.keys),
      IntentHandler(),
    ]);
  }

  static void onRechargeSuccess() {
    controller1.notifyRechargeSuccess(WebViewScene.game);
  }
}

class AppJsEventHandlerExample extends JSEventHandler {
  final Iterable<String> supportMethods;

  AppJsEventHandlerExample({required this.supportMethods});

  @override
  bool canHandleJSEvent(String methodName, String message) {
    return supportMethods.contains(methodName);
  }

  @override
  bool handleJSEvent(BuildContext context, String methodName, String message) {
    switch (methodName) {
      case "close":
        Navigator.pop(context);
        return true;
      case "yyy":
        // do something
        return true;
    }
    return false;
  }
}

class IntentHandler extends ExternalLinkEventHandler {
  @override
  bool canHandleUrl(String url) {
    return url.startsWith("intent:") || !url.startsWith("http");
  }

  @override
  bool handleUrl(String url) {
    // launchUrl(Uri.parse(url));
    return true;
  }
}
