import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_util/src/controller/request_loading_controller.dart';
import 'package:http_util/src/core/dio_client.dart';
import 'package:http_util/src/core/network_config.dart';
import 'package:http_util/src/multi/dio_factory.dart';
import 'package:http_util/src/multi/model_factory.dart';

import 'app_config.dart';
import 'model/api_response.dart';

/// 业务层的 AppHttpClient
class AppHttpClient {
  late DioClient _client;

  DioClient get client => _client;

  AppHttpClient() {
    _client = DioFactory.getClient(
      'user-api',
      NetworkConfig(
        baseUrl: AppConfig.baseUrl,
        headersBuilder: () => AppConfig.getHeaders(),
        enableLogging: false,
        responseWrapper: <T>(rawData, fromJson) {
          Map<String, dynamic> jsonData = {};
          // response.data 的数据处理，可以在这里处理，也可以放在拦截器中。
          if (rawData is String) {
            jsonData = jsonDecode(rawData);
          } else if (rawData is Map<String, dynamic>) {
            jsonData = rawData;
          }
          // else {
          //   throw Exception('Unexpected response data format');
          // }
          return ApiResponse<T>.fromJson(jsonData, fromJson);
        },
        responseWrapper2: <T>(rawData) {
          Map<String, dynamic> jsonData = {};
          // response.data 的数据处理，可以在这里处理，也可以放在拦截器中。
          if (rawData is String) {
            jsonData = jsonDecode(rawData);
          } else if (rawData is Map<String, dynamic>) {
            jsonData = rawData;
          }
          return ApiResponse<T>.fromJson(jsonData, fromJsonByType<T>);
        },
        onException: (error, stack) {
          if (error is DioException) {
            var statusCode = error.response?.statusCode;
            if (statusCode == null) {
              if (error.type != DioExceptionType.cancel) {
                // 显示 toast
                print("Show toast, message: ${error.message}");
              }
            } else {
              switch (statusCode) {
                case 404:
                  // 显示 toast
                  print(
                      "Show toast, statusCode: $statusCode, message: ${error.message}");
                  break;
              }
            }
          } else {
            // 显示 toast
            print("Show toast, message: ${error.toString()}");
          }
        },
        businessErrorHandler: <R>(response, isShowToast, path) {
          if (response is ApiResponse) {
            if (isShowToast &&
                !response.isSuccess &&
                response.message.isNotEmpty == true) {
              // 显示 toast
              print("Show toast, message: ${response.message}, path: $path");
            }
          }
        },
        excludeLogPaths: [
          "user/getUserCoins",
          RegExp(r'/user/register'),
        ],
        loadingController: RequestLoadingController(
          show: () {
            // 显示 loading
            print("Show loading");
          },
          dismiss: () {
            // 隐藏 loading
            print("Hide loading");
          },
        ),
      ),
    );
  }
}
