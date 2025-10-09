abstract class IIAPLogger {
  void log(
    String event, {
    String? productId,
    String? orderNo,
    String? errorCode,
    String? errorMsg,
  });
}
