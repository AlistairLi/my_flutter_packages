import 'package:flutter/cupertino.dart';

import 'base_event_handler.dart';

/// 事件处理器管理器
class EventProcessor {
  final List<BaseEventHandler> _handlers = [];

  /// 添加事件处理器
  void addHandler(BaseEventHandler handler) {
    _handlers.add(handler);
    _sortHandlers();
  }

  /// 移除事件处理器
  void removeHandler(BaseEventHandler handler) {
    _handlers.remove(handler);
  }

  /// 移除指定类型的事件处理器
  void removeHandlerByType<T extends BaseEventHandler>() {
    _handlers.removeWhere((handler) => handler is T);
  }

  /// 清空所有事件处理器
  void clearHandlers() {
    _handlers.clear();
  }

  /// 处理事件
  /// [data] 事件数据
  /// 返回值：true表示已处理，false表示未处理
  bool process(BuildContext context, dynamic data) {
    for (var handler in _handlers) {
      if (handler.canHandle(data)) {
        if (handler.handle(context, data)) {
          return true;
        }
      }
    }
    return false;
  }

  /// 获取所有事件处理器
  List<BaseEventHandler> get handlers => List.unmodifiable(_handlers);

  /// 获取指定类型的事件处理器
  List<T> getHandlersByType<T extends BaseEventHandler>() {
    return _handlers.whereType<T>().toList();
  }

  /// 检查是否有指定类型的事件处理器
  bool hasHandler<T extends BaseEventHandler>() {
    return _handlers.any((handler) => handler is T);
  }

  /// 按优先级排序处理器
  void _sortHandlers() {
    _handlers.sort((a, b) => a.priority.compareTo(b.priority));
  }
}
