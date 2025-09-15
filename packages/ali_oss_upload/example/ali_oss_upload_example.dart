import 'package:ali_oss_upload/ali_oss_upload.dart';

void main() async {
  var localPath = 'xxx/xxx/image.png';

  // 从项目的服务器获取OSS凭证信息
  Map<String, dynamic>? ossAuthMap;
  ossAuthMap = await Future.delayed(Duration(milliseconds: 500));
  if (ossAuthMap == null || ossAuthMap.isEmpty) return null;
  var ossAuth = OssAuth.fromJson(ossAuthMap);

  // 上传文件到oss
  OssResult? ossResult = await OssUploadService.uploadFile(
    filePath: localPath,
    ossAuth: ossAuth,
  );
  if (ossResult == null) return null;

  // 上传文件的OSS路径到项目的服务器
  // ossResult.filename
}
