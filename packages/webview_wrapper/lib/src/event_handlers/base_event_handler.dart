import 'package:flutter/cupertino.dart';

/// 基础事件处理器接口
abstract class BaseEventHandler {
  /// 检查是否可以处理该事件
  /// [data] 事件数据，对于外部链接是URL字符串，对于JS事件可能是消息内容
  bool canHandle(dynamic data);

  /// 处理事件
  /// [data] 事件数据
  /// 返回值：true表示已处理，false表示未处理
  bool handle(BuildContext context, dynamic data);

  /// 处理器优先级，数字越小优先级越高，默认0
  int get priority => 0;

  /// 处理器名称，用于调试和日志
  String get name => runtimeType.toString();
}

/// 外部链接事件处理器接口
abstract class ExternalLinkEventHandler extends BaseEventHandler {
  @override
  bool canHandle(dynamic data) {
    if (data is! String) return false;
    return canHandleUrl(data);
  }

  @override
  bool handle(BuildContext context, dynamic data) {
    if (data is! String) return false;
    return handleUrl(data);
  }

  /// 检查是否可以处理该URL
  bool canHandleUrl(String url);

  /// 处理URL
  /// 返回值：true表示已处理，false表示未处理
  bool handleUrl(String url);
}

/// JS事件处理器接口
abstract class JSEventHandler extends BaseEventHandler {
  @override
  bool canHandle(dynamic data) {
    if (data is! Map<String, dynamic>) return false;
    return canHandleJSEvent(data['methodName'], data['message']);
  }

  @override
  bool handle(BuildContext context, dynamic data) {
    if (data is! Map<String, dynamic>) return false;
    return handleJSEvent(context, data['methodName'], data['message']);
  }

  /// 检查是否可以处理该JS事件
  bool canHandleJSEvent(String methodName, String message);

  /// 处理JS事件
  /// 返回值：true表示已处理，false表示未处理
  bool handleJSEvent(BuildContext context, String methodName, String message);
}
