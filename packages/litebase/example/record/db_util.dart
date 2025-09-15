import 'package:litebase/litebase.dart';

import 'record_model.dart';

/// 数据库工具类
class DbUtil {
  static const String recordTableName = "record";

  static final Map<String, BaseDao> _daoList = {};

  /// 注册表结构
  /// 调用时机
  ///   - 应用启动时调用，异步执行
  static void registerTable() {
    // 注册记录表结构
    DbManager.registerUserTable(
      recordTableName,
      '''CREATE TABLE $recordTableName (id INTEGER PRIMARY KEY autoincrement,
            userId String, 
            nickname String,
            avatar String,
            createTimestamp integer,
            updateTimestamp integer
            )''',
    );
  }

  /// 用户登录
  /// 调用时机
  ///   - 用户登录成功后调用，同步执行
  ///   - 免登录时调用，同步执行
  static Future<void> onUserLogin(String? userId) async {
    if (userId == null || userId.isEmpty) return;
    await DbManager.userLogin(userId);
    _daoList[recordTableName] = RecordDao().forUser(userId);
  }

  /// 用户退出
  static Future<void> onUserLogout(String? userId) async {
    if (userId == null || userId.isEmpty) return;
    await DbManager.userLogout(userId);
    _daoList.clear();
  }

  /// 用户删除
  static Future<void> onUserDelete(String? userId) async {
    if (userId == null || userId.isEmpty) return;
    await DbManager.deleteUserDatabase(userId);
  }

  /// 记录的 DAO
  /// 注意 实际返回的是 _UserSpecificDao，所以要声明为 BaseDao<RecordModel>
  static BaseDao<RecordModel>? get recordDao {
    return _daoList[recordTableName] as BaseDao<RecordModel>?;
  }
}

/// 记录的 DAO
class RecordDao extends BaseDao<RecordModel> {
  @override
  String get tableName => DbUtil.recordTableName;

  @override
  RecordModel fromMap(Map<String, dynamic> map) => RecordModel.fromJson(map);
}
