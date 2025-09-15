import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_navigator_helper/src/route_config.dart';

final naviObserverImpl = NaviObserverImpl();

class NaviObserverImpl extends NavigatorObserver {
  final String _tag = "NaviObserverImpl";
  final _routeBroadcast = StreamController<Route<dynamic>>.broadcast();

  Stream<Route<dynamic>> get routeStream => _routeBroadcast.stream;

  final List<Route<dynamic>> _routeHistories = [];

  List<Route<dynamic>> get routeHistories => _routeHistories;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeHistories.add(route);
    _sendRouteData();
    if (RouteConfig.enablePrint) {
      print(
          "$_tag, didPush(), ${route.settings.name} ${previousRoute?.settings.name}");
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeHistories.remove(route);
    if (RouteConfig.enablePrint) {
      print(
          "$_tag, didPop(), ${route.settings.name} ${previousRoute?.settings.name}");
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeHistories.remove(route);
    print(route.settings.name);
    _sendRouteData();
    if (RouteConfig.enablePrint) {
      print(
          "$_tag, didRemove(), ${route.settings.name} ${previousRoute?.settings.name}");
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    var index = -1;
    if (oldRoute != null) {
      index = _routeHistories.indexOf(oldRoute);
    }
    if (index >= 0) {
      _routeHistories[index] = newRoute!;
      _sendRouteData();
    }
    if (RouteConfig.enablePrint) {
      print(
          "$_tag, didReplace(), ${newRoute?.settings.name} ${oldRoute?.settings.name}");
    }
  }

  void _sendRouteData() {
    _routeBroadcast.add(_routeHistories.last);
  }
}
