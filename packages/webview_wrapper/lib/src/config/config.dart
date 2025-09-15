import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:webview_wrapper/src/config/global_config.dart';
import 'package:webview_wrapper/src/event_handlers/base_event_handler.dart';

class WebViewConfig {
  /// 网页链接
  String url;

  /// 页面场景
  WebViewScene scene;

  /// 是否需要原生导航
  bool needAppbar;

  /// 标题，需要显示AppBar时传入
  String? title;

  /// 自定义事件配置，key为JS方法名，value为对应的JavaScriptChannel名称
  Map<String, String>? customEvents;

  /// 事件回调函数
  Map<String, Function(BuildContext context, String event)>? eventCallbacks;

  /// 事件处理器列表
  /// 用于处理各种事件（外部链接、JS事件等）
  List<BaseEventHandler>? eventHandlers;

  WebViewConfig({
    required this.url,
    required this.scene,
    required this.needAppbar,
    this.title,
    this.customEvents,
    this.eventCallbacks,
    this.eventHandlers,
  });

  /// 获取最终的事件配置（合并全局配置和实例配置）
  Map<String, String> get finalCustomEvents {
    Map<String, String> result = {};

    // 先添加全局配置
    if (WebViewGlobalConfig.globalCustomEvents != null) {
      result.addAll(WebViewGlobalConfig.globalCustomEvents!);
    }

    // 再添加实例配置（会覆盖全局配置中的相同key）
    if (customEvents != null) {
      result.addAll(customEvents!);
    }

    return result;
  }

  /// 获取最终的事件回调函数（合并全局配置和实例配置）
  Map<String, Function(BuildContext context, String event)>
      get finalEventCallbacks {
    Map<String, Function(BuildContext context, String event)> result = {};

    // 先添加全局配置
    if (WebViewGlobalConfig.globalEventCallbacks != null) {
      result.addAll(WebViewGlobalConfig.globalEventCallbacks!);
    }

    // 再添加实例配置（会覆盖全局配置中的相同key）
    if (eventCallbacks != null) {
      result.addAll(eventCallbacks!);
    }

    return result;
  }

  /// 获取事件处理器（合并全局配置和实例配置）
  List<BaseEventHandler> get finalEventHandlers {
    List<BaseEventHandler> result = [];

    // 先添加全局事件处理器
    if (WebViewGlobalConfig.globalEventHandlers != null) {
      result.addAll(WebViewGlobalConfig.globalEventHandlers!);
    }

    // 再添加实例事件处理器
    if (eventHandlers != null) {
      result.addAll(eventHandlers!);
    }

    return result;
  }

  /// 生成第一段需要注入的JS
  String generateWebViewJS1() {
    Map<String, String> events = finalCustomEvents;
    if (events.isEmpty) {
      return '';
    }

    String json = '';
    events.forEach((key, value) {
      json +=
          '$key:(arg)=>{$value.postMessage(typeof arg=="object"? JSON.stringify( arg || {} ) :  (arg || "" ) ) },';
    });
    String javaScript = 'window.JSBridgeService = {$json};';
    return javaScript;
  }

  /// 生成第二段JS
  String generateWebviewJS2() {
    Map<String, String> events = finalCustomEvents;
    if (events.isEmpty) {
      return '';
    }

    List<String> keys = [];
    events.forEach((key, value) {
      keys.add(key);
    });
    String json = jsonEncode(keys);
    String javaScript = 'window.getSupportApi($json);';
    return javaScript;
  }
}

enum WebViewScene {
  /// 游戏场景
  game,

  /// 充值场景
  recharge,
}
