import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'migration.dart';

/// 数据库管理类
class DbManager {
  /// 创建应用级别数据表 sql
  static final _appTables = <String, String>{};

  /// 创建用户级别数据表 sql
  static final _userTables = <String, String>{};

  /// 应用级别数据库实例
  static Database? _appDb;

  /// 用户级别数据库管理
  static final Map<String, Database> _userDatabases = {};

  /// 数据库迁移
  static Migration? _migration;

  /// 注册应用级别数据表
  /// 应用初始化时调用
  static void registerAppTable(String name, String createSql) {
    _appTables[name] = createSql;
  }

  /// 注册用户级别数据表
  /// 应用初始化时调用
  static void registerUserTable(String name, String createSql) {
    _userTables[name] = createSql;
  }

  /// 注册数据库迁移
  static void registerMigration(Migration migration) {
    _migration = migration;
  }

  /// 用户登录 - 创建/打开用户数据库
  static Future<void> userLogin(String userId) async {
    if (_userDatabases.containsKey(userId)) {
      return;
    }

    _userDatabases[userId] = await _initUserDatabase(userId);
  }

  /// 用户退出 - 关闭用户数据库
  static Future<void> userLogout(String userId) async {
    if (_userDatabases.containsKey(userId)) {
      await _userDatabases[userId]!.close();
      _userDatabases.remove(userId);
    }
  }

  /// 获取应用级别数据库实例
  static Future<Database> get appDb async {
    if (_appDb != null) return _appDb!;

    String path = join(await getDatabasesPath(), 'app.db');

    _appDb = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        for (var sql in _appTables.values) {
          await db.execute(sql);
        }
      },
      onOpen: (db) {},
      onUpgrade: _migration,
    );

    return _appDb!;
  }

  /// 获取用户数据库实例
  static Future<Database> getUserDb(String userId) async {
    if (!_userDatabases.containsKey(userId)) {
      throw Exception(
          'User database not found. Please call userLogin($userId) first.');
    }
    return _userDatabases[userId]!;
  }

  /// 检查用户数据库是否存在
  static bool hasUserDb(String userId) {
    return _userDatabases.containsKey(userId);
  }

  /// 创建用户级别数据库名称
  static String _createUserDatabaseName(String userId) {
    return 'user_$userId.db';
  }

  /// 初始化用户数据库
  static Future<Database> _initUserDatabase(String userId) async {
    String path = join(
      await getDatabasesPath(),
      _createUserDatabaseName(userId),
    );

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        for (var sql in _userTables.values) {
          await db.execute(sql);
        }
      },
      onOpen: (db) {},
      onUpgrade: _migration,
    );

    return db;
  }

  /// 获取所有已登录用户的ID列表
  static List<String> get loggedInUserIds => _userDatabases.keys.toList();

  /// 删除用户数据库（完全删除文件）
  static Future<void> deleteUserDatabase(String userId) async {
    // 先关闭数据库连接
    if (_userDatabases.containsKey(userId)) {
      await _userDatabases[userId]!.close();
      _userDatabases.remove(userId);
    }

    // 删除数据库文件
    String path = join(
      await getDatabasesPath(),
      _createUserDatabaseName(userId),
    );
    await deleteDatabase(path);
  }

  /// 关闭应用级别数据库
  static Future<void> closeAppDb() async {
    await _appDb?.close();
    _appDb = null;
  }

  /// 关闭用户级数据库
  static Future<void> closeUserDb() async {
    // 关闭所有用户数据库
    for (final db in _userDatabases.values) {
      await db.close();
    }
    _userDatabases.clear();
  }
}
