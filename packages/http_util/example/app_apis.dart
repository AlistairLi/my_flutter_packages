// 用到的API
class AppApis {
  AppApis._();

  static const String apisGetSafeUploadUrl = 'risk/info/upload'; // 风控主动上报

  /// App flyer功能
  static const String apisAscribeRecordUrl = 'hit/ascribeRecordReqs'; // AF上报

  /// 前后台切换功能
  static const String apisAppModeSwitch = "user/mode/switch"; // 上报用户状态

  /// 长链功能
  static const String apisAppHeartbeat = "user/activeing"; // 心跳

  /// 打点功能
  static const String apisLogUrl = "log/liveChatPostV2"; // 打点

  /// 文件上传
  static const String apisOssAuthUrl = 'user/oss/policyPostV2'; // oss授权

  /// 应用启动
  static const String apisGetStrategyUrl = 'config/getStrategyPostV2'; // 获取应用策略
  static const String apisGetAppConfigUrlPostV2 =
      'config/getAppConfigPostV2'; // 获取应用配置

  /// IM功能
  static const String apisRtcTokenUrl =
      'user/rongcloud/tokenPostV2'; // 获取融云Token

  /// 登录功能
  static const String apisLoginUrl = 'security/oauth'; // 登录
  static const String apisQuitLoginUrl = 'security/logout'; // 退出登录
  static const String apisRemoveUserUrl = 'user/deleteAccount'; // 删除账号

  /// 用户信息功能
  static const String apisGetUserInfoUrl = 'user/getUserInfo'; // 获取用户信息
  static const String apisGetUserInfoUrlPostV2 =
      'user/getUserInfoPostV2'; // 获取用户信息
  static const String apisSaveUserInfoUrl = 'user/saveUserInfo'; //保存用户信息
  static const String apisUpdateAvatarUrl = 'user/updateAvatar'; //更新用户头像
  static const String apisupdateMediaUrl = 'user/updateMedia'; //更新用户媒体资料
  static const String apisgetUserCoinsUrl = "user/getUserCoins"; // 获取用户金币数
  static const String apisgetUserCoinsUrlPostV2 =
      "user/getUserCoinsPostV2"; // 获取用户金币数
  static const String apisgetUserOnlineStatus =
      'user/getUserOnlineStatusPostV2'; // 获取用户在线状态
  static const String apisgetUserListOnlineStatus =
      'user/getUserListOnlineStatusPostV2'; // 批量获取用户在线状态
  static const String apisgetAnchorExtraInfo =
      'user/getBroadcasterExtraInfoPostV2'; // 获取主播额外信息

  /// 主播墙功能
  static const String apisgetBroadcasterUrl =
      'broadcaster/wall/search'; // 拉取主播墙
  static const String apisgetRandomBroadcasterUrl =
      'user/getRandomBroadcasterPostV2'; // 获取随机推荐主播
  static const String apisgetUserGifts = 'gift/getGiftCount'; // 获取用户礼物列表

  /// 关注功能
  static const String apisaddFriendUrl = 'user/addFriend'; // 添加好友
  static const String apisunfriendUrl = 'user/unfriend'; // 移除好友
  static const String apisFavoriteListUrl = "user/getFriendsListPage"; // 获取好友列表

  /// 拉黑功能
  static const String apisreportOrBlockUrl =
      'report/complain/insertRecord'; // 举报/拉黑
  static const String apisemoveBlockUrl =
      'report/complain/removeBlock'; // 移出黑名单
  static const String apisgetBlockListUrl =
      'report/complain/blockList'; // 获取黑名单列表

  /// 充值功能
  static const String apisgeGoodsUrl = 'coin/goods/search'; // 获取商品列表
  static const String apisgetPromotionGoodUrl =
      'coin/goods/getPromotion'; // 获取促销商品（新用户促销）
  static const String apisgetPayChannelUrl =
      'coin/payChannel/getPostV2'; // 获取支付渠道
  static const String apiscreateOrderUrl = 'coin/recharge/create'; // 创建订单
  static const String apischeckApplePaymentStatusUrl =
      'coin/recharge/payment/ipa'; // iOS内购验单
  static const String apischeckGooglePaymentStatusUrl =
      'coin/recharge/payment/gp'; // 谷歌内购验单
  static const String apischeckLinkUrl =
      'coin/recharge/checkBroadcasterInvitationPostV2'; // 验证充值链接是否有效
  static const String apisgetChargeLinkGoodsListUrl =
      'coin/goods/broadcasterInvitation'; // 获取点击充值链接要展示的商品

  /// Banner功能
  static const String apisGetBannerUrl = 'game/banner/info'; // 轮播信息

  /// 快速匹配功能
  static const String apisflashChatUrl = 'video-call/flash/chat'; // 发起匹配
  static const String apiscancelFlashChatUrl = "video-call/match/cancel";
  static const String apisflashChatContentSearchUrl =
      'config/content/search'; // 轮播话术

