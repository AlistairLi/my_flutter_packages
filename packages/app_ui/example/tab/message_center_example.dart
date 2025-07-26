import 'package:app_ui/src/tab/app_multi_tab_widget2.dart';
import 'package:flutter/material.dart';

/// 消息中心
class MessageCenterExample extends StatelessWidget {
  const MessageCenterExample({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> titles = [
      "tab1",
      "tab2",
      "tab3",
    ];
    return MultiTabView2<String, String>(
      firstLevelTabs: titles,
      // 没有二级标签，secondLevelTabs这样传值:
      secondLevelTabs: List.filled(titles.length, [""]),
      firstLevelStyle: TabStyleConfig2(
        labelStyle: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        indicator: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/image/xxx.png"),
            alignment: Alignment.bottomCenter,
            // fit: BoxFit.contain,
            scale: 3,
          ),
        ),
        padding: EdgeInsetsDirectional.symmetric(horizontal: 10),
        labelPadding: EdgeInsetsDirectional.symmetric(horizontal: 10),
      ),
      firstLevelTitleExtractor: (value) => value,
      secondLevelTitleExtractor: (value) => value,
      shouldShowSecondLevel: (secondTabs) => secondTabs.isNotEmpty,
      customHeader: SizedBox(height: MediaQuery.of(context).padding.top),
      widthScaleFactor: 1.0,
      textScaleFactor: 1.0,
      onFirstLevelSelected: (firstIndex, firstTab) {
        //
      },
      contentBuilder: (firstIndex, secondIndex, firstTab, secondTab) {
        switch (firstIndex) {
          case 0:
            return Container(
              alignment: Alignment.center,
              child: Text("tab1"),
            );
          case 1:
            return Container(
              alignment: Alignment.center,
              child: Text("tab2"),
            );
          case 2:
            return Container(
              alignment: Alignment.center,
              child: Text("tab3"),
            );
          default:
            return SizedBox.expand();
        }
      },
    );
  }
}
