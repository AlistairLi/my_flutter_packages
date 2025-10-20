class RequestLoadingController {
  final void Function()? _onShow;
  final void Function()? _onDismiss;

  int _loadingCounter = 0;

  RequestLoadingController({void Function()? show, void Function()? dismiss})
      : _onShow = show,
        _onDismiss = dismiss;

  /// 每个请求开始时调用
  /// TODO 高并发请求时，会不会出现问题
  void show() {
    _loadingCounter++;
    if (_loadingCounter == 1) {
      _onShow?.call();
    }
  }

  /// 每个请求完成时调用
  /// TODO 高并发请求时，会不会出现问题
  void dismiss() {
    _loadingCounter = (_loadingCounter - 1).clamp(0, double.infinity).toInt();
    if (_loadingCounter == 0) {
      _onDismiss?.call();
    }
  }

  void reset() {
    _loadingCounter = 0;
    _onDismiss?.call();
  }
}
