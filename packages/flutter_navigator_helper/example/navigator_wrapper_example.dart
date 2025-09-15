import 'package:flutter/material.dart';
import 'package:flutter_navigator_helper/src/navigator_observer_impl.dart';
import 'package:flutter_navigator_helper/src/navigator_util.dart';
import 'package:flutter_navigator_helper/src/route_config.dart';

void main() {
  runApp(MaterialApp(
    // ...
    navigatorKey: RouteConfig.navigatorKey,
    navigatorObservers: [naviObserverImpl],
  ));
}

void example() {
  var topRouter = NavigatorUtil.topStackRoutingName;
}
