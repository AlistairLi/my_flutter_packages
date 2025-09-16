import 'package:app_base_kit/app_base_kit.dart';

// 定义事件
class MessageEvent extends AppEvent {
  final String? message;

  MessageEvent(this.message);

  @override
  List<Object?> get props => [message, timestamp];
}

class SomeAnotherEvent extends AppEvent {
  final String? message;

  SomeAnotherEvent(this.message);

  @override
  List<Object?> get props => [timestamp, message];
}

void main() async {
  // 创建一个事件
  var event = MessageEvent("Hello World");

  // 监听特定事件
  var sub = AppEventBus().on<MessageEvent>().listen((event) {
    print(event.message);
  });

  // 等待3秒
  await Future.delayed(Duration(seconds: 3));

  // 触发事件
  AppEventBus().fire(event);

  // 获取事件历史
  var list = AppEventBus().history;

  // 等待5秒
  await Future.delayed(Duration(seconds: 5));

  // 取消订阅
  sub.cancel();

  // 取消订阅后，再触发事件，看有没有响应-没有
  AppEventBus().fire(event);

  // 等待5秒
  await Future.delayed(Duration(seconds: 5));

  watch();
}

/// 监听进行中的事件
void watch() {
  // 创建一个事件
  var event = MessageEvent("Hello World");

  // 开始监听事件直到其完成
  AppEventBus().watch(event);

  // 并检查进度
  var inProgress = AppEventBus().isInProgress<MessageEvent>();

  // 或者监听流以查看处理过程
  var stream = AppEventBus().inProgress$.map(
      (List<AppEvent> events) => events.whereType<MessageEvent>().isNotEmpty);

  // complete
  AppEventBus().complete(event);

  // 或通过完成事件确认完成
  AppEventBus().complete(event, nextEvent: SomeAnotherEvent("HelloWorld"));
}

/// Mapping
void mapping() {
  // final eventBus = bus = EventBus(
  //   map: {
  //     SomeEvent: [
  //           (e) => SomeAnotherEvent(),
  //     ],
  //   },
  // );
}
