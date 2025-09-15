import 'dart:io';

import 'package:ali_oss_upload/src/oss_config.dart';
import 'package:ali_oss_upload/src/oss_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// OSS上传服务
class OssUploadService {
  OssUploadService._();

  static final tag = 'OssUploadService';

  /// 上传文件到OSS
  ///
  /// [filePath] 本地文件路径
  /// [ossAuth] OSS凭证信息
  /// [fileType] 文件类型（如：avatar, media, chat等）
  /// [config] 上传配置
  ///
  /// 返回上传结果，失败返回null
  static Future<OssResult?> uploadFile({
    required String filePath,
    required OssAuth ossAuth,
    String? fileType,
    OssUploadConfig? config,
  }) async {
    try {
      // 验证OSS凭证信息
      if (!_validateOssAuth(ossAuth)) {
        _log('The OSS certificate information is incomplete');
        return null;
      }

      // 上传到OSS
      return await _doUpload(
        filePath: filePath,
        ossAuth: ossAuth,
        fileType: fileType,
      );
    } catch (e) {
      _log('OSS upload anomaly: $e');
      return null;
    }
  }

  /// 验证OSS数据
  static bool _validateOssAuth(OssAuth ossAuth) {
    return _checkString(ossAuth.host) &&
        _checkString(ossAuth.dir) &&
        _checkString(ossAuth.policy) &&
        _checkString(ossAuth.callback) &&
        _checkString(ossAuth.signature) &&
        _checkString(ossAuth.accessKeyId);
  }

  /// 执行上传OSS
  static Future<OssResult?> _doUpload({
    required String filePath,
    required OssAuth ossAuth,
    String? fileType,
    OssUploadConfig? uploadConfig,
  }) async {
    try {
      var file = File.fromUri(Uri.parse(filePath));
      if (!await file.exists()) {
        _log('file does not exist: $filePath');
        return null;
      }

      String fileName = file.path.split('/').last;
      var multipartFile = await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      );
      final formData = FormData.fromMap({
        'key': _generateFileName(
          ossAuth.dir ?? "",
          filePath,
          fileType: fileType,
        ),
        'file': multipartFile,
        'policy': ossAuth.policy,
        'callback': ossAuth.callback,
        'signature': ossAuth.signature,
        'ossaccessKeyId': ossAuth.accessKeyId,
      });
      String domain = ossAuth.host ?? "";

      var config = uploadConfig ?? OssUploadConfig();
      Dio dio = Dio(BaseOptions(
        sendTimeout: config.sendTimeout,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
      ));
      var response = await dio.post(domain, data: formData);
      return OssResult.fromJson(response.data['data']);
    } catch (e) {
      _log('OSS upload failed: $e');
      return null;
    }
  }

  /// 生成文件名
  static String _generateFileName(
    String dir,
    String filePath, {
    String? fileType,
  }) {
    DateTime timeNow = DateTime.now();
    String formatName = filePath.split('.').last;
    int imageTimeName = timeNow.millisecondsSinceEpoch +
        (timeNow.microsecondsSinceEpoch ~/ 2000000);
    String name = '$imageTimeName.$formatName';
    return '$dir/$name';
  }

  static bool _checkString(String? str) {
    return str != null && str.trim().isNotEmpty;
  }

  static void _log(String msg) {
    if (kDebugMode) {
      print('[$tag] $msg');
    }
  }
}
