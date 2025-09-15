/// OSS配置模型
class OssAuth {
  OssAuth({
    String? accessKeyId,
    String? policy,
    String? signature,
    String? expire,
    String? dir,
    String? host,
    String? callback,
  }) {
    _accessKeyId = accessKeyId;
    _policy = policy;
    _signature = signature;
    _expire = expire;
    _dir = dir;
    _host = host;
    _callback = callback;
  }

  OssAuth.fromJson(dynamic json) {
    _accessKeyId = json['accessKeyId'];
    _policy = json['policy'];
    _signature = json['signature'];
    _expire = json['expire'];
    _dir = json['dir'];
    _host = json['host'];
    _callback = json['callback'];
  }

  String? _accessKeyId;
  String? _policy;
  String? _signature;
  String? _expire;
  String? _dir;
  String? _host;
  String? _callback;

  OssAuth copyWith({
    String? accessKeyId,
    String? policy,
    String? signature,
    String? expire,
    String? dir,
    String? host,
    String? callback,
  }) =>
      OssAuth(
        accessKeyId: accessKeyId ?? _accessKeyId,
        policy: policy ?? _policy,
        signature: signature ?? _signature,
        expire: expire ?? _expire,
        dir: dir ?? _dir,
        host: host ?? _host,
        callback: callback ?? _callback,
      );

  String? get accessKeyId => _accessKeyId;

  String? get policy => _policy;

  String? get signature => _signature;

  String? get expire => _expire;

  String? get dir => _dir;

  String? get host => _host;

  String? get callback => _callback;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['accessKeyId'] = _accessKeyId;
    map['policy'] = _policy;
    map['signature'] = _signature;
    map['expire'] = _expire;
    map['dir'] = _dir;
    map['host'] = _host;
    map['callback'] = _callback;
    return map;
  }
}

/// OSS上传结果模型
class OssResult {
  OssResult({
    String? filename,
    String? size,
    String? mimeType,
    String? width,
    String? height,
  }) {
    _filename = filename;
    _size = size;
    _mimeType = mimeType;
    _width = width;
    _height = height;
  }

  OssResult.fromJson(dynamic json) {
    _filename = json['filename'];
    _size = json['size'];
    _mimeType = json['mimeType'];
    _width = json['width'];
    _height = json['height'];
  }

  String? _filename;
  String? _size;
  String? _mimeType;
  String? _width;
  String? _height;

  OssResult copyWith({
    String? filename,
    String? size,
    String? mimeType,
    String? width,
    String? height,
  }) =>
      OssResult(
        filename: filename ?? _filename,
        size: size ?? _size,
        mimeType: mimeType ?? _mimeType,
        width: width ?? _width,
        height: height ?? _height,
      );

  String? get filename => _filename;

  String? get size => _size;

  String? get mimeType => _mimeType;

  String? get width => _width;

  String? get height => _height;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['filename'] = _filename;
    map['size'] = _size;
    map['mimeType'] = _mimeType;
    map['width'] = _width;
    map['height'] = _height;
    return map;
  }
}
