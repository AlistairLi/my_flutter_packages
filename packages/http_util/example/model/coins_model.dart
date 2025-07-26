class CoinsModel {
  int? availableCoins;

  CoinsModel({
    this.availableCoins,
  });

  factory CoinsModel.fromJson(Map<dynamic, dynamic> json) => CoinsModel(
        availableCoins: json["availableCoins"],
      );

  Map<dynamic, dynamic> toJson() => {
        "availableCoins": availableCoins,
      };
}
