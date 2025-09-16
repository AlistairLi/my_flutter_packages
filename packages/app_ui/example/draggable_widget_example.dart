import 'dart:math';

import 'package:app_ui/src/draggable_widget.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@override
Widget build(BuildContext context) {
  var isArabic = Random().nextBool();
  var screenWidth = MediaQuery.of(context).size.width;
  return PopScope(
    canPop: false,
    child: Stack(
      children: [
        DraggableWidget(
          offset: Offset(
            isArabic ? 20 : screenWidth - 100 - 20,
            0,
          ),
          parentKey: navigatorKey,
          child: Container(
            width: 100,
            height: 100,
            color: Colors.green,
          ),
        )
      ],
    ),
  );
}
