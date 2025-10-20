import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_tool/src/controller/request_loading_controller.dart';
import 'package:http_tool/src/core/dio_client.dart';
import 'package:http_tool/src/core/network_config.dart';
import 'package:http_tool/src/multi/dio_factory.dart';
import 'package:http_tool/src/multi/model_factory.dart';

import 'api_response_example.dart';

DioClient dioClient = AppHttpClientExample().client;

/// 业务层的 AppHttpClient
class AppHttpClientExample {
  late DioClient _client;

  DioClient get client => _client;

  AppHttpClientExample() {
    _client = DioFactory.getClient(
      'user-api',
      NetworkConfig(
        baseUrl: "https://www.xxx.com",
        headersBuilder: () {
          return {
            "header1": "value1",
            "header2": "value2",
          };
        },
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
          return ApiResponseExample<T>.fromJson(jsonData, fromJson);
        },
        responseWrapper2: <T>(rawData) {
          Map<String, dynamic> jsonData = {};
          // response.data 的数据处理，可以在这里处理，也可以放在拦截器中。
          if (rawData is String) {
            jsonData = jsonDecode(rawData);
          } else if (rawData is Map<String, dynamic>) {
            jsonData = rawData;
          }
          return ApiResponseExample<T>.fromJson(jsonData, fromJsonByType<T>);
        },
        onDioException: (error, stack, isShowToast) {
          String message = '';
          if (error.type == DioExceptionType.connectionError) {
            message =
                'Network connection is unavailable, Please check your network settings';
          } else if (error.type == DioExceptionType.unknown) {
            message = 'Network connection failed, please try again later';
          } else if (error.type == DioExceptionType.connectionTimeout) {
            message = 'Network connection timeout';
          } else if (error.type == DioExceptionType.receiveTimeout) {
            message = 'Network reception timeout';
          } else if (error.type == DioExceptionType.sendTimeout) {
            message = 'Network transmission timeout';
          } else if (error.type == DioExceptionType.badCertificate ||
              error.type == DioExceptionType.badResponse) {
            message = 'Network transmission timeout';
          } else if (error.type == DioExceptionType.cancel) {
            // if (kDebugMode) {
            //   message = 'Network request cancelled';
            // }
          }
          if (message.isNotEmpty) {
            // toast(message);
          }
        },
        onException: (e, options, path, isShowToast) {
          // if (kDebugMode) {
          //   toast(e.toString());
          // }
          print('onException(), path: $path, ${e.toString()}');
        },
        businessErrorHandler: <R>(response, isShowToast, path) {
          if (response is ApiResponseExample) {
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
