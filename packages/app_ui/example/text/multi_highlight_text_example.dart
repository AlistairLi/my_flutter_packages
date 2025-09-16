import 'package:app_ui/src/text/multi_highlight_text.dart';
import 'package:flutter/widgets.dart';

Widget buildTextRich() {
  String coinsStr = "1";

  return MultiHighlightText(
    template: "每场比赛消耗XXX金币",
    variables: {
      "XXX": coinsStr,
    },
    highlightStyles: {
      "XXX": TextStyle(
        color: Color(0xFFFFEE58),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    },
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}
