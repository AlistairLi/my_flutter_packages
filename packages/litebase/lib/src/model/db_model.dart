/// 数据模型统一接口
abstract class DbModel {
  Map<String, dynamic> toMap();

  /// 可选实现，默认用 toMap()
  // Map<String, dynamic> toJson() => toMap();

  /// 你可以选择实现 fromJson 静态方法
}
