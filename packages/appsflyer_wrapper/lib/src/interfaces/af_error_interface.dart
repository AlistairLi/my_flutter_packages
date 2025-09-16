abstract class AFErrorInterface {
  /// 上报错误信息到后端
  void onError({
    String event,
    String source,
    String? errorMsg,
  });
}
