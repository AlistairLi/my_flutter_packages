import 'package:flutter/material.dart';
import 'package:smart_video_player/smart_video_player.dart';

class Demo extends StatelessWidget {
  final pagerController = VideoPagerController();

  final items = [
    VideoItem(
      url: "http://xxx/video1.mp4",
      sourceType: SmartVideoSourceType.network,
      title: "第一条视频",
      description: "这是一个描述",
    ),
    VideoItem(
      url: "http://xxx/video2.mp4",
      sourceType: SmartVideoSourceType.network,
      title: "第二条视频",
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoPager(
        items: items,
        controller: pagerController,
        overlayBuilder: (context, item, {index}) {
          return Center(
            child: Text(
              "title",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          );
        },
      ),
    );
  }
}
