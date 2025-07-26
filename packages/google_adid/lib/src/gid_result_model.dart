class GidResultModel {
  String? gid;
  int? code;
  String? msg;

  GidResultModel(this.gid, this.code, this.msg);

  factory GidResultModel.fromJson(Map<String, dynamic> json) {
    return GidResultModel(
      json['gid'] ?? "",
      json['code'] ?? -1,
      json['msg'] ?? "",
    );
  }
}
