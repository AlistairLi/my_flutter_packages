/// Map 的扩展方法
extension MapExtensions<K, V> on Map<K, V> {
  /// 安全获取值，如果键不存在返回 null
  V? getOrNull(K key) => this[key];

  /// 安全获取值，如果键不存在返回默认值
  V getOrDefault(K key, V defaultValue) => this[key] ?? defaultValue;

  /// 获取值，如果键不存在则计算并存储默认值
  V getOrPut(K key, V Function() defaultValue) {
    if (containsKey(key)) {
      return this[key]!;
    }
    final value = defaultValue();
    this[key] = value;
    return value;
  }

  /// 获取值，如果键不存在则计算并存储默认值（异步）
  Future<V> getOrPutAsync(K key, Future<V> Function() defaultValue) async {
    if (containsKey(key)) {
      return this[key]!;
    }
    final value = await defaultValue();
    this[key] = value;
    return value;
  }

  /// 移除满足条件的键值对
  void removeWhere(bool Function(K key, V value) test) {
    final keysToRemove = <K>[];
    forEach((key, value) {
      if (test(key, value)) {
        keysToRemove.add(key);
      }
    });
    for (final key in keysToRemove) {
      remove(key);
    }
  }

  /// 获取所有键
  List<K> get keysList => keys.toList();

  /// 获取所有值
  List<V> get valuesList => values.toList();

  /// 获取键值对列表
  List<MapEntry<K, V>> get entriesList => entries.toList();

  /// 反转键值对
  Map<V, K> get reversed {
    final result = <V, K>{};
    forEach((key, value) => result[value] = key);
    return result;
  }

  /// 根据值过滤
  Map<K, V> filterValues(bool Function(V value) test) {
    return Map.fromEntries(
      entries.where((entry) => test(entry.value)),
    );
  }

  /// 根据键过滤
  Map<K, V> filterKeys(bool Function(K key) test) {
    return Map.fromEntries(
      entries.where((entry) => test(entry.key)),
    );
  }

  /// 转换值
  Map<K, R> mapValues<R>(R Function(V value) transform) {
    return Map.fromEntries(
      entries.map((entry) => MapEntry(entry.key, transform(entry.value))),
    );
  }

  /// 转换键
  Map<R, V> mapKeys<R>(R Function(K key) transform) {
    return Map.fromEntries(
      entries.map((entry) => MapEntry(transform(entry.key), entry.value)),
    );
  }

  /// 合并另一个 Map
  Map<K, V> merge(Map<K, V> other) {
    final result = Map<K, V>.from(this);
    result.addAll(other);
    return result;
  }

  /// 深度合并（如果值是 Map 类型）
  Map<K, dynamic> deepMerge(Map<K, dynamic> other) {
    final result = Map<K, dynamic>.from(this);
    other.forEach((key, value) {
      if (result.containsKey(key) && result[key] is Map && value is Map) {
        result[key] = (result[key] as Map).deepMerge(value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  /// 获取第一个键值对
  MapEntry<K, V>? get firstEntry => isEmpty ? null : entries.first;

  /// 获取最后一个键值对
  MapEntry<K, V>? get lastEntry => isEmpty ? null : entries.last;

  /// 检查是否包含指定的值
  bool containsValue(V value) => values.contains(value);

  /// 获取所有键的集合
  Set<K> get keysSet => keys.toSet();

  /// 获取所有值的集合
  Set<V> get valuesSet => values.toSet();

  /// 根据值排序
  List<MapEntry<K, V>> sortedByValue([int Function(V a, V b)? compare]) {
    final entries = this.entries.toList();
    entries.sort((a, b) =>
        compare?.call(a.value, b.value) ??
        (a.value as Comparable).compareTo(b.value as Comparable));
    return entries;
  }

  /// 根据键排序
  List<MapEntry<K, V>> sortedByKey([int Function(K a, K b)? compare]) {
    final entries = this.entries.toList();
    entries.sort((a, b) =>
        compare?.call(a.key, b.key) ??
        (a.key as Comparable).compareTo(b.key as Comparable));
    return entries;
  }

  /// 获取最小值对应的键值对
  MapEntry<K, V>? get minByValue {
    if (isEmpty) return null;
    return entries.reduce((a, b) =>
        (a.value as Comparable).compareTo(b.value as Comparable) <= 0 ? a : b);
  }

  /// 获取最大值对应的键值对
  MapEntry<K, V>? get maxByValue {
    if (isEmpty) return null;
    return entries.reduce((a, b) =>
        (a.value as Comparable).compareTo(b.value as Comparable) >= 0 ? a : b);
  }

  /// 计算值的总和（如果值是数字）
  num sumValues() {
    return values.fold<num>(0, (sum, value) => sum + (value as num));
  }

  /// 计算值的平均值（如果值是数字）
  double averageValues() {
    if (isEmpty) return 0.0;
    return sumValues() / length;
  }

  /// 分组（根据值分组）
  Map<V, List<K>> groupByValue() {
    final result = <V, List<K>>{};
    forEach((key, value) {
      result.putIfAbsent(value, () => []).add(key);
    });
    return result;
  }

  /// 检查是否所有值都满足条件
  bool allValues(bool Function(V value) test) {
    return values.every(test);
  }

  /// 检查是否至少有一个值满足条件
  bool anyValue(bool Function(V value) test) {
    return values.any(test);
  }

  /// 检查是否所有键都满足条件
  bool allKeys(bool Function(K key) test) {
    return keys.every(test);
  }

  /// 检查是否至少有一个键满足条件
  bool anyKey(bool Function(K key) test) {
    return keys.any(test);
  }
}

extension MapExtensions2<K, V> on Map<K, V>? {
  /// 检查是否为 null 或 空
  bool get isEmptyOrNull => this == null || this!.isEmpty;

  /// 检查是否不为 null 且 不为空
  bool get isNotEmptyOrNull => !isEmptyOrNull;
}
