class AppConfigModel {
  AppConfigModel({
    required this.k1,
    required this.k2,
    required this.k3,
    required this.k4,
    required this.strategy,
    required this.isWebApp,
    required this.mType,
  });

  String? k1;
  String? k2;
  String? k3;
  String? k4;
  String? strategy;
  String? isWebApp;
  String? mType;

  factory AppConfigModel.fromJson(Map<dynamic, dynamic> json) => AppConfigModel(
        k1: json["k1"],
        k2: json["k2"],
        k3: json["k3"],
        k4: json["k4"],
        strategy: json["strategy"],
        isWebApp: json["isWebApp"],
        mType: json["mType"],
      );

  Map<dynamic, dynamic> toJson() => {
        "k1": k1,
        "k2": k2,
        "k3": k3,
        "k4": k4,
        "strategy": strategy,
        "isWebApp": isWebApp,
        "mType": mType,
      };
}
