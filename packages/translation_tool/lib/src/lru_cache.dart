import 'dart:collection';

/// 缓存类，使用LRU策略管理缓存条目。
///
/// 支持泛型键值对存储，适用于需要快速查找、限制容量的缓存场景。
class LruCache<K, V> {
  LruCache(this.capacity) : assert(capacity > 0, 'Capacity must be positive');

  /// 内部缓存容器，使用[LinkedHashMap]保证插入顺序以支持LRU策略。
  final LinkedHashMap<K, V> _cacheMap = LinkedHashMap<K, V>();

  /// 缓存的最大容量，超出此数量将淘汰最近最少使用的条目。
  int capacity;

  /// 当前缓存中的条目数量
  int get length => _cacheMap.length;

  /// 缓存是否为空
  bool get isEmpty => _cacheMap.isEmpty;

  /// 缓存是否已满
  bool get isFull => _cacheMap.length >= capacity;

  /// 获取所有键的集合
  Iterable<K> get keys => _cacheMap.keys;

  /// 获取所有值的集合
  Iterable<V> get values => _cacheMap.values;

  /// 获取所有键值对的集合
  Iterable<MapEntry<K, V>> get entries => _cacheMap.entries;

  /// 获取与[key]关联的值，如果存在的话。
  ///
  /// 如果命中缓存，则会重新插入该条目以更新其使用顺序（LRU行为）。
  V? get(K key) {
    final value = _cacheMap.remove(key);
    if (value != null) {
      _cacheMap[key] = value; // 重新插入到末尾，更新访问顺序
    }
    return value;
  }

  /// 将给定的[key]和[value]放入缓存中。
  ///
  /// - 如果[key]已存在，则先移除旧条目；
  /// - 如果缓存已满，则移除最近最少使用的条目；
  /// - 最后插入新条目。
  void set(K key, V value) {
    if (_cacheMap.containsKey(key)) {
      _cacheMap.remove(key);
    } else if (_cacheMap.length >= capacity) {
      final oldKey = _cacheMap.keys.first;
      _cacheMap.remove(oldKey);
    }
    _cacheMap[key] = value;
  }

  bool containsKey(K key) {
    return _cacheMap.containsKey(key);
  }

  V? delete(K key) {
    return _cacheMap.remove(key);
  }

  /// 清空所有缓存条目
  void clear() {
    _cacheMap.clear();
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    return {
      'capacity': capacity,
      'size': length,
      'usage': length / capacity,
      'isEmpty': isEmpty,
      'isFull': isFull,
    };
  }
}
