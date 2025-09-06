import 'package:flutter/material.dart';
import 'package:smart_video_player/smart_video_player.dart';

class VideoPlayerPage extends StatelessWidget {
  VideoPlayerPage({super.key});

  final List<String> videoPaths = [
    "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Smart video player",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              itemCount: videoPaths.length,
              controller: PageController(initialPage: 0),
              itemBuilder: (context, index) {
                return SmartVideoPlayer(
                  videoUrl: videoPaths[index],
                  sourceType: SmartVideoSourceType.network,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
