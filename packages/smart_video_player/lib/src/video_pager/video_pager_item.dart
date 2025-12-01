import 'package:smart_video_player/smart_video_player.dart';

class VideoItem {
  final String url;
  final SmartVideoSourceType sourceType;
  final String? title;
  final String? description;
  final String? coverImage;
  final String? region;

  /// 扩展字段
  final Map<String, dynamic>? extra;

  VideoItem({
    required this.url,
    required this.sourceType,
    this.title,
    this.description,
    this.coverImage,
    this.region,
    this.extra,
  });
}
