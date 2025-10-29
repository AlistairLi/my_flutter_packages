import 'package:danmaku_widget/src/danmaku_widget.dart';
import 'package:flutter/material.dart';

class DanmakuWidgetExample extends StatefulWidget {
  const DanmakuWidgetExample({super.key});

  @override
  State<DanmakuWidgetExample> createState() => _DanmakuWidgetExampleState();
}

class _DanmakuWidgetExampleState extends State<DanmakuWidgetExample> {
  final DanmakuManager _danmakuManager = DanmakuManager();

  static final Color color1 = Colors.tealAccent;
  static final Color color2 = Colors.blue;
  static final Color color3 = Colors.greenAccent;
  static final Color color4 = Colors.white;
  static final Color color5 = Colors.yellow;

  void _addSampleDanmaku() {
    // 添加示例弹幕，模拟图片中的效果
    _danmakuManager.addDanmaku(
      "OMG this part is insane! 🔥",
      borderColor: color1,
    );

    _danmakuManager.addDanmaku(
      "I’ve watched this like 10 times already 😂",
      borderColor: color2,
    );

    _danmakuManager.addDanmaku(
      "That transition was smooth af 😳",
      borderColor: color3,
    );

    _danmakuManager.addDanmaku(
      "Who else got chills here? 👀",
      borderColor: color4,
    );

    _danmakuManager.addDanmaku(
      "Everyone talking about the scene, but that soundtrack tho 🎧",
      borderColor: color5,
    );

    _danmakuManager.addDanmaku(
      "Bro just casually dropped a masterpiece 💯",
      borderColor: color1,
    );

    _danmakuManager.addDanmaku(
      "Can’t stop smiling watching this 😭",
      borderColor: color2,
    );

    _danmakuManager.addDanmaku(
      "The editing skills are unreal 😮",
      borderColor: color3,
    );

    _danmakuManager.addDanmaku(
      "Wait… how did they even do that?? 🤯",
      borderColor: color4,
    );

    _danmakuManager.addDanmaku(
      "Literally perfection, no notes 😌",
      borderColor: color5,
    );

    _danmakuManager.addDanmaku(
      "This deserves way more views 🙌",
      borderColor: color1,
    );

    _danmakuManager.addDanmaku(
      "I came here just for this moment 😆",
      borderColor: color2,
    );

    _danmakuManager.addDanmaku(
      "The vibe is immaculate 🌈",
      borderColor: color3,
    );

    _danmakuManager.addDanmaku(
      "Why does this go so hard?? 😭🔥",
      borderColor: color4,
    );

    _danmakuManager.addDanmaku(
      "That timing was perfect 👏👏",
      borderColor: color5,
    );
  }

  @override
  void initState() {
    super.initState();
    _addSampleDanmaku();
  }

  @override
  void dispose() {
    _danmakuManager.clearDanmaku();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          height: 240,
          child: DanmakuWidget(
            danmakuDataSource: _danmakuManager.danmakuList,
            config: DanmakuConfig(
              fontSize: 13,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              borderRadius: 10,
              borderWidth: 1,
            ),
          ),
        ),
      ),
    );
  }
}