  /// 通话功能
  static const String apiscreateChannelUrl =
      'video-call/channel/create'; // 创建通道
  static const String apisgetChatTimeUrl =
      'video-call/user/callResult'; // 获取通话时长
  static const String apiscallHangUpUrl = "video-call/hangUp"; // 挂断通话
  static const String apiscallPickUp = "video-call/pickUp"; // 接听通话
  static const String apisjoinRoomSuccess = "video-call/channel/join"; // 加入通话
  static const String apisupdateUid = "user/updateAgoraUid"; // 更新声网ID
  static const String apisCallDuration = "video-call/duration"; // 获取通话时长

  /// 切换摄像头功能
  static const String apisgetCameraConfigUrl =
      "user/rearCamera/config"; // 获取当前摄像头配置信息
  static const String apisopenCameraUrl = "user/rearCamera/open"; // 打开摄像头

  /// 礼物功能
  static const String apisgetGiftListUrl = "gift/v2/listPostV2"; // 获取礼物列表
  static const String apissendGiftUrl = "user/giveUserGifts"; // 发送礼物

  /// 设置功能
  static const String apisswitchDisturbUrl =
      'user/switchNotDisturb'; // IM和视频通话消息开关

  /// 导量功能
  static const String apisbindInviteCode = 'user/guideInviteCode/bind'; // 提交邀请码
  static const String apisgetGuideConfig = 'user/strongGuide/config'; // 获取导量配置
  static const String apisgetGuideResultConfig =
      'config/getGuideInConfig'; // 获取导量成功提示

  /// 活动、新用户注册奖励
  static const String apisgetPresented =
      'coin/presented/getPostV2'; // 获取新用户注册奖励
  static const String apisgetSpecialOffer =
      'coin/goods/getLastSpecialOfferV2'; // 获取促销活动

  /// 排行榜
  static const String apisgetAnchorRankSearch =
      'broadcaster/rank/search'; // 主播排行榜
  static const String apisgetUserRankSearch = 'user/rank/search'; // 用户排行榜
  static const String apisgetUserRankCp = 'user/rank/searchCouple'; // cp排行榜

  /// 机器人客服
  static const String apisgetFaqUrl = 'user/FAQ/get';

  ///策略下发模块
  static const String getRongCloudToken =
      "user/rongcloud/tokenPostV2"; //获取融云token✅

  ///登录模块
  static const String login = "security/oauth"; //登录✅

  static const String checkToken = "security/isValidToken"; //Token校验

  static const String logout = "security/logout"; //退出登录✅

  static const String deleteAccount = "user/deleteAccount"; //删除账号✅

  ///用户模块
  static const String broadcasterWall =
      "broadcaster/wall/search"; //主播墙接口-获取A面模拟的用户资料✅
  static const String userInfo = "user/getUserInfoPostV2"; //用户信息✅
  static const String updateAvatar = "user/updateAvatar"; //更新头像✅
  static const String updateUserInfo = "user/saveUserInfo"; //保存用户信息✅
  static const String addFriend = "user/addFriend"; //关注✅
  static const String unfriend = "user/unfriend"; //取消关注✅
  static const String addToBlockList = "report/complain/insertRecord"; //举报拉黑✅
  static const String removeFromBlockList =
      "report/complain/removeBlock"; //解除拉黑接口✅
  static const String blockList = "report/complain/blockList"; //获取屏蔽列表接口✅
  static const String getFriendsList = "user/getFriendsListPage"; //获取关注列表接口

  ///内购模块
  static const String goodsList = "coin/goods/search"; //充值商品列表✅
  static const String createRechargeOrder = "coin/recharge/create"; //创建充值订单接口✅
  static const String checkRechargeOrder = "coin/recharge/payment/ipa"; //验单接口✅
  static const String consumeCoin = "coin/reviewModeConsume"; //金币消耗接口✅

  static String isValidToken = 'security/isValidToken';
  static String rankList = 'broadcaster/wall/search';
  static String removeFriend = 'user/unfriend';
  static String saveUserInfo = 'user/saveUserInfo';
  static String getUserInfo = 'user/getUserInfoPostV2';
  static String getOssPolicy = 'user/oss/policyPostV2';
  static String getFollowedList = 'user/getFriendsListPage';
  static String reportComplain = 'report/complain/insertRecord';
  static String unblock = 'report/complain/removeBlock';
  static String googleTranslate =
      'https://translation.googleapis.com/language/translate/v2';
  static String getIMStrategy = 'config/getStrategyPostV2';
  static String getIMToken = 'user/rongcloud/tokenPostV2';
  static String trackingLog = 'log/liveChatPostV2';
  static String createOrder = 'coin/recharge/create';
  static String validateOrder = 'coin/recharge/payment/ipa';
  static String reviewModeConsume = 'coin/reviewModeConsume';
}
