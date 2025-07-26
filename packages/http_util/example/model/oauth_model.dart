import 'user_model.dart';

class OauthModel {
  String? token;
  bool? isFirstRegister;
  UserModel? userInfo;

  OauthModel({
    this.userInfo,
    this.isFirstRegister,
    this.token,
  });

  factory OauthModel.fromJson(Map<dynamic, dynamic> json) => OauthModel(
        token: json["token"],
        isFirstRegister: json["isFirstRegister"],
        userInfo: json["userInfo"] != null
            ? UserModel.fromJson(json["userInfo"])
            : null,
      );

  Map<dynamic, dynamic> toJson() => {
        "token": token,
        "isFirstRegister": isFirstRegister,
        "userInfo": userInfo?.toJson(),
      };
}
