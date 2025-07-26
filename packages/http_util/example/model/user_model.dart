class UserModel {
  String? userId;
  String? nickname;
  String? country;
  String? avatarUrl;
  int? availableCoins;
  int? gender;
  int? age;

  UserModel({
    this.avatarUrl,
    this.availableCoins,
    this.gender,
    this.nickname,
    this.userId,
    this.age,
  });

  factory UserModel.fromJson(Map<dynamic, dynamic> json) => UserModel(
        avatarUrl: json["avatarUrl"],
        availableCoins: json["availableCoins"],
        gender: json["gender"],
        nickname: json["nickname"],
        userId: json["userId"],
        age: json["age"],
      );

  Map<dynamic, dynamic> toJson() => {
        "country": country,
        "avatarUrl": avatarUrl,
        "availableCoins": availableCoins,
        "gender": gender,
        "nickname": nickname,
        "userId": userId,
        "age": age,
      };
}
