import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_wrapper/src/config/config.dart';

/// WebView包装器控制器
class WebViewWrapperController {
  WebViewController? _webViewController;
  WebViewConfig? _config;
  bool _isAttached = false;

  /// 获取内部的WebViewController
  WebViewController? get webViewController => _webViewController;

  /// 获取当前配置
  WebViewConfig? get config => _config;

  /// 检查是否已附加到WebView
  bool get isAttached => _isAttached;

  /// 检查当前WebView是否为游戏场景
  bool get isGameScene => _config?.scene == WebViewScene.game;

  /// 获取当前场景
  WebViewScene? get currentScene => _config?.scene;

  /// 附加到WebView, 内部使用，外部不需要调用
  void attach(WebViewController webViewController, WebViewConfig config) {
    _webViewController = webViewController;
    _config = config;
    _isAttached = true;
  }

  /// 分离WebView, 内部使用，外部不需要调用
  void detach() {
    _webViewController = null;
    _config = null;
    _isAttached = false;
  }

  /// 向网页发送充值成功通知,当应用充值成功后调用此方法
  Future<void> notifyRechargeSuccess(WebViewScene scene) async {
    if (!_isAttached || _webViewController == null) {
      return;
    }

    if (_config?.scene == scene) {
      try {
        await _webViewController!.loadRequest(
          Uri.parse("javascript:HttpTool.NativeToJs('recharge')"),
        );
      } catch (e) {}
    }
  }

  /// 向网页发送自定义消息
  /// [methodName] JS方法名
  /// [data] 要传递的数据（可选）
  Future<void> sendMessageToWeb(String methodName, [String? data]) async {
    if (!_isAttached || _webViewController == null) {
      return;
    }

    try {
      String script = data != null
          ? "javascript:HttpTool.NativeToJs('$methodName', '$data')"
          : "javascript:HttpTool.NativeToJs('$methodName')";

      await _webViewController!.loadRequest(Uri.parse(script));
    } catch (e) {}
  }

  /// 执行JavaScript代码
  /// [script] 要执行的JavaScript代码
  Future<void> runJavaScript(String script) async {
    if (!_isAttached || _webViewController == null) {
      return;
    }

    try {
      return await _webViewController!.runJavaScript(script);
    } catch (e) {
      return;
    }
  }

  /// 重新加载页面
  Future<void> reload() async {
    if (!_isAttached || _webViewController == null) {
      return;
    }

    try {
      await _webViewController!.reload();
    } catch (e) {}
  }

  /// 返回上一页
  Future<void> goBack() async {
    if (!_isAttached || _webViewController == null) {
      return;
    }

    try {
      return await _webViewController!.goBack();
    } catch (e) {
      return;
    }
  }

  /// 前进到下一页
  Future<void> goForward() async {
    if (!_isAttached || _webViewController == null) {
      return;
    }

    try {
      return await _webViewController!.goForward();
    } catch (e) {
      return;
    }
  }

  /// 检查是否可以返回
  Future<bool> canGoBack() async {
    if (!_isAttached || _webViewController == null) {
      return false;
    }

    try {
      return await _webViewController!.canGoBack();
    } catch (e) {
      return false;
    }
  }

  /// 检查是否可以前进
  Future<bool> canGoForward() async {
    if (!_isAttached || _webViewController == null) {
      return false;
    }

    try {
      return await _webViewController!.canGoForward();
    } catch (e) {
      return false;
    }
  }

  /// 获取当前URL
  Future<String?> getCurrentUrl() async {
    if (!_isAttached || _webViewController == null) {
      return null;
    }

    try {
      return await _webViewController!.currentUrl();
    } catch (e) {
      return null;
    }
  }

  /// 获取页面标题
  Future<String?> getTitle() async {
    if (!_isAttached || _webViewController == null) {
      return null;
    }

    try {
      return await _webViewController!.getTitle();
    } catch (e) {
      return null;
    }
  }
}
