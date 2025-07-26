import 'package:http_util/src/core/dio_client.dart';

import 'app_apis.dart';
import 'app_http_client.dart';
import 'model/api_response.dart';
import 'model/oauth_model.dart';

/// 后端接口加密example

void main() async {
  DioClient client = AppHttpClient().client;

  // 获取appConfig
  final loginResponse = await client.post<Object, ApiResponse<Object>>(
    AppApis.apisGetAppConfigUrlPostV2,
    data: {"ver": "0"},
    fromJsonT: (data) {
      return Object();
    },
    isShowToast: true,
    isShowLoading: true,
  );
}
