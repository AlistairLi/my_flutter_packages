import 'dart:convert';

import 'package:http_util/src/core/dio_client.dart';
import 'package:http_util/src/multi/model_factory.dart';

import 'app_apis.dart';
import 'app_config.dart';
import 'app_http_client.dart';
import 'model/api_response.dart';
import 'model/coins_model.dart';
import 'model/oauth_model.dart';
import 'model/user_model.dart';

DioClient client = AppHttpClient().client;

void main() async {
  registerBasicTypes();
  registerFactory<OauthModel>((json) => OauthModel.fromJson(json));
  registerFactory<UserModel>((json) => UserModel.fromJson(json));
  registerFactory<CoinsModel>((json) => CoinsModel.fromJson(json));

  // 登陆
  final loginResponse = await client.post<OauthModel, ApiResponse<OauthModel>>(
    AppApis.apisLoginUrl,
    data: {
      "oauthType": 4,
      "token": "d95140f1b6b1d8fa",
    },
    fromJsonT: (data) {
      var jsonStr = jsonEncode(data);
      return OauthModel.fromJson(data);
    },
    isShowToast: true,
    isShowLoading: true,
  );
  AppConfig.requestToken = loginResponse.data?.token ?? "";
  print("userId: ${loginResponse.data?.userInfo?.userId}\n"
      "token: ${loginResponse.data?.token}\n\n");

  UserModel? userInfo = loginResponse.data?.userInfo;
  if (userInfo == null) return;
  // 测试多个并发请求共享同一个 Loading
  getUserInfo(userInfo);
  getUserCoins(userInfo);
  bindCode();
}

/// 获取用户信息
void getUserInfo(UserModel userInfo) async {
  final userInfoResponse = await client.get<UserModel, ApiResponse<UserModel>>(
    AppApis.apisGetUserInfoUrl,
    queryParameters: {
      "userId": userInfo.userId,
    },
    fromJsonT: (data) {
      var jsonStr = jsonEncode(data);
      return UserModel.fromJson(data);
    },
    isShowToast: true,
    isShowLoading: true,
  );
  print("userName: ${userInfoResponse.data?.nickname}\n"
      "userId: ${userInfoResponse.data?.userId}");
}

/// 获取用户金币数
void getUserCoins(UserModel userInfo) async {
  final userInfoResponse =
      await client.get<CoinsModel, ApiResponse<CoinsModel>>(
    AppApis.apisgetUserCoinsUrl,
    queryParameters: {
      "userId": userInfo.userId,
    },
    fromJsonT: (data) {
      var jsonStr = jsonEncode(data);
      return CoinsModel.fromJson(data);
    },
    isShowToast: true,
    isShowLoading: true,
  );
  print("coins: ${userInfoResponse.data?.availableCoins}");
}

/// 绑定邀请码
void bindCode() async {
  final bindResponse = await client.post<bool, ApiResponse<bool>>(
    AppApis.apisbindInviteCode,
    data: {
      "inviteCode": "qogaql",
    },
    isShowToast: true,
    isShowLoading: true,
  );
  print("result: ${bindResponse.data}");
}
