import 'package:litebase/litebase.dart';

// 示例数据模型
class UserMessage extends DbModel {
  final int? id;
  final String content;
  final int timestamp;

  UserMessage({
    this.id,
    required this.content,
    required this.timestamp,
  });

  UserMessage.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        content = map['content'],
        timestamp = map['timestamp'];

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp,
    };
  }
}

// 示例DAO
class UserMessageDao extends BaseDao<UserMessage> {
  @override
  String get tableName => 'user_messages';

  @override
  UserMessage fromMap(Map<String, dynamic> map) => UserMessage.fromMap(map);
}

void main() async {
  // 配置数据库
  DbManager.registerMigration((db, oldVersion, newVersion) async {
    print('数据库从版本 $oldVersion 升级到 $newVersion');
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE user_messages ADD COLUMN user_id TEXT');
    }
  });

  // 注册表结构
  DbManager.registerUserTable('user_messages', '''
    CREATE TABLE user_messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      content TEXT NOT NULL,
      timestamp INTEGER NOT NULL
    )
  ''');

  DbManager.registerAppTable('app_settings', '''
    CREATE TABLE app_settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT UNIQUE NOT NULL,
      value TEXT NOT NULL
    )
  ''');

  // 应用级别数据库操作
  print('=== 应用级别数据库操作 ===');

  // 在应用级别插入设置
  final appDb = await DbManager.appDb;
  await appDb.insert('app_settings', {
    'key': 'theme',
    'value': 'dark',
  });

  var appSettings = await appDb.query('app_settings');
  print('应用设置: $appSettings');

  // 用户级别数据库操作
  print('\n=== 用户级别数据库操作 ===');

  // 用户1登录
  await DbManager.userLogin('user_001');
  print('用户1登录，已登录用户: ${DbManager.loggedInUserIds}');

  // 使用DAO操作用户1的数据
  final userMessageDao = UserMessageDao();
  final user1Dao = userMessageDao.forUser('user_001');

  await user1Dao.insert(UserMessage(
    content: '用户1的消息1',
    timestamp: DateTime.now().millisecondsSinceEpoch,
  ));

  await user1Dao.insert(UserMessage(
    content: '用户1的消息2',
    timestamp: DateTime.now().millisecondsSinceEpoch,
  ));

  List<UserMessage> user1Messages = await user1Dao.queryAll();
  print('用户1的消息: ${user1Messages.map((m) => m.content).toList()}');

  // 用户2登录
  await DbManager.userLogin('user_002');
  print('用户2登录，已登录用户: ${DbManager.loggedInUserIds}');

  // 用户2的数据
  final user2Dao = userMessageDao.forUser('user_002');

  await user2Dao.insert(UserMessage(
    content: '用户2的消息1',
    timestamp: DateTime.now().millisecondsSinceEpoch,
  ));

  await user2Dao.insert(UserMessage(
    content: '用户2的消息2',
    timestamp: DateTime.now().millisecondsSinceEpoch,
  ));

  List<UserMessage> user2Messages = await user2Dao.queryAll();
  print('用户2的消息: ${user2Messages.map((m) => m.content).toList()}');

  // 同时查询用户1的数据（用户1数据库仍然存在）
  List<UserMessage> user1MessagesAgain = await user1Dao.queryAll();
  print('用户1的消息（重新查询）: ${user1MessagesAgain.map((m) => m.content).toList()}');

  // 应用级别数据库仍然可用
  var appSettingsAgain = await appDb.query('app_settings');
  print('应用设置（重新查询）: $appSettingsAgain');

  // 检查用户数据库状态
  print('用户1数据库存在: ${DbManager.hasUserDb('user_001')}');
  print('用户2数据库存在: ${DbManager.hasUserDb('user_002')}');
  print('用户3数据库存在: ${DbManager.hasUserDb('user_003')}');

  // 批量操作示例
  print('\n=== 批量操作示例 ===');

  // 用户3登录
  await DbManager.userLogin('user_003');
  final user3Dao = userMessageDao.forUser('user_003');

  List<UserMessage> batchMessages = [
    UserMessage(
        content: '批量消息1', timestamp: DateTime.now().millisecondsSinceEpoch),
    UserMessage(
        content: '批量消息2', timestamp: DateTime.now().millisecondsSinceEpoch),
    UserMessage(
        content: '批量消息3', timestamp: DateTime.now().millisecondsSinceEpoch),
  ];

  await user3Dao.insertBatchInTransaction(batchMessages);
  print('批量插入完成');

  List<UserMessage> allMessages = await user3Dao.queryAll();
  print('用户3所有消息: ${allMessages.map((m) => m.content).toList()}');

  // 分页查询示例
  print('\n=== 分页查询示例 ===');

  List<UserMessage> pagedMessages = await user3Dao.queryPaged(
    offset: 0,
    limit: 2,
    orderBy: 'timestamp DESC',
  );
  print('用户3分页消息: ${pagedMessages.map((m) => m.content).toList()}');

  // 统计数量
  int count = await user3Dao.count();
  print('用户3消息总数: $count');

  // 用户退出
  print('\n=== 用户退出 ===');

  await DbManager.userLogout('user_001');
  print('用户1退出，已登录用户: ${DbManager.loggedInUserIds}');
  print('用户1数据库存在: ${DbManager.hasUserDb('user_001')}');

  // 尝试访问已退出用户的数据库会抛出异常
  try {
    await user1Dao.queryAll();
  } catch (e) {
    print('访问已退出用户数据库异常: $e');
  }

  // 其他用户数据库仍然可用
  List<UserMessage> user2MessagesAgain = await user2Dao.queryAll();
  print('用户2的消息（用户1退出后）: ${user2MessagesAgain.map((m) => m.content).toList()}');

  // 删除用户数据库
  await DbManager.deleteUserDatabase('user_002');
  print('删除用户2数据库后，已登录用户: ${DbManager.loggedInUserIds}');

  // 应用级别数据库仍然可用
  var finalAppSettings = await appDb.query('app_settings');
  print('应用设置（最终）: $finalAppSettings');
}
