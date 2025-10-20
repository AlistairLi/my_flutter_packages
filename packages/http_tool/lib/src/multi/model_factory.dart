typedef JsonFactory<T> = T Function(dynamic json);

final Map<Type, JsonFactory> _factories = {};

void registerFactory<T>(JsonFactory<T> factory) {
  _factories[T] = factory;
}

T fromJsonByType<T>(dynamic json) {
  final factory = _factories[T];
  if (factory == null) {
    throw Exception('No factory registered for type $T');
  }
  return factory(json);
}

// 注册基本类型
void registerBasicTypes() {
  registerFactory<int>((json) => json as int);
  registerFactory<bool>((json) => json as bool);
  registerFactory<double>((json) => json as double);
  registerFactory<String>((json) => json as String);
  registerFactory<dynamic>((json) => json as dynamic);
  registerFactory<List>((json) => json as List);
  registerFactory<List<String>>((json) {
    return (json as List).map((e) => e.toString()).toList();
  });
  registerFactory<Map>((json) => json as Map);
  registerFactory<Map<String, dynamic>>(
      (json) => (json is Map<String, dynamic>) ? json : <String, dynamic>{});
}
