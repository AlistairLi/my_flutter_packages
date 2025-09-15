import 'package:sqflite/sqflite.dart';

import '../model/db_model.dart';
import 'db_manager.dart';

abstract class BaseDao<T extends DbModel> {
  String get tableName;

  T fromMap(Map<String, dynamic> map);

  // 默认使用应用级别数据库
  Future<Database> get _db async => await DbManager.appDb;

  // 获取用户数据库的DAO实例
  BaseDao<T> forUser(String userId) {
    return _UserSpecificDao<T>(this, userId);
  }

  // 插入一条数据
  Future<int> insert(T model) async {
    return (await _db).insert(tableName, model.toMap());
  }

  // 插入或替换（用于主键冲突）
  Future<int> insertOrReplace(T model) async {
    return (await _db).insert(
      tableName,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 批量插入（非事务）
  Future<void> insertBatch(List<T> models) async {
    final db = await _db;
    final batch = db.batch();
    for (var model in models) {
      batch.insert(tableName, model.toMap());
    }
    await batch.commit(noResult: true);
  }

  // 批量插入（事务）
  Future<void> insertBatchInTransaction(List<T> models) async {
    final db = await _db;
    await db.transaction((txn) async {
      for (var model in models) {
        await txn.insert(tableName, model.toMap());
      }
    });
  }

  // 更新
  Future<int> update(T model, String where, List<Object?> args) async {
    return (await _db).update(
      tableName,
      model.toMap(),
      where: where,
      whereArgs: args,
    );
  }

  /// 根据指定的字段更新部分字段
  Future<int> updateFieldsByField(
      String fieldName,
      dynamic fieldValue,
      Map<String, dynamic> updateFields
      ) async {
    return (await _db).update(
      tableName,
      updateFields,
      where: '$fieldName = ?',
      whereArgs: [fieldValue],
    );
  }

  // 删除
  Future<int> delete(String where, List<Object?> args) async {
    return (await _db).delete(tableName, where: where, whereArgs: args);
  }

  // 根据某个字段删除记录
  Future<int> deleteByField(String fieldName, dynamic fieldValue) async {
    return (await _db).delete(
      tableName,
      where: '$fieldName = ?',
      whereArgs: [fieldValue],
    );
  }

  // 删除所有数据
  Future<int> deleteAll() async {
    return (await _db).delete(tableName);
  }

  // 查询所有
  Future<List<T>> queryAll() async {
    final list = await (await _db).query(tableName);
    return list.map(fromMap).toList();
  }

  // 条件查询
  Future<List<T>> queryWhere(String where, List<Object?> args) async {
    final list =
        await (await _db).query(tableName, where: where, whereArgs: args);
    return list.map(fromMap).toList();
  }

  // 分页查询
  Future<List<T>> queryPaged({
    int offset = 0,
    int limit = 20,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final list = await (await _db).query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return list.map(fromMap).toList();
  }

  // 统计数量
  Future<int> count({String? where, List<Object?>? whereArgs}) async {
    final result = await (await _db).rawQuery(
      'SELECT COUNT(*) FROM $tableName${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

/// 用户特定的DAO实现
class _UserSpecificDao<T extends DbModel> extends BaseDao<T> {
  final BaseDao<T> _originalDao;
  final String _userId;

  _UserSpecificDao(this._originalDao, this._userId);

  @override
  String get tableName => _originalDao.tableName;

  @override
  T fromMap(Map<String, dynamic> map) => _originalDao.fromMap(map);

  @override
  Future<Database> get _db async => await DbManager.getUserDb(_userId);
}
