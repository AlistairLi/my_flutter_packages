import 'package:http_tool/src/multi/model_factory.dart';

import 'api_request_service_example.dart';
import 'model/user_model_example.dart';

void main() async {
  // 注册基础类型
  registerBasicTypes();
  // 注册模型解析
  registerFactory<UserModelExample>((json) => UserModelExample.fromJson(json));

  // 登陆
  var userModel = await APIRequestServiceExample.login();
}
