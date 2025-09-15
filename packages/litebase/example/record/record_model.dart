import 'package:litebase/litebase.dart';

class RecordModel extends DbModel {
  RecordModel({
    String? userId,
    String? nickname,
    String? avatar,
    num? createTimestamp,
    num? updateTimestamp,
  }) {
    _userId = userId;
    _nickname = nickname;
    _avatar = avatar;
    _createTimestamp = createTimestamp;
    _updateTimestamp = updateTimestamp;
  }

  /// 创建记录的命名构造函数
  RecordModel.createRecord({
    required String channel,
    required String userId,
    required String nickname,
    required String avatar,
    required String state,
    num? age,
    String? country,
    String? onlineStatus,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _userId = userId;
    _nickname = nickname;
    _avatar = avatar;
    _createTimestamp = now;
    _updateTimestamp = now;
  }

  RecordModel.fromJson(dynamic json) {
    _userId = json['userId'].toString();
    _nickname = json['nickname'];
    _avatar = json['avatar'];
    _createTimestamp = json['createTimestamp'];
    _updateTimestamp = json['updateTimestamp'];
  }

  String? _userId;
  String? _nickname;
  String? _avatar;
  num? _createTimestamp; // 创建时间戳
  num? _updateTimestamp; // 更新时间戳

  RecordModel copyWith({
    String? userId,
    String? nickname,
    String? avatar,
    num? createTimestamp,
    num? updateTimestamp,
  }) =>
      RecordModel(
        userId: userId ?? _userId,
        nickname: nickname ?? _nickname,
        avatar: avatar ?? _avatar,
        createTimestamp: createTimestamp ?? _createTimestamp,
        updateTimestamp: updateTimestamp ?? _updateTimestamp,
      );

  String? get userId => _userId;

  String? get nickname => _nickname;

  String? get avatar => _avatar;

  num? get createTimestamp => _createTimestamp;

  num? get updateTimestamp => _updateTimestamp;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userId'] = _userId;
    map['nickname'] = _nickname;
    map['avatar'] = _avatar;
    map['createTimestamp'] = _createTimestamp;
    map['updateTimestamp'] = _updateTimestamp;
    return map;
  }

  @override
  Map<String, dynamic> toMap() => toJson();
}
