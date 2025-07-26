import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smart_refresh_list/src/config/smart_refresh_config.dart';

/// 刷新控制器
class SmartRefreshController<T> {
  final RefreshController _controller;

  /// 当前页码
  int _currentPage = 1;

  /// 当前页面大小（从PageData中获取）
  int? _currentPageSize;

  /// 数据列表状态管理器
  final ValueNotifier<List<T>> _dataNotifier = ValueNotifier([]);

  /// 去重条件
  final dynamic Function(T element)? distinctKeySelector;

  SmartRefreshController({
    bool initialRefresh = false,
    this.distinctKeySelector,
  }) : _controller = RefreshController(
          initialRefresh: initialRefresh,
          initialRefreshStatus:
              initialRefresh ? RefreshStatus.refreshing : RefreshStatus.idle,
        );

  /// 获取原始的RefreshController
  RefreshController get raw => _controller;

  /// 获取数据ValueNotifier
  ValueNotifier<List<T>> get dataNotifier => _dataNotifier;

  /// 获取当前数据列表
  List<T> get dataList => _dataNotifier.value;

  /// 获取当前页面大小
  int get pageSize => _currentPageSize ?? RefreshConfig.defaultPageSize;

  /// 获取当前页码
  int get currentPage => _currentPage;

  RefreshStatus? get headerStatus => _controller.headerStatus;

  LoadStatus? get footerStatus => _controller.footerStatus;

  /// 数据是否为空
  bool get isEmpty => _dataNotifier.value.isEmpty;

  /// 数据数量
  int get length => _dataNotifier.value.length;

  /// 完成刷新
  void finishRefresh({bool success = true}) {
    if (success) {
      _controller.refreshCompleted(resetFooterState: true);
    } else {
      _controller.refreshFailed();
    }
  }

  /// 完成加载
  void finishLoad({bool success = true, bool noMore = false}) {
    if (noMore) {
      _controller.loadNoData();
    } else {
      success ? _controller.loadComplete() : _controller.loadFailed();
    }
  }

  /// 设置数据列表
  void setData(List<T> data) {
    if (distinctKeySelector != null) {
      _dataNotifier.value = data.distinctBy(distinctKeySelector!);
    } else {
      _dataNotifier.value = data;
    }
  }

  /// 添加数据
  void addData(List<T> data) {
    final newList = List<T>.from(_dataNotifier.value)..addAll(data);
    if (distinctKeySelector != null) {
      _dataNotifier.value = newList.distinctBy(distinctKeySelector!);
    } else {
      _dataNotifier.value = newList;
    }
  }

  /// 移除数据
  void removeData(T data) {
    final newList = List<T>.from(_dataNotifier.value)..remove(data);
    _dataNotifier.value = newList;
  }

  /// 根据条件移除第一个匹配的数据
  void removeFirstWhere(bool Function(T element) test) {
    final newList = List<T>.from(_dataNotifier.value);
    final index = newList.indexWhere(test);
    if (index != -1) {
      newList.removeAt(index);
      _dataNotifier.value = newList;
    }
  }

  /// 获取数据列表中某一个字段的列表
  List<R?> getFieldList<R>(R? Function(T element) fieldSelector) {
    return _dataNotifier.value.map(fieldSelector).toList();
  }

  /// 更新列表中某项的某个字段值
  /// [idSelector]：获取元素的唯一标识符（如 id）
  /// [fieldSelector]：获取需要更新的字段
  /// [updates]：Map形式的数据
  /// [updater]：给定旧对象和新值，返回更新后的新对象
  void updateField<R, V>(
    Map<R, V> updates,
    R Function(T element) idSelector,
    T Function(T item, V value) updater,
  ) {
    if (updates.isEmpty) return;
    final newList = _dataNotifier.value.map((item) {
      final uid = idSelector(item);
      final value = updates[uid];
      if (value != null) {
        return updater(item, value);
      }
      return item;
    }).toList();

    _dataNotifier.value = newList;
  }

  /// 更新列表中某项的某个字段值（直接修改原对象）
  /// [idSelector]：获取元素的唯一标识符（如 id）
  /// [updates]：Map形式的数据
  /// [updater]：给定旧对象和新值，直接修改该对象
  void updateFieldInPlace<R, V>(
    Map<R, V> updates,
    R Function(T element) idSelector,
    void Function(T item, V value) updater,
  ) {
    if (updates.isEmpty) return;
    final newList = _dataNotifier.value.map((item) {
      final uid = idSelector(item);
      final value = updates[uid];
      if (value != null) {
        updater(item, value);
      }
      return item;
    }).toList();

    _dataNotifier.value = newList;
  }

  /// 设置当前页码和页面大小
  void setPage(int page, {int? pageSize}) {
    _currentPage = page;
    if (pageSize != null) {
      _currentPageSize = pageSize;
    }
  }

  /// 手动触发刷新
  void requestRefresh() {
    _controller.requestRefresh();
  }

  /// 手动触发加载
  void requestLoad() {
    // if (footerStatus != LoadStatus.noMore) {
    _controller.requestLoading();
    // }
  }

  /// 清空数据
  void clearData() {
    _dataNotifier.value = [];
    _currentPage = 1;
    _currentPageSize = null;
  }

  /// 重置状态
  void reset() {
    _controller.resetNoData();
  }

  /// 释放资源
  void dispose() {
    _controller.dispose();
    _dataNotifier.dispose();
  }
}

extension ListExtensions<T> on List<T> {
  /// 根据条件去重
  List<T> distinctBy<R>(R Function(T element) keySelector) {
    final seen = <R>{};
    return where((element) => seen.add(keySelector(element))).toList();
  }
}
