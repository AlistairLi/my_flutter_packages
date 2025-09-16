import 'package:event_bus_plus/res/event_bus.dart';

/// EventBus 单例
class AppEventBus extends EventBus {
  AppEventBus.internal();

  static final AppEventBus _instance = AppEventBus.internal();

  factory AppEventBus() {
    return _instance;
  }
}
