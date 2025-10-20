class UserModelExample {
  String? userId;
  String? nickname;
  int? age;

  UserModelExample({
    this.userId,
    this.nickname,
    this.age,
  });

  factory UserModelExample.fromJson(Map<dynamic, dynamic> json) =>
      UserModelExample(
        userId: json["userId"],
        nickname: json["nickname"],
        age: json["age"],
      );

  Map<dynamic, dynamic> toJson() => {
        "userId": userId,
        "nickname": nickname,
        "age": age,
      };
}
