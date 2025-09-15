import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_wrapper/src/config/config.dart';

import 'event_handlers/event_processor.dart';
import 'web_view_controller.dart';

/// WebView, 加载网页
class WebViewPage extends StatefulWidget {
  final WebViewConfig config;
  final WebViewWrapperController? controller;

  const WebViewPage({
    super.key,
    required this.config,
    this.controller,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final tag = "WebViewPage";

  var _controller = WebViewController();
  late final WebViewConfig _config = widget.config;
  late final EventProcessor _eventProcessor = EventProcessor();

  void _init() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    WebViewController webViewController =
        WebViewController.fromPlatformCreationParams(params);
    webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return _handleNavigationRequest(request.url);
          },
          onPageFinished: (String url) async {
            if (Platform.isIOS == false) {
              String script1 = _config.generateWebViewJS1();
              if (script1.isNotEmpty) {
                await webViewController.runJavaScript(script1);
              }
              String script2 = _config.generateWebviewJS2();
              if (script2.isNotEmpty) {
                await webViewController.runJavaScript(script2);
              }
            }
          },
        ),
      );

    // 初始化事件处理器
    _initEventHandlers();

    // 动态添加JavaScriptChannel
    _addJavaScriptChannels(webViewController);

    webViewController.loadRequest(Uri.parse(_config.url));

    if (webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = webViewController;

    // 附加控制器
    if (widget.controller != null) {
      widget.controller!.attach(webViewController, _config);
    }
  }

  /// 初始化事件处理器
  void _initEventHandlers() {
    // 添加配置中的事件处理器
    for (var handler in _config.finalEventHandlers) {
      _eventProcessor.addHandler(handler);
    }
  }

  /// 处理导航请求
  /// 使用事件处理器处理外部链接
  NavigationDecision _handleNavigationRequest(String url) {
    // 使用事件处理器处理
    final bool shouldPrevent = _eventProcessor.process(context, url);

    return shouldPrevent
        ? NavigationDecision.prevent
        : NavigationDecision.navigate;
  }

  /// 动态添加JavaScriptChannel
  void _addJavaScriptChannels(WebViewController controller) {
    Map<String, String> events = _config.finalCustomEvents;
    if (events.isEmpty) {
      return;
    }

    events.forEach((jsMethodName, channelName) {
      controller.addJavaScriptChannel(
        jsMethodName,
        onMessageReceived: (JavaScriptMessage message) {
          // 使用事件处理器处理JS事件
          _handleJSEvent(jsMethodName, message.message);
        },
      );
    });
  }

  /// 处理JS事件
  void _handleJSEvent(String methodName, String message) {
    // 创建JS事件数据
    final eventData = {
      'methodName': methodName,
      'message': message,
    };

    // 使用事件处理器处理
    final bool handled = _eventProcessor.process(context, eventData);

    if (!handled) {
      // 如果没有处理器处理，则使用原有的回调机制（向后兼容）
      Map<String, Function(BuildContext context, String event)> callbacks =
          _config.finalEventCallbacks;
      if (callbacks.containsKey(methodName)) {
        callbacks[methodName]!(context, message);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.detach();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _config.needAppbar
          ? AppBar(
              title: Text(_config.title ?? ""),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        top: !_config.needAppbar,
        bottom: false,
        child: WebViewPlatform.instance is WebKitWebViewPlatform
            ? WebViewWidget(
                controller: _controller,
              )
            : WebViewWidget.fromPlatformCreationParams(
                params: AndroidWebViewWidgetCreationParams(
                  displayWithHybridComposition: true, // 开启允许使用跨平台组件
                  controller: _controller.platform,
                ),
              ),
      ),
    );
  }
}
