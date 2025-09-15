import 'package:litebase/src/model/db_model.dart';

/// 包含 id 和 content 的通用数据模型
class IdContentModel extends DbModel {
  IdContentModel({
    String? id,
    String? content,
  }) {
    _id = id;
    _content = content;
  }

  IdContentModel.fromJson(dynamic json) {
    _id = json['id'];
    _content = json['content'];
  }

  String? _id;
  String? _content;

  IdContentModel copyWith({
    String? id,
    String? content,
  }) =>
      IdContentModel(
        id: id ?? _id,
        content: content ?? _content,
      );

  String? get id => _id;

  String? get content => _content;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['content'] = _content;
    return map;
  }

  @override
  Map<String, dynamic> toMap() => toJson();
}
