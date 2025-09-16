import 'package:hive_easy/hive_easy.dart';

void main() async {
  // ***** 初始化 *****

  // When the application starts, initialize the Hive storage.
  await HiveUtil.init();

  // After successful login, set the user's ID to use the user-level storage
  HiveUtil.setCurrentUser("1238750892171");

  // When logging out, the user-level storage is closed (the user's local data will not be cleared)
  HiveUtil.setCurrentUser(null);

  // ***** 使用 *****

  // 应用级别数据存储
  // Map存取
  var appObject = HiveUtil.getAppObject('appKey1');
  HiveUtil.putAppObject('appKey1', {'value1': "value"});
  // 字符串存取
  var appStr = HiveUtil.getAppString('appKey2');
  HiveUtil.putAppString('appKey2', 'value');

  // 用户级别数据存储
  // Map存取
  var userObject = HiveUtil.getUserObject('userKey1');
  HiveUtil.putUserObject('userKey1', {'value1': "value"});
  // 字符串存取
  var userStr = HiveUtil.getUserString('userKey2');
  HiveUtil.putUserString('userKey2', 'value');
}
