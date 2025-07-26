/// 数据转换回调函数类型
typedef DataTransformer<T> = List<T> Function(dynamic data);

/// 分页数据模型
class PageData<T> {
  final List<T> data;
  final int page;
  final int pageSize;
  final bool Function(List<T> value)? hasMoreChecker;

  const PageData({
    required this.data,
    required this.page,
    required this.pageSize,
    this.hasMoreChecker,
  });

  bool getHasMore() {
    if (hasMoreChecker != null) {
      return hasMoreChecker!.call(data);
    }
    // 默认逻辑
    return data.isNotEmpty;
  }

  factory PageData.empty({int page = 1, int pageSize = 20}) {
    return PageData(
      data: [],
      page: page,
      pageSize: pageSize,
    );
  }
}
