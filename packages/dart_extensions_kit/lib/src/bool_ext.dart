/// bool 的扩展方法
extension BoolExtensions on bool {
  /// 转换为int（true=1, false=0）
  int get toInt => this ? 1 : 0;

  /// 转换为中文
  String get toChinese => this ? '是' : '否';
}

extension BoolExtensions2 on bool? {
  bool get isTrue => this == true;
}
