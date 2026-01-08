import 'dart:math';

/// List 的扩展方法
extension ListExtensions<T> on List<T> {
  /// 安全获取元素，如果索引超出范围返回 null
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// 安全获取元素，如果索引超出范围返回默认值
  T getOrDefault(int index, T defaultValue) {
    return getOrNull(index) ?? defaultValue;
  }

  /// 随机获取一个元素
  T? get randomOrNull => isEmpty ? null : this[Random().nextInt(length)];

  /// 随机获取一个元素，如果列表为空返回默认值
  T randomOrDefault(T defaultValue) => randomOrNull ?? defaultValue;

  /// 随机打乱列表
  List<T> get shuffled => List<T>.from(this)..shuffle();

  /// 去重（保持顺序）
  List<T> get distinct {
    Set<T> seen = {};
    return where((element) => seen.add(element)).toList();
  }

  /// 根据条件去重
  List<T> distinctBy<R>(R Function(T) keySelector) {
    Set<R> seen = {};
    return where((element) => seen.add(keySelector(element))).toList();
  }

  /// 提取属性列表
  ///
  /// - selector: 指定获取的属性
  /// - distinct: 是否去重（默认 true）
  /// - ignoreNull: 是否忽略 null（默认 true）
  /// - ignoreEmptyString: 是否忽略空字符串（仅 String 生效，默认 true）
  ///
  /// ### 示例
  /// ```dart
  ///  final userIds = users.select((u) => u.userId);
  ///  ```
  List<R> select<R>(R? Function(T item) selector, {
    bool distinct = true,
    bool ignoreNull = true,
    bool ignoreEmptyString = true,
  }) {
    Iterable<R?> result = whereType<T>().map(selector);

    if (ignoreNull) {
      result = result.where((e) => e != null);
    }

    // 仅当 R 为 String 时，过滤空字符串
    if (ignoreEmptyString) {
      result = result.where((e) {
        if (e is String) {
          return e
              .trim()
              .isNotEmpty;
        }
        return true;
      });
    }

    final list = result.cast<R>().toList();

    return distinct ? list.toSet().toList() : list;
  }

  /// 分块处理
  /// [chunkSize] 分块大小
  List<List<T>> chunk(int chunkSize) {
    if (chunkSize <= 0) return [];
    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += chunkSize) {
      chunks.add(sublist(i, (i + chunkSize).clamp(0, length)));
    }
    return chunks;
  }

  /// 移除第一个满足条件的元素
  bool removeFirstWhere(bool Function(T) test) {
    final index = indexWhere(test);
    if (index != -1) {
      removeAt(index);
      return true;
    }
    return false;
  }

  /// 插入元素到指定位置（如果索引超出范围，添加到末尾）
  void insertSafe(int index, T element) {
    if (index < 0) {
      insert(0, element);
    } else if (index >= length) {
      add(element);
    } else {
      insert(index, element);
    }
  }

  /// 交换两个元素的位置
  void swap(int index1, int index2) {
    if (index1 < 0 || index1 >= length || index2 < 0 || index2 >= length) {
      return;
    }
    final temp = this[index1];
    this[index1] = this[index2];
    this[index2] = temp;
  }

  /// 获取满足条件的元素数量
  int count(bool Function(T) test) {
    return where(test).length;
  }

  /// 获取满足条件的第一个元素
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }

  /// 获取满足条件的最后一个元素
  T? lastWhereOrNull(bool Function(T) test) {
    try {
      return lastWhere(test);
    } catch (e) {
      return null;
    }
  }

  /// 获取满足条件的元素的索引
  int? indexWhereOrNull(bool Function(T) test) {
    final index = indexWhere(test);
    return index == -1 ? null : index;
  }

  /// 获取最后一个满足条件的元素的索引
  int? lastIndexWhereOrNull(bool Function(T) test) {
    final index = lastIndexWhere(test);
    return index == -1 ? null : index;
  }

  /// 检查索引是否有效
  bool isValidIndex(int index) => index >= 0 && index < length;

  /// 获取子列表（安全版本）
  List<T> sublistSafe(int start, [int? end]) {
    final safeStart = start.clamp(0, length);
    final safeEnd = (end ?? length).clamp(safeStart, length);
    return sublist(safeStart, safeEnd);
  }

  /// 添加元素（如果元素不为 null）
  void addIfNotNull(T? element) {
    if (element != null) add(element);
  }

  /// 添加所有元素（过滤 null 值）
  void addAllNotNull(Iterable<T?> elements) {
    addAll(elements.whereType<T>());
  }

  /// 在开头添加元素
  void prepend(T element) {
    insert(0, element);
  }

  /// 在开头添加多个元素
  void prependAll(Iterable<T> elements) {
    insertAll(0, elements);
  }

  /// 获取列表的中间元素
  T? get middle {
    if (isEmpty) return null;
    return this[length ~/ 2];
  }

  /// 获取列表的前半部分
  List<T> get firstHalf {
    if (isEmpty) return [];
    return sublist(0, length ~/ 2);
  }

  /// 获取列表的后半部分
  List<T> get secondHalf {
    if (isEmpty) return [];
    return sublist(length ~/ 2);
  }

  /// 检查列表是否包含重复元素
  bool get hasDuplicates {
    final seen = <T>{};
    for (final element in this) {
      if (!seen.add(element)) return true;
    }
    return false;
  }

  /// 获取重复的元素
  List<T> get duplicates {
    final seen = <T>{};
    final duplicates = <T>{};
    for (final element in this) {
      if (!seen.add(element)) {
        duplicates.add(element);
      }
    }
    return duplicates.toList();
  }

  /// 获取唯一元素（只出现一次的元素）
  List<T> get unique {
    final count = <T, int>{};
    for (final element in this) {
      count[element] = (count[element] ?? 0) + 1;
    }
    return where((element) => count[element] == 1).toList();
  }
}

extension ListExtensions2<T> on List<T>? {
  /// 检查列表是否为 null 或 空
  bool get isEmptyOrNull => this == null || this!.isEmpty;

  /// 检查列表是否不为 null 且 不为空
  bool get isNotEmptyOrNull => !isEmptyOrNull;
}

extension ListStringFilter on List<String?> {
  /// 过滤掉 null 和空字符串（去除前后空格后为空的也过滤）
  List<String> whereNotNullOrEmpty({bool ignoreWhitespaceOnly = true}) {
    return where((item) {
      if (item == null) return false;
      final trimmed = item.trim();
      if (ignoreWhitespaceOnly && trimmed.isEmpty) return false;
      return true;
    }).cast<String>().toList();
  }
}

/// 枚举帮助扩展类
extension EnumHelper<T extends Enum> on List<T> {
  T? fromEnumName(String? name, [T? defaultValue]) {
    final match = where((e) => e.name == name);
    return match.isNotEmpty ? match.first : defaultValue;
  }

  T fromEnumNameOr(String? name, T defaultValue) {
    final match = where((e) => e.name == name);
    return match.isNotEmpty ? match.first : defaultValue;
  }
}
