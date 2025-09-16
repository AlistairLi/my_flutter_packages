class AppsflyerArgs {
  String? pkg;
  String? ver;
  String? deviceId;
  String? userId;
  String? utmSource;
  String? adgroupId;
  String? adset;
  String? adsetId;
  String? afStatus;
  String? agency;
  String? afChannel;
  String? campaign;
  String? campaignId;

  AppsflyerArgs.fromJson(dynamic json) {
    utmSource = json['media_source'];
    adgroupId = json['adgroup_id'];
    adset = json['adset'];
    adsetId = json['adset_id'];
    afStatus = json['af_status'];
    agency = json['agency'];
    afChannel = json['af_channel'];
    campaign = json['campaign'];
    campaignId = json['campaign_id'];
  }
}
