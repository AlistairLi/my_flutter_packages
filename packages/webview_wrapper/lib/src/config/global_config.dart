import 'package:flutter/widgets.dart';
import 'package:webview_wrapper/src/event_handlers/base_event_handler.dart';

/// 全局WebView配置管理
class WebViewGlobalConfig {
  /// 全局自定义事件配置
  static Map<String, String>? _globalCustomEvents;

  /// 全局事件回调函数
  static Map<String, Function(BuildContext context, String event)>?
      _globalEventCallbacks;

  /// 全局事件处理器列表
  static List<BaseEventHandler>? _globalEventHandlers;

  /// 获取全局自定义事件配置
  static Map<String, String>? get globalCustomEvents => _globalCustomEvents;

  /// 获取全局事件回调函数
  static Map<String, Function(BuildContext context, String event)>?
      get globalEventCallbacks => _globalEventCallbacks;

  /// 获取全局事件处理器列表
  static List<BaseEventHandler>? get globalEventHandlers =>
      _globalEventHandlers;

  /// 设置全局自定义事件配置
  static void setGlobalCustomEvents(Map<String, String> events) {
    _globalCustomEvents = events;
  }

  /// 设置全局事件回调函数
  static void setGlobalEventCallbacks(
      Map<String, Function(BuildContext context, String event)> callbacks) {
    _globalEventCallbacks = callbacks;
  }

  /// 设置全局事件处理器列表
  static void setGlobalEventHandlers(List<BaseEventHandler> handlers) {
    _globalEventHandlers = handlers;
  }

  /// 添加全局事件处理器
  static void addGlobalEventHandler(BaseEventHandler handler) {
    _globalEventHandlers ??= [];
    _globalEventHandlers!.add(handler);
  }

  /// 移除全局事件处理器
  static void removeGlobalEventHandler(BaseEventHandler handler) {
    _globalEventHandlers?.remove(handler);
  }

  /// 设置全局配置
  static void setGlobalConfig({
    Map<String, String>? customEvents,
    Map<String, Function(BuildContext context, String event)>? eventCallbacks,
    List<BaseEventHandler>? eventHandlers,
  }) {
    if (customEvents != null) {
      _globalCustomEvents = customEvents;
    }
    if (eventCallbacks != null) {
      _globalEventCallbacks = eventCallbacks;
    }
    if (eventHandlers != null) {
      _globalEventHandlers = eventHandlers;
    }
  }

  /// 清除全局配置
  static void clearGlobalConfig() {
    _globalCustomEvents = null;
    _globalEventCallbacks = null;
    _globalEventHandlers = null;
  }

  /// 添加单个全局事件配置
  static void addGlobalEvent(String jsMethodName, String channelName) {
    _globalCustomEvents ??= {};
    _globalCustomEvents![jsMethodName] = channelName;
  }

  /// 添加单个全局事件回调
  static void addGlobalEventCallback(String jsMethodName,
      Function(BuildContext context, String event) callback) {
    _globalEventCallbacks ??= {};
    _globalEventCallbacks![jsMethodName] = callback;
  }

  /// 移除单个全局事件配置
  static void removeGlobalEvent(String jsMethodName) {
    _globalCustomEvents?.remove(jsMethodName);
  }

  /// 移除单个全局事件回调
  static void removeGlobalEventCallback(String jsMethodName) {
    _globalEventCallbacks?.remove(jsMethodName);
  }
}
