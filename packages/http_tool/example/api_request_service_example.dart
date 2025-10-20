import 'api_response_example.dart';
import 'http_client_example.dart';
import 'model/user_model_example.dart';

/// API 请求
class APIRequestServiceExample {
  APIRequestServiceExample._();

  /// 登录
  static Future<UserModelExample?> login() async {
    var response =
        await dioClient.post<UserModelExample, ApiResponseExample<UserModelExample>>(
      '/login',
      data: {"key": "value"},
    );
    return response?.data;
  }
}
