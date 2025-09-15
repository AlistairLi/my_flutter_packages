import 'package:litebase/src/core/base_dao.dart';
import 'package:litebase/src/core/db_manager.dart';
import 'package:litebase/src/model/db_model.dart';

class User extends DbModel {
  final int? id;
  final String name;

  User({this.id, required this.name});

  @override
  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  static User fromMap(Map<String, dynamic> map) => User(
        id: map['id'],
        name: map['name'],
      );
}

class UserDao extends BaseDao<User> {
  @override
  String get tableName => 'users';

  @override
  User fromMap(Map<String, dynamic> map) => User.fromMap(map);
}

// 使用前初始化
Future<void> initDb() async {
  DbManager.registerAppTable(
    'users',
    'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)',
  );
}

void main() async {
  final userDao = UserDao();

  // 批量插入
  await userDao.insertBatch([
    User(name: 'Alice'),
    User(name: 'Bob'),
    User(name: 'Charlie'),
  ]);

  // 分页查询第2页，每页 10 条
  final page2Users = await userDao.queryPaged(offset: 10, limit: 10);

  // 查询 name 包含 A 的用户
  final filtered = await userDao.queryWhere('name LIKE ?', ['%A%']);

  // 查询总人数
  final total = await userDao.count();
}
